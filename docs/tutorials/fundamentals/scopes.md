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

## Improved Scopes

!!! success "This syntax is recommended"
	From now on, you'll see this syntax used throughout the tutorials.

Fusion can help manage your scopes for you. This unlocks convenient syntax, and
allows Fusion to optimise your code.

You can call `scoped()` to obtain a new scope.

```Lua linenums="2" hl_lines="2 4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped()
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

doCleanup(scope)
```

Unlike `{}` (which always creates a new array), `scoped` can re-use old arrays.
This helps keep your program running smoothly.

Beyond making your code more efficient, you can also use `scoped` for convenient
syntax.

You can pass a table of constructor functions into `scoped`:

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

You can now use those constructors as methods on `scope`.

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

This makes it harder to mess up writing scopes. Your code reads more naturally,
too.

### Adding Methods In Bulk

Try passing `Fusion` to `scoped()` - it's a table with functions.

```Lua linenums="2" hl_lines="4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped(Fusion)
local thing1 = scope:Value("i am thing 1")
local thing2 = scope:Value("i am thing 2")
local thing3 = scope:Value("i am thing 3")

doCleanup(scope)
```

This gives you access to all of Fusion's constructors without having to import
each one manually.

If you need to mix in other things, you can pass in another table.

```Lua
local scope = scoped(Fusion, {
	Foo = ...,
	Bar = ...
})
```

You can do this for as many tables as you need.

!!! fail "Conflicting names"
	If you pass in two tables that contain things with the same name, `scoped()`
	will error.

### Reusing Methods From Other Scopes

Sometimes, you'll want to make a new scope with the same methods as an existing
scope.

```Lua
local foo = scoped({
	Foo = Foo,
	Bar = Bar,
	Baz = Baz
})

-- it'd be nice to define this once only...
local bar = scoped({
	Foo = Foo,
	Bar = Bar,
	Baz = Baz
})
```

To do this, Fusion provides a `deriveScope` function. It behaves like `scoped`
but lets you skip defining the methods. Instead, you give it an example of what
the scope should look like.

```Lua linenums="2" hl_lines="2 11"
local Fusion = require(ReplicatedStorage.Fusion)
local scoped, deriveScope = Fusion.scoped, Fusion.deriveScope
local doCleanup = Fusion.doCleanup

local foo = scoped({
	Foo = Foo,
	Bar = Bar,
	Baz = Baz
})

local bar = deriveScope(foo)

doCleanup(bar)
doCleanup(foo)
```

*Deriving* scopes like this is highly efficient because Fusion can re-use the
same information for both scopes. It also helps keep your definitions all in
one place.

-----

## When You'll Use This

Scopes might sound like a lot of upfront work. However, you'll find in practice
that Fusion manages a lot of this for you.

You'll need to create and destroy your own scopes manually sometimes. For
example, you'll need to create a scope in your main code file to start using
Fusion, and you might want to make a few more in other parts of your code.

However, Fusion manages most of your scopes for you, so for large parts of your
codebase, you won't have to consider scopes and destruction at all.