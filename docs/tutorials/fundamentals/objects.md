In Fusion, you will create a lot of objects. These objects will need to be
destroyed when you are done with them.

Fusion introduces a few coding conventions that makes working with a large 
quantity of objects a lot easier. You're learning these coding conventions now,
before you learn about Fusion's features, because it's used throughout Fusion
and is very important.

-----

## Scopes

When you create a bunch of objects at the same time, you will often want to 
`:destroy()` them later at the same time, too. To make this easier, you can add
your objects to an array. Arrays that group together objects like this are given
a special name: *scopes*.

To create a new scope, create an empty array. This array will hold your objects.

```Lua linenums="2" hl_lines="3"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
```

Later, when you create objects, they will ask you to provide a scope as the
first argument.

```Lua linenums="2" hl_lines="4"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing = Fusion.Value(scope, "i am a thing")
```

When you create an object in Fusion like this, it will add itself to the scope.

```Lua linenums="2" hl_lines="6"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing = Fusion.Value(scope, "i am a thing")

print(scope[1] == thing) --> true
```

You can repeat this as many times as you like. Objects are added in the order
they are created.

```Lua linenums="2" hl_lines="4-10"
local Fusion = require(ReplicatedStorage.Fusion)

local scope = {}
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

print(scope[1] == thing1) --> true
print(scope[2] == thing2) --> true
print(scope[3] == thing3) --> true
```

Later on, you can destroy the scope by using the `doCleanup()` function. That
will destroy all the objects you added to it.

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

Scopes passed to `doCleanup` can have any of the following:

- Objects with `:destroy()` or `:Destroy()` methods to be called
- Functions to be run
- Roblox instances to destroy
- Roblox event connections to disconnect
- Other nested scopes to be cleaned up

That's all there is to scopes. They are nothing more than arrays of objects
which eventually get passed to a cleanup function.

-----

## Improved Syntax

While the above way of writing scopes is good for learning, Fusion also provides
more convenient shorthand that makes writing them out easier.

The first change is to use `scoped()` to make our scope, instead of creating an
array normally. It asks for a table argument, which we'll leave empty for now.

```Lua linenums="2" hl_lines="2 4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped({})
local thing1 = Fusion.Value(scope, "i am thing 1")
local thing2 = Fusion.Value(scope, "i am thing 2")
local thing3 = Fusion.Value(scope, "i am thing 3")

doCleanup(scope)
```

`scoped()` will return an array, just like the one we created ourselves.
However, we can now upgrade it with Fusion's syntax.

Whenever we have a function that takes `scope` as the first argument, we can add
it to the table argument of `scoped()`.

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

Now, we can use that function as a method on `scope`, like this:

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

This makes your code shorter, cleaner and more consistent. When you write code
in this way, you no longer have to refer to the full function name, and it's
easier to copy and paste around without making mistakes.

As a nice shorthand, you can pass in `Fusion` directly to `scoped()` rather than
listing out all the functions you want manually. Because `Fusion` is already a
table full of functions for creating things, it works too.

```Lua linenums="2" hl_lines="4"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped(Fusion)
local thing1 = scope:Value("i am thing 1")
local thing2 = scope:Value("i am thing 2")
local thing3 = scope:Value("i am thing 3")

doCleanup(scope)
```

Remember - this is just a nicer syntax for exactly the same thing we were doing
before.

From now on, you'll see this `scoped()` syntax used throughout the tutorials.