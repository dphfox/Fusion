Sometimes values are used in far-away parts of the codebase. For example, many
UI elements might share theme colours for light and dark theme.

-----

## Globals

Typically, values are shared by placing them in modules. These modules can be
required from anywhere in the codebase, and their values can be imported into
any code.

Values shared in this way are known as *globals*.

=== "Theme.luau"

	```Lua linenums="1"
	local Theme = {}

	Theme.colours = {
		background = Color3.fromHex("FFFFFF"),
		text = Color3.fromHex("222222"),
		-- etc.
	}

	return Theme
	```

=== "Somewhere else"

	```Lua linenums="1"
	local Theme = require("path/to/Theme.luau")

	local textColour = Theme.colours.text
	print(textColour) --> 34, 34, 34
	```

In particular, you can share state objects this way, and every part of the
codebase will be able to see and interact with those state objects.

=== "Theme.luau"

	```Lua linenums="1"
	local Fusion = require("path/to/Fusion.luau")

	local Theme = {}

	Theme.colours = {
		background = {
			light = Color3.fromHex("FFFFFF"),
			dark = Color3.fromHex("222222")
		},
		text = {
			light = Color3.fromHex("FFFFFF"),
			dark = Color3.fromHex("222222")
		},
		-- etc.
	}

	function Theme.init(
		scope: Fusion.Scope<typeof(Fusion)>
	)
		Theme.currentTheme = scope:Value("light")
	end

	return Theme
	```

=== "Somewhere else"

	```Lua linenums="1"
	local Fusion = require("path/to/Fusion.luau")
	local scoped, peek = Fusion.scoped, Fusion.peek

	local Theme = require("path/to/Theme.luau")

	local function printTheme()
		local theme = Theme.currentTheme
		print(
			peek(theme), 
			if typeof(theme) == "string" then "constant" else "state object"
		)
	end

	local scope = scoped(Fusion)
	Theme.init(scope)
	printTheme() --> light state object

	Theme.currentTheme:set("dark")
	printTheme() --> dark state object
	```

Globals are very straightforward to implement and can be useful, but they can
quickly cause problems if not used carefully.

### Hidden dependencies

When you use a global inside a block of reusable code such as a component, you
are making your code dependent on another code file without declaring it to the
outside world.

