In Fusion, you create a lot of objects. These objects need to be destroyed when
you're done with them.

Fusion has some coding conventions to make large quantities of objects easier to
manage.

-----

## Scopes

When you create many objects at once, you often want to  `:destroy()` them
together later. 

To make this easier, some people add their objects to an array. Arrays that
group together objects like this are given a special name: *scopes*.

To create a new scope, create an empty array.

```Lua linenums="2" hl_lines="3"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
```

Later, when you create objects, they will ask for a scope as the first argument.

```Lua linenums="2" hl_lines="4"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing = Fusion.Value(scope, "i am a thing")
```

That object will add itself to the scope.

```Lua linenums="2" hl_lines="6"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing = Fusion.Value(scope, "i am a thing")

print(scope[1] == thing) --> true
```

Repeat as many times as you like. Objects appear in order of creation.

```Lua linenums="2"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

print(scope[1] == thing1) --> true
print(scope[2] == thing2) --> true
print(scope[3] == thing3) --> true
```

Later, destroy the scope by using the `doCleanup()` function. The contents are
destroyed in reverse order.

```Lua linenums="2" hl_lines="2 9"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup = Fusion.doCleanup

local scope = {}
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

doCleanup(scope)
-- Using `doCleanup` is the same as:
-- thing3:destroy()
-- thing2:destroy()
-- thing1:destroy()
```

Scopes passed to `doCleanup` can contain:

- Objects with `:destroy()` or `:Destroy()` methods to be called
- Functions to be run
- Roblox instances to destroy
- Roblox event connections to disconnect
- Other nested scopes to be cleaned up

You can add these manually using `table.insert` if you need custom behaviour,
or if you are working with objects that don't add themselves to scopes.

That's all there is to scopes. They are arrays of objects which later get passed
to a cleanup function.

-----

## Improved Syntax

Fusion provides better shorthand for scopes to improve readability and
maintainability.

To use shorthand, use `scoped({})` to create your scopes. By default this still
creates a normal empty array.

```Lua linenums="2" hl_lines="2 4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped({})
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

doCleanup(scope)
```

`scoped` can extend the array with custom methods. This is used primarily for
constructors.

Specify them in the table argument:

```Lua linenums="2" hl_lines="4-6"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped({
	Value = Fusion.Value
})
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

doCleanup(scope)
```

You can now rewrite those constructors as method calls.

```Lua linenums="2" hl_lines="7-9"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped({
	Value = Fusion.Value
})
local thing1 = scope:Value("i am thing 1")
local thing2 = scope:Value("i am thing 2")
local thing3 = scope:Value("i am thing 3")

doCleanup(scope)
```

This makes code shorter, cleaner and consistent. You import fewer things, names
are consistently positioned and more visually parseable, and it is easier to
move and copy code.

Try passing `Fusion` to `scoped()` rather than listing functions manually. 
Because `Fusion` already contains those functions, it works too.

```Lua linenums="2" hl_lines="4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped(Fusion)
local thing1 = scope:Value("i am thing 1")
local thing2 = scope:Value("i am thing 2")
local thing3 = scope:Value("i am thing 3")

doCleanup(scope)
```

Remember: this is only nicer syntax for exactly the same thing you did before.

From now on, you'll see this `scoped()` syntax used throughout the tutorials.