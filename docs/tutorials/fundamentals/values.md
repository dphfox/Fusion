Values are objects which store single values. You can read from them with
`:get()`, and write to them with `:set()`.

```Lua
local health = Value(100)

print(health:get()) --> 100
health:set(25)
print(health:get()) --> 25
```

-----

## Usage

To use `Value` in your code, you first need to import it from the Fusion module,
so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Value = Fusion.Value
```

To create a new value, call the `Value` function:

```Lua
local health = Value() -- this will create and return a new Value object
```

By default, new `Value` objects store `nil`. If you want the `Value` object to
start with a different value, you can provide one:

```Lua
local health = Value(100) -- the Value will initially store a value of 100
```

You can retrieve the currently stored value at any time with `:get()`:

```Lua
print(health:get()) --> 100
```

You can also set the stored value at any time with `:set()`:

```Lua
health:set(25)
print(health:get()) --> 25
```

-----

## Why Objects?

### The Problem

Imagine some UI in your head. Think about what it looks like, and think about
the different variables it's showing to you.

<figure markdown>
![An example of a game's UI, with some variables labelled and linked to parts of the UI.](Game-UI-Variables-Light.svg#only-light)
![An example of a game's UI, with some variables labelled and linked to parts of the UI.](Game-UI-Variables-Dark.svg#only-dark)
<figcaption>Screenshot: GameUIDatabase (Halo Infinite)</figcaption>
</figure>

Your UIs are usually driven by a few internal variables. When those variables
change, you want your UI to reflect those changes.

Unfortunately, there's no way to listen for those changes in Lua. When you
change those variables, it's normally *your* responsibility to figure out what
needs to update, and to send out those updates.

Over time, we've come up with many methods of dealing with this inconvenience.
Perhaps the simplest are 'setter functions', like these:

```Lua
local ammo = 100

local function setAmmo(newAmmo)
	ammo = newAmmo
	-- you need to send out updates to every piece of code using `ammo` here
	updateHUD()
	updateGunModel()
	sendAmmoToServer()
end
```

But this is clunky and unreliable; what if there's another piece of code using
`ammo` that we've forgotten to update here? How can you guarantee we've covered
everything? Moreover, why is the code setting the `ammo` even concerned with who
uses it?

### Building Better Variables

In an ideal world, anyone using `ammo` should be able to listen for changes, and
get notified when someone sets it to a new value.

To make this work, we need to fundamentally extend what variables can do. In
particular, we need two additional features:

- We need to save a list of *dependents* - other places currently using our
variable. This is so we know who to notify when the value changes.
- We need to run some code when the variable is set to a new value. If we can
do that, then we can go through the list and notify everyone.

To solve this, Fusion introduces the idea of a 'state object'. These are objects
that represent a single value, which you can `:get()` at any time. They also
keep a list of dependents; when the object's value changes, it can notify
everyone so they can respond to the change.

`Value` is one such state object. It's specifically designed to act like a
variable, so it has an extra `:set()` method. Using that method, you can change
the object's value manually. If you set it to a different value than before,
it'll notify anyone using the object.

This means you can use `Value` objects like variables, with the added benefit of
being able to listen to changes like we wanted!

### Sharing Variables

There is another benefit to using objects too; you can easily share your objects
directly with other code. Every usage of that object will refer to the
same underlying value:

```Lua
-- someObject is a `Value` object
local function printValue(someObject)
	print(someObject:get())
end

local health = Value(100)
printValue(health) --> 100

local myDogsName = Value("Dan")
printValue(myDogsName) --> Dan
```

This is something that normal variables can't do by default, and is a benefit
exclusive to state objects.

In the above code, `printValue` can operate on *any* arbitrary variable without
knowing what it is, or where it comes from. This is very useful for writing
generic, reusable code, and you'll see it used a lot throughout Fusion.