To some extent, this is entirely why using globals is desirable. While it's more
'correct' to accept the `Theme` via the parameters of your function, it often
means the `Theme` has to be passed down through multiple layers of functions.
This is known as [prop drilling](https://kentcdodds.com/blog/prop-drilling) and
is widely considered bad practice, because it clutters up unrelated code with
parameters that are only passed through functions.

To avoid prop drilling, globals are often used, which 'hides' the dependency on
that external code file. You no longer have to pass it down through parameters.
However, relying too heavily on these hidden dependencies can cause your code to
behave in surprising, unintuitive ways, or it can obscure what functionality is
available to developers using your code.

### Hard-to-locate writes

If you write into globals from deep inside your code base, it becomes very hard
to figure out where the global is being changed from, which significantly hurts
debugging.

Generally, it's best to treat globals as *read-only*. If you're writing to a
global, it should be coming from a single well-signposted, easy-to-find place.

You should also keep the principles of [top-down control](../callbacks) in mind;
think of globals as 'flowing down' from the root of the program. Globals are
best managed from high up in the program, because they have widespread effects,
so consider using callbacks to pass control up the chain, rather than managing
globals directly from every part of the code base.

### Memory management

In addition, globals can complicate memory management. Because every part of
your code base can access them, you can't destroy globals until the very end of
your program.

In the above example, this is solved with an `init()` method which passes the
main scope to `Theme`. Because `init()` is called before anything else that uses
`Theme`, the objects that `Theme` creates will be added to the scope first.

When the main scope is cleaned up, `doCleanup()` will destroy things in reverse
order. This means the `Theme` objects will be cleaned up last, after everything
else in the program has been cleaned up.

This only works if you know that the main script is the only entry point in your
program. If you have two scripts running concurrently which try to `init()` the
`Theme` module, they will overwrite each other.

### Non-replaceable for testing

When your code uses a global, you're hard-coding a connection between your code
and that specific global.

This is problematic for testing; unless you're using an advanced testing
framework with code injection, it's pretty much impossible to separate your code
from that global code, which makes it impossible to replace global values for
testing purposes.

For example, if you wanted to write automated tests that verify light theme and
dark theme are correctly applied throughout your UI, you can't replace any
values stored in `Theme`.

You might be able to write to the `Theme` by going through the normal process,
but this fundamentally limits how you can test. For example, you couldn't run a
test for light theme and dark theme at the same time.

-----

## Contextuals

The main drawback of globals is that they hold one value for all code. To solve
this, Fusion introduces *contextual values*, which can be temporarily changed
for the duration of a code block.

To create a contextual, call the `Contextual` function from Fusion. It asks for
a default value.

```Lua
local myContextual = Contextual("foo")
```

At any time, you can query its current value using the `:now()` method.

```Lua
local myContextual = Contextual("foo")
print(myContextual:now()) --> foo
```

You can override the value for a limited span of time using `:is():during()`.
Pass the temporary value to `:is()`, and pass a callback to `:during()`.

While the callback is running, the contextual will adopt the temporary value.

```Lua
local myContextual = Contextual("foo")
print(myContextual:now()) --> foo

myContextual:is("bar"):during(function()
	print(myContextual:now()) --> bar
end)

print(myContextual:now()) --> foo
```

By storing widely-used values inside contextuals, you can isolate different
code paths from each other, while retaining the easy, hidden referencing that
globals offer. This makes testing and memory management significantly easier,
and helps you locate which code is modifying any shared values.

To demonstrate, the `Theme` example can be rewritten to use contextuals.

=== "Theme.luau"

	```Lua linenums="1"
	local Fusion = require("path/to/Fusion.luau")
	local Contextual = Fusion.Contextual

	local Theme = {}

	Theme.colours = {
		background = {
			light = Color3.fromHex("FFFFFF"),
			dark = Color3.fromHex("222222")
		},
		text = {
			light = Color3.fromHex("FFFFFF"),
			dark = Color3.fromHex("222222")
		},
		-- etc.
	}

	Theme.currentTheme = Contextual("light")

	return Theme
	```

=== "Somewhere else"

	```Lua linenums="1"
	local Fusion = require("path/to/Fusion.luau")
	local scoped, peek = Fusion.scoped, Fusion.peek

	local Theme = require("path/to/Theme.luau")

	local function printTheme()
		local theme = Theme.currentTheme:now()
		print(
			peek(theme), 
			if typeof(theme) == "string" then "constant" else "state object"
		)
	end

	printTheme() --> light constant

	local scope = scoped(Fusion)
	local override = scope:Value("light")
	Theme.currentTheme:is(override):during(function()
		printTheme()  --> light state object
		override:set("dark")
		printTheme() --> dark state object
	end)

	printTheme() --> light constant
	```

In this rewritten example, `Theme` no longer requires an `init()` function,
because - instead of defining a state object globally - `Theme` only defines
`"light"` as the default value.

You're expected to replace the default value with a state object when you want
to make the theme dynamic. This has a number of benefits:

- Because the override is time-limited to one span of your code, you can have
multiple scripts running at the same time with completely different overrides.

- It also explicitly places your code in charge of memory management, because
you're creating the object yourself.

- It's easy to locate where changes are coming from, because you can look for
the nearest `:is():during()` call. Optionally, you could share a limited, 
read-only version of the value, while retaining private access to write to the 
value wherever you're overriding the contextual from.

- Testing becomes much simpler; you can override the contextual for different
parts of your testing, without ever having to inject code, and without altering
how you read and override the contextual in your production code.

It's still possible to run into issues with contextuals, though.

- You're still hiding a dependency of your code, which can still lead to
confusion and obscuring available features, just the same as globals.
- Unlike globals, contextuals are time-limited. If you connect to an event or 
start a delayed task, you won't be able to access the value anymore. Instead,
capture the value at the start of the code block, so you can use it in delayed
tasks.