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

!!! success "This syntax is recommended"
	It is recommended to use this syntax. However, it is technically optional;
	if it does not fit your technical requirements, the barebones syntax will
	always be available.

	From now on, you'll see this syntax used throughout the tutorials.

Fusion provides alternate syntax for scopes, which improves readability and
maintainability.

To use this syntax, call `scoped()` to create your scopes. This creates a normal
empty array.

```Lua linenums="2" hl_lines="2 4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped()
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

doCleanup(scope)
```

`scoped` can then add methods to that array for you. This is most useful for
constructor functions.

Name some constructors in a table, and pass it to `scoped()`.

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

You can now rewrite those constructors as method calls. The `scope` argument is
inferred for you.

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

This strongly ties your constructors to your scopes, which makes it much harder
to mess up or circumvent them. It also makes code read much more naturally.

### Adding Methods In Bulk

Try passing `Fusion` to `scoped()` rather than listing functions manually. 
Because `Fusion` is a table containing functions, it works too.

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

You can merge in as many extras as you'd like by adding them as arguments.

```Lua hl_lines="4"
local LibraryA = { foo = ..., bar = ... }
local LibraryB = { frob = ..., garb = ... }

local scope = scoped(Fusion, LibraryA, LibraryB)

print(scope.Value == Fusion.Value) --> true
print(scope.foo == LibraryA.foo) --> true
print(scope.garb == LibraryB.garb) --> true

```

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
that Fusion manages most of this for you.

You'll only ever have to manage scopes when you're creating and destroying them
directly. For example, you'll likely deal with them in your main code file,
where you need to create a scope directly in order to start using Fusion.

However, Fusion manages most of your scopes for you. As you'll see, parts of
Fusion will often give you an automatically-created scope. In those cases,
Fusion takes responsibility for managing them, so you can use them without
thinking about how they work.