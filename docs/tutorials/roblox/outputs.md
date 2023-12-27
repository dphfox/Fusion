`Out` is a function that returns keys to use when hydrating or creating an
instance. Those keys let you output a property's value to a `Value` object.

```Lua
local name = scope:Value()

local thing = scope:New "Part" {
    [Out "Name"] = name
}

print(peek(name)) --> Part

thing.Name = "Jimmy"
print(peek(name)) --> Jimmy
```

-----

## Usage

`Out` doesn't need a scope - import it into your code from Fusion directly.

```Lua
local Out = Fusion.Out
```

When you call `Out` with a property name, it will return a special key:

```Lua
local key = Out("Activated")
```

When used in a property table, you can pass in a `Value` object. It will be set
to the value of the property, and when the property changes, it will be set to
the new value:

```Lua
local name = scope:Value()

local thing = scope:New "Part" {
    [Out("Name")] = name
}

print(peek(name)) --> Part

thing.Name = "Jimmy"
print(peek(name)) --> Jimmy
```

If you're using quotes `'' ""` for the event name, the extra parentheses `()`
are optional:

```Lua
local thing = scope:New "Part" {
    [Out "Name"] = name
}
```

-----

## Two-Way Binding

By default, `Out` only *outputs* changes to the property. If you set the value
to something else, the property remains the same:

```Lua
local name = scope:Value()

local thing = scope:New "Part" {
    [Out "Name"] = name -- When `thing.Name` changes, set `name`
}

print(thing.Name, peek(name)) --> Part Part
name:set("NewName")
task.wait()
print(thing.Name, peek(name)) --> Part NewName
```

If you want the value to both *change* and *be changed* by the property, you
need to explicitly say so:

```Lua hl_lines="4 11"
local name = scope:Value()

local thing = scope:New "Part" {
    Name = name -- When `name` changes, set `thing.Name`
    [Out "Name"] = name -- When `thing.Name` changes, set `name`
}

print(thing.Name, peek(name)) --> Part Part
name:set("NewName")
task.wait()
print(thing.Name, peek(name)) --> NewName NewName
```

This is known as two-way binding. Most of the time you won't need it, but it can
come in handy when working with some kinds of UI - for example, a text box that
users can write into, but which can also be modified by your scripts.