In Fusion, you create a lot of objects. These objects need to be destroyed when
you're done with them.

Fusion has some coding conventions to make large quantities of objects easier to
manage.

-----

## Scopes

When you create many objects at once, you often want to destroy them together
later. 

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

That object will add its `destroy()` function to the scope:

```Lua linenums="2" hl_lines="6"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing = Fusion.Value(scope, "i am a thing")

print(scope[1]) --> function: 0x123456789abcdef
```

Repeat as many times as you like. Objects appear in order of creation.

```Lua linenums="2"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")
```

Later, destroy the scope by using the `doCleanup()` function. The contents are
destroyed in reverse order.

```Lua linenums="2" hl_lines="8"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

Fusion.doCleanup(scope)
-- Using `doCleanup` is conceptually the same as:
-- thing3:destroy()
-- thing2:destroy()
-- thing1:destroy()
```

Scopes passed to `doCleanup` can contain:

- Functions to be run (like those `destroy()` functions above)
- Roblox instances to destroy
- Roblox event connections to disconnect
- Your own objects with `:destroy()` or `:Destroy()` methods to be called
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
local scoped = Fusion.scoped

local scope = scoped()
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

Fusion.doCleanup(scope)
```

Unlike `{}` (which always creates a new array), `scoped` can re-use old arrays.
This helps keep your program running smoothly.

Beyond making your code more efficient, you can also use `scoped` for convenient
syntax.

You can pass a table of functions into `scoped`:

```Lua linenums="2" hl_lines="4-7"
local Fusion = require(ReplicatedStorage.Fusion)
local scoped = Fusion.scoped

local scope = scoped({
	Value = Fusion.Value,
	doCleanup = Fusion.doCleanup
})
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

Fusion.doCleanup(scope)
```

If those functions take `scope` as their first argument, you can use them as
methods directly on the scope:

```Lua linenums="2" hl_lines="8-10 12"
local Fusion = require(ReplicatedStorage.Fusion)
local scoped = Fusion.scoped

local scope = scoped({
	Value = Fusion.Value,
	doCleanup = Fusion.doCleanup
})
local thing1 = scope:Value("i am thing 1")
local thing2 = scope:Value("i am thing 2")
local thing3 = scope:Value("i am thing 3")

scope:doCleanup()
```

This makes it harder to mess up writing scopes. Your code reads more naturally,
too.

### Adding Methods In Bulk

Try passing `Fusion` to `scoped()` - it's a table with functions, too.

```Lua hl_lines="1"
local scope = scoped(Fusion)

-- all still works!
local thing1 = scope:Value("i am thing 1")
local thing2 = scope:Value("i am thing 2")
local thing3 = scope:Value("i am thing 3")

scope:doCleanup()
```

This gives you access to all of Fusion's functions without having to import
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

-- `bar` should have the same methods as `foo`
-- it'd be nice to define this once only...
local bar = scoped({
	Foo = Foo,
	Bar = Bar,
	Baz = Baz
})

print(foo.Baz == bar.Baz) --> true

bar:doCleanup()
foo:doCleanup()
```

To do this, Fusion provides a `deriveScope` function. It behaves like `scoped`
but lets you skip defining the methods. Instead, you give it an example of what
the scope should look like.

```Lua hl_lines="9"
local foo = scoped({
	Foo = Foo,
	Bar = Bar,
	Baz = Baz
})

-- `bar` should have the same methods as `foo`
-- now, it's only defined once!
local bar = foo:deriveScope()

print(foo.Baz == bar.Baz) --> true

bar:doCleanup()
foo:doCleanup()
```

*Deriving* scopes like this is highly efficient because Fusion can re-use the
same information for both scopes. It also helps keep your definitions all in
one place.

You can also add more method tables if you'd like to.

```Lua hl_lines="9"
local foo = scoped({
	Foo = Foo,
	Bar = Bar,
	Baz = Baz
})

-- `bar` should have the same methods as `foo`
-- now, it's only defined once!
local bar = foo:deriveScope({
	Garb = Garb
})

print(bar.Garb) --> function: 0x123456789abcdef
print(foo.Garb) --> nil
```

### Inner Scopes

The main reason you would want to create a new scope is to create things that
get destroyed at different times.

For example, imagine you're creating a dropdown menu. You create a new scope for
the menu, which you clean up when the menu is closed.

```Lua
local uiScope = scoped(Fusion)

-- ... create the ui ...

table.insert(
	uiScope,
	dropdownOpened:Connect(function()
		local dropdownScope = uiScope:deriveScope()

		-- ... create the dropdown ...

		table.insert(
			dropdownScope,
			dropdownClosed:Connect(function()
				dropdownScope:doCleanup()
			end)
		)
	end)
)
```

This ordinarily works just fine; when the dropdown is opened, the new scope is
created, and when the dropdown is closed, the new scope is destroyed.

However, what if the UI gets cleaned up while the dropdown is open? The
`uiScope` will get cleaned up, but the `dropdownScope` will not.

To help with this, Fusion provides an `innerScope` method. It works just like
`deriveScope`, but it adds in extra logic:

- When the original scope is cleaned up, the 'inner scope' is cleaned up too
- You can still call `doCleanup()` to clean the inner scope up early

```Lua hl_lines="8"
local uiScope = scoped(Fusion)

-- ... create the ui ...

table.insert(
	uiScope,
	dropdownOpened:Connect(function()
		local dropdownScope = uiScope:innerScope()

		-- ... create the dropdown ...

		table.insert(
			dropdownScope,
			dropdownClosed:Connect(function()
				dropdownScope:doCleanup()
			end)
		)
	end)
)
```

Now, the dropdown scope is guaranteed to be cleaned up if the UI it came from is
cleaned up. This strictly limits how long the dropdown can exist for.

Inner scopes are often the safest choice for creating new scopes. They let you
call `doCleanup` whenever you like, but guarantee that they won't stick around
beyond the rest of the code they're in.

-----

## When You'll Use This

Scopes might sound like a lot of upfront work. However, you'll find in practice
that Fusion manages a lot of this for you, and it makes your code much more
resilient to memory leaks and other kinds of memory management issues.

You'll need to create and destroy your own scopes manually sometimes. For
example, you'll need to create a scope in your main code file to start using
Fusion, and you might want to make a few more in other parts of your code.

However, Fusion manages most of your scopes for you, so for large parts of your
codebase, you won't have to consider scopes and destruction at all.