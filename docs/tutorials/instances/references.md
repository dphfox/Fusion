The `[Ref]` key allows you to save a reference to an instance you're hydrating
or creating.

```Lua
local myRef = Value()

local thing = New "Part" {
    [Ref] = myRef
}

print(myRef:get()) --> Part
print(myRef:get() == thing) --> true
```

-----

## Usage

To use `Ref` in your code, you first need to import it from the Fusion module,
so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Ref = Fusion.Ref
```

When using `New` or `Hydrate`, you can use `[Ref]` as a key in the property
table. It expects a value object to be passed in, and it will save a reference
to the instance in that object:

```Lua
local myRef = Value()

New "Part" {
    [Ref] = myRef
}

print(myRef:get()) --> Part
```

When the instance is cleaned up, the value object is set to nil to avoid memory
leaks:

```Lua
local myPart = Value()

New "Part" {
    [Ref] = myPart
}

print(myPart:get()) --> Part

myPart:get():Destroy()

print(myPart:get()) --> nil
```

-----

## When To Use This

You may have noticed that `New` and `Hydrate` already return their instances.
You might wonder why there's two ways to get the same instance reference:

```Lua
local fromRef = Value()
local returned = New "Part" {
    [Ref] = fromRef
}

print(returned) --> Part
print(fromRef:get()) --> Part

print(returned == fromRef:get()) --> true
```

There are two main use cases. Firstly, when you're using `[Children]` to nest
instances inside each other, it's hard to access the instance reference:

```Lua
local folders = New "Folder" {
    [Children] = New "Folder" {
        -- the instance reference gets passed straight into [Children]
        -- so... how do you save this somewhere else?
        [Children] = New "Part" {}
    }
}
```

One solution is to extract the `New` call out to a separate variable. This is
the simplest solution, but because the part is separated from the folders, it's
harder to see they're related at a glance:

```Lua
-- build the part elsewhere, so it can be saved to a variable
local myPart = New "Part" {}

local folders = New "Folder" {
    [Children] = New "Folder" {
        -- use the saved reference
        [Children] = myPart
    }
}
```

`Ref` allows you to save the reference without moving the `New` call:

```Lua
-- use a Value instead of a plain variable, so it can be passed to `Ref`
local myPart = Value()

local folders = New "Folder" {
    [Children] = New "Folder" {
        [Children] = New "Part" {
            -- save a reference into the value object
            [Ref] = myPart
        }
    }
}
```

The second use case arises when one instance needs to refer to another. Since
`Ref` saves to a value object, you can pass the object directly into another
`New` or `Hydrate` call:

```Lua
local myPart = Value()

New "SelectionBox" {
    -- the selection box should adorn to the part
    Adornee = myPart
}

New "Part" {
    -- saving a reference to `myPart`, which will change the Adornee prop above
    [Ref] = myPart
}
```

These aren't the only use cases for `Ref`, but they're the most common patterns
which are worth covering.