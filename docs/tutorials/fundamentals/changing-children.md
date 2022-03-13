!!! warning "Under construction"
	This page is under construction - information may be incomplete or missing.


-----

## Passing State To Children

!!! note "Stub"
	This section is a stub - it may require more detail added to it in future.

Previously, we found that we could pass state objects as properties to bind them:

```Lua
local message = State("Hello")

local gui = New "TextLabel" {
	Text = message
}

message:set("World") -- sets Text to World
```

The same principle works for `[Children]` - you can pass in a state object
containing any children you'd like to add, and they'll be bound similarly:

```Lua
local child = State(New "Folder" {})

local gui = New "TextLabel" {
	[Children] = child
}

child:set(New "ScreenGui") -- changes the child from the folder to the screen gui

```

```Lua
local child1 = New "Folder" {}
local child2 = New "Folder" {}
local child3 = New "Folder" {}

local children = State({child1, child2})

local gui = New "TextLabel" {
	[Children] = children
}

children:set({child2, child3}) -- unparents child1, parents child2

```

Note that when a child is removed like this, it is only unparented, not destroyed.
Make sure to destroy any instances you remove if you're not using a helper like
ComputedPairs.

-----

## Deferred Updates

!!! note "Stub"
	This section is a stub - it may require more detail added to it in future.

Changes to bound children are deferred until the next render step, just like
changes to bound properties.
