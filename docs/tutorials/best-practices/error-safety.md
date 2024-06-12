Code can fail unexpectedly for many reasons. While Fusion tries to prevent many
errors by design, Fusion can't stop you from trying to access data that doesn't
exist, or taking actions that don't make sense to the computer.

So, you need to be able to deal with errors that happen while your program is
running.

-----

## Fatality

An error can be either *fatal* or *non-fatal*:

- fatal errors aren't handled by anything, so they crash your program
- non-fatal errors are handled by Fusion and let your program continue

You're likely familiar with fatal errors. You can create them with `error()`:

=== "Luau code"

	```Lua
	print("before")
	print("before")
	print("before")

	error("Kaboom!")

	print("after")
	print("after")
	print("after")
	```

=== "Output"

	``` hl_lines="4-10"
	before
	before
	before
	Main:7: Kaboom!
	Stack Begin
	Main:7
	Fusion.State.Computed:74 function update
	Fusion.State.Computed:166 function Computed
	Main:6
	Stack End
	```

You can make it non-fatal by protecting the call, with `pcall()`:

=== "Luau code"

	```Lua
	print("before")
	print("before")
	print("before")

	pcall(function()
		error("Kaboom!")
	end)

	print("after")
	print("after")
	print("after")
	```

=== "Output"

	```
	before
	before
	before
	after
	after
	after
	```

### Example

To demonstrate the difference, consider how Fusion handles errors in state objects.

State objects always run your code in a safe environment, to ensure that an
error doesn't leave your state objects in a broken configuration.

This means you can broadly do whatever you like inside of them, and they won't
cause a fatal error that stops your program from running.

=== "Luau code"

	```Lua
	print("before")
	print("before")
	print("before")

	scope:Computed(function()
		error("Kaboom!")
	end)

	print("after")
	print("after")
	print("after")
	```

=== "Output"

	``` hl_lines="4-13"
	before
	before
	before
	[Fusion] Error in callback: Kaboom!
	  (ID: callbackError)
	  ---- Stack trace ----
	  Main:7
	  Fusion.State.Computed:74 function update
	  Fusion.State.Computed:166 function Computed
	  Main:6
	  
	Stack Begin
	Stack End
	after
	after
	after
	```

These are *non-fatal* errors. You don't *have* to handle them, because
Fusion will take all the necessary steps to ensure your program keeps running.
In this case, the `Computed` object tries to roll back to the last value it had,
if any.

```Lua hl_lines="17"
local number = scope:Value(1)
local double = scope:Computed(function(use)
	local number = use(number)
	assert(number ~= 3, "I don't like the number 3")
	return number * 2
end)

print("number:", peek(number), "double:", peek(double))
	--> number: 1 double: 2

number:set(2)
print("number:", peek(number), "double:", peek(double))
	--> number: 2 double: 4

number:set(3)
print("number:", peek(number), "double:", peek(double))
	--> number: 3 double: 4

number:set(4)
print("number:", peek(number), "double:", peek(double))
	--> number: 4 double: 8
```

### Be Careful

Just because your program continues running, doesn't mean that it will behave
the way you expect it to. In the above example, the roll back gave us a nonsense
answer:

```
--> number: 3 double: 4
```

This is why it's still important to practice good error safety. If you expect
an error to occur, you should always handle the error explicitly, and define
what should be done about it.

```Lua hl_lines="4-7 24"
local number = scope:Value(1)
local double = scope:Computed(function(use)
	local number = use(number)
	local ok, result = pcall(function()
		assert(number ~= 3, "I don't like the number 3")
		return number * 2
	end)
	if ok then
		return result
	else
		return "failed: " .. err
	end
end)
```

Now when the computation fails, it fails more helpfully:

```
--> number: 3 double: failed: I don't like the number 3
```

As a general rule, your program should never error in a way that prints red text
to the output.

-----

## Safe Expressions

Functions like `pcall` and `xpcall` can be useful for catching errors. However,
they can often make a lot of code clunkier, like the code above.

To help with this, Fusion introduces
[safe expressions](../../../api-reference/general/members/safe). They let you
try and run a calculation, and fall back to another calculation if it fails.

```Lua
Safe {
	try = function()
		return -- a value that might error during calculation
	end,
	fallback = function(theError)
		return -- a fallback value if an error does occur
	end
}
```
To see how `Safe` improves the readability and conciseness of your code,
consider this next snippet. You can write it using `Safe`, `xpcall` and `pcall`
- here's how each one looks:

=== "pcall"

	```Lua
	local double = scope:Computed(function(use)
		local ok, result = pcall(function()
			local number = use(number)
			assert(number ~= 3, "I don't like the number 3")
			return number * 2
		end)
		if ok then
			return result
		else
			return "failed: " .. err
		end
	end)
	```

=== "xpcall"

	```Lua
	local double = scope:Computed(function(use)
		local _, result = xpcall(
			function()
				local number = use(number)
				assert(number ~= 3, "I don't like the number 3")
				return number * 2
			end,
			function(err)
				return "failed: " .. err
			end
		)
		return result
	end)
	```

=== "Safe"

	```Lua
	local double = scope:Computed(function(use)
		return Safe {
			try = function()
				local number = use(number)
				assert(number ~= 3, "I don't like the number 3")
				return number * 2
			end,
			fallback = function(err)
				return "failed: " .. err
			end
		}
	end)
	```

`pcall` is the simplest way to safely handle errors. It's not entirely
convenient because you have to check the `ok` boolean before you know
whether the calculation was successful, which makes it difficult to use
as part of a larger expression.

`xpcall` is an improvement over `pcall`, because it lets you define the
fallback value as a second function, and uses its return value as the
result of the calculation whenever an error occurs. However, it still
returns the `ok` boolean, which has to be explicitly discarded.

`Safe` is an improvement over `xpcall`, because it does away with the
`ok` boolean altogether, and *only* returns the result. It also clearly
labels the `try` and `fallback` functions so you can easily tell which
one handles which case.

As a result of its design, `Safe` can be used widely throughout Fusion to catch
fatal errors. For example, you can use it to conditionally render error
components directly as part of a larger UI:

```Lua
[Children] = Safe {
	try = function()
		return scope:FormattedForumPost {
			-- ... properties ...
		}
	end,
	fallback = function(err)
		return scope:ErrorPage {
			title = "An error occurred while showing this forum post",
			errorMessage = tostring(err)
		}
	end
}
```

### Non-Fatal Errors

As before, note that *non-fatal* errors aren't caught by `Safe`, because they do
not cause the computation in `try()` to crash.

```Lua
-- The `Safe` is outside the `Computed`.
-- It will not catch the error, because the `Computed` handles the error.
local result = Safe {
	try = function()
		scope:Computed(function()
			error("Kaboom!")
		end)
		return "success"
	end,
	fallback = function(err)
		return "fail"
	end
}

print(result) --> success
```

You must move the `Safe` closer to the source of the error, as discussed before.

```Lua
-- The `Safe` and the the `Computed` have swapped places.
-- The error is now caught by the `Safe` instead of the `Computed`.
local result = scope:Computed(function()
	return Safe {
		try = function()
			error("Kaboom!")
			return "success"
		end,
		fallback = function(err)
			return "fail"
		end
	}
end)

print(peek(result)) --> fail
```