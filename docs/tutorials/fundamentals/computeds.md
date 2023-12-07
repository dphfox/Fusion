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
that performs your calculation.

```Lua linenums="5" hl_lines="2-4"
local scope = scoped(Fusion)
local hardMaths = scope:Computed(function(_, _)
    return 1 + 1
end)
```

The value the callback returns will be stored as the computed's value. You can
get the computed's current value using `peek()`:

```Lua linenums="5" hl_lines="6"
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

```Lua linenums="5"
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

```Lua linenums="5" hl_lines="4"
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

```Lua linenums="5" hl_lines="4"
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

??? question "Help! Using the same name gives me a warning."

	Depending on your setup, Luau might be configured to warn when you use the
	same variable name multiple times.

	In many cases, using the same variable name can be a mistake, but in this
	case we actually find it useful. So, to turn off the warning, try adding
	`--!nolint LocalShadow` to the top of your file.

Keep in mind that Fusion might apply its own optimisations to these calculations.
It might choose to delay the recalculation if the computed isn't actively being
used, or it might never recalculate at all. It shouldn't affect normal
calculations, but if you need to do things like playing sound effects, you
should put those things inside observer objects instead.

-----

## Inner Scopes

Sometimes, you'll need to create things inside computed objects temporarily. In
these cases, you want the temporary things to be destroyed when you're done.

You might try and reuse the scope you already have, but that scope doesn't get
destroyed when the computed object recalculates, so it won't work:

```Lua linenums="5"
local scope = scoped(Fusion)
local valueMaker = scope:Computed(function(use, _)
	-- this `innerValue` never gets destroyed, ever
	local innerValue = scope:Value(5)
end)
```

That's why the second argument is a freshly created scope for you to use while
inside the computed object. This freshly created scope is automatically cleaned
up for you when the computed object recalculates.

```Lua linenums="5" hl_lines="2"
local scope = scoped(Fusion)
local valueMaker = scope:Computed(function(use, brandNewScope)
	-- now, `innerValue` is destroyed at the correct time
	local innerValue = brandNewScope:Value(5)
end)
```

It can help to give this parameter the same name as the original scope. This
stops you from accidentally using the original scope inside the computed, and
makes your code more easily copyable and movable.

```Lua linenums="5"
local scope = scoped(Fusion)
local valueMaker = scope:Computed(function(use, scope)
	local innerValue = scope:Value(5)
end)
```

??? question "Help! Using the same name gives me a warning."

	Depending on your setup, Luau might be configured to warn when you use the
	same variable name multiple times.

	In many cases, using the same variable name can be a mistake, but in this
	case we actually find it useful. So, to turn off the warning, try adding
	`--!nolint LocalShadow` to the top of your file.