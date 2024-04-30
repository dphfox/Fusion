Computeds are state objects that immediately process values from other state
objects.

You pass in a callback to define a calculation. Then, you can use
`peek()` to read the result of the calculation at any time.

```Lua
local numCoins = scope:Value(50)
local itemPrice = scope:Value(10)

local finalCoins = scope:Computed(function(use, scope)
    return use(numCoins) - use(itemPrice)
end)

print(peek(finalCoins)) --> 40

numCoins:set(25)
itemPrice:set(15)
print(peek(finalCoins)) --> 10
```

-----

## Usage

To create a new computed object, call `scope:Computed()` and give it a function
that performs your calculation. It takes two parameters which will be explained
later; for the first part of this tutorial, they'll be left unnamed.

```Lua linenums="6" hl_lines="2-4"
local scope = scoped(Fusion)
local hardMaths = scope:Computed(function(_, _)
    return 1 + 1
end)
```

The value the callback returns will be stored as the computed's value. You can
get the computed's current value using `peek()`:

```Lua linenums="6" hl_lines="6"
local scope = scoped(Fusion)
local hardMaths = scope:Computed(function(_, _)
    return 1 + 1
end)

print(peek(hardMaths)) --> 2
```

The calculation should be *immediate* - that is, it should never delay. That
means you should not use computed objects when you need to wait for something to
occur (e.g. waiting for a server to respond to a request).

-----

## Using State Objects

The calculation is only run once by default. If you try to `peek()` at state
objects inside the calculation, your code breaks quickly:

```Lua linenums="6" hl_lines="10-11"
local scope = scoped(Fusion)
local number = scope:Value(2)
local double = scope:Computed(function(_, _)
    return peek(number) * 2
end)

print(peek(number), peek(double)) --> 2 4

-- The calculation won't re-run! Oh no!
number:set(10)
print(peek(number), peek(double)) --> 10 4
```

Instead, the computed object provides a `use` function as the first argument.
As your logic runs, you can call this function with different state objects. If
any of them changes, then the computed throws everything away and recalculates.

```Lua linenums="6" hl_lines="4"
local scope = scoped(Fusion)
local number = scope:Value(2)
local double = scope:Computed(function(use, _)
	use(number) -- the calculation will re-run when `number` changes value
    return peek(number) * 2
end)

print(peek(number), peek(double)) --> 2 4

-- Now it re-runs!
number:set(10)
print(peek(number), peek(double)) --> 10 20
```

For convenience, `use()` will also read the value, just like `peek()`, so you
can easily replace `peek()` calls with `use()` calls. This keeps your logic
concise, readable and easily copyable.

```Lua linenums="6" hl_lines="4"
local scope = scoped(Fusion)
local number = scope:Value(2)
local double = scope:Computed(function(use, _)
    return use(number) * 2
end)

print(peek(number), peek(double)) --> 2 4

number:set(10)
print(peek(number), peek(double)) --> 10 20
```

It's recommended you always give the first parameter the name `use`, even if it
already exists. This helps prevent you from using the wrong parameter if you
have multiple computed objects at the same time.

```Lua
scope:Computed(function(use, _)
	-- ...
	scope:Computed(function(use, _)
		-- ...
		scope:Computed(function(use, _)
			return use(number) * 2
		end)
		-- ...
	end)
	-- ...
end)
```

??? warning "Help! Using the same name gives me a warning."

	Depending on your setup, Luau might be configured to warn when you use the
	same variable name multiple times.

	In many cases, using the same variable name can be a mistake, but in this
	case we actually find it useful. So, to turn off the warning, try adding
	`--!nolint LocalShadow` to the top of your file.

Keep in mind that Fusion sometimes applies optimisations; recalculations might
be postponed or cancelled if the value of the computed isn't being used. This is
why you should not use computed objects for things like playing sound effects.

[You will learn more about how Fusion does this later.](../../best-practices/optimisation/#similarity)

-----

## Inner Scopes

Sometimes, you'll need to create things inside computed objects temporarily. In
these cases, you want the temporary things to be destroyed when you're done.

You might try and reuse the scope you already have, to construct objects and
add cleanup tasks.

=== "Luau code"

	```Lua linenums="6" hl_lines="7"
	local scope = scoped(Fusion)
	local number = scope:Value(5)
	local double = scope:Computed(function(use, _)
		local current = use(number)
		print("Creating", current)
		-- suppose we want to run some cleanup code for stuff in here
		table.insert(scope, function()
			print("Destroying", current)
		end)
		return current * 2
	end)

	print("...setting to 25...")
	number:set(25)
	print("...setting to 2...")
	number:set(2)
	print("...cleaning up...")
	doCleanup(scope)
	```

=== "Output"

	```
	Creating 5
	...setting to 25...
	Creating 25
	...setting to 2...
	Creating 2
	...cleaning up...
	Destroying 2
	Destroying 25
	Destroying 5
	```

However, this doesn't work the way you'd want it to. All of the tasks pile up at
the end of the program, instead of being thrown away with the rest of the
calculation.

That's why the second argument is a different scope for you to use while inside
the computed object. This scope argument is automatically cleaned up for you
when the computed object recalculates.

=== "Luau code"

	```Lua linenums="6" hl_lines="3 6"
	local scope = scoped(Fusion)
	local number = scope:Value(5)
	local double = scope:Computed(function(use, myBrandNewScope)
		local current = use(number)
		print("Creating", current)
		table.insert(myBrandNewScope, function()
			print("Destroying", current)
		end)
		return current * 2
	end)

	print("...setting to 25...")
	number:set(25)
	print("...setting to 2...")
	number:set(2)
	print("...cleaning up...")
	doCleanup(scope)
	```

=== "Output"

	```
	Creating 5
	...setting to 25...
	Creating 25
	Destroying 5
	...setting to 2...
	Creating 2
	Destroying 25
	...cleaning up...
	Destroying 2
	```

When using this new 'inner' scope, the tasks no longer pile up at the end of the
program. Instead, they're cleaned up as soon as possible, when the computed
object throws away the old calculation.

It can help to give this parameter the same name as the original scope. This
stops you from accidentally using the original scope inside the computed, and
makes your code more easily copyable and movable.

```Lua
local scope = scoped(Fusion)
scope:Computed(function(use, scope)
	-- ...
	scope:Computed(function(use, scope)
		-- ...
		scope:Computed(function(use, scope)
			local innerValue = scope:Value(5)
		end)
		-- ...
	end)
	-- ...
end)
```

??? warning "Help! Using the same name gives me a warning."

	Depending on your setup, Luau might be configured to warn when you use the
	same variable name multiple times.

	In many cases, using the same variable name can be a mistake, but in this
	case we actually find it useful. So, to turn off the warning, try adding
	`--!nolint LocalShadow` to the top of your file.

Once you understand computeds, as well as the previously discussed scopes,
values and observers, you're well positioned to explore the rest of Fusion.