```Lua
local Children: Symbol
```

The symbol used to denote the children of an instance when working with the
[New](../new) function.

When using this symbol as a key in `New`'s property table, the values will be
treated as children, and parented according to the rules below.

-----

## Example Usage

```Lua
local example = New "Folder" {
	[Children] = New "StringValue" {
		Value = "I'm parented to the Folder!"
	}
}
```

-----

## Processing Children

A 'child' is defined (recursively) as:

- an instance
- a [state object](../state) or [computed object](../computed) containing children
- an array of children

Since this definition is recursive, arrays and state objects can be nested; that
is, the following code is valid:

```Lua
local example = New "Folder" {
	[Children] = {
		{
			{
				New "StringValue" {
					Value = "I'm parented to the Folder!"
				}
			}
		}
	}
}
```

This behaviour is especially useful when working with components - the following
component can return multiple instances to be parented without disrupting the
code next to it:

```Lua
local function Component(props)
	return {
		New "TextLabel" {
			LayoutOrder = 1,
			Text = "Instance one"
		},

		New "TextLabel" {
			LayoutOrder = 2,
			Text = "Instance two"
		}
	}
end

local parent = New "Frame" {
	Children = {
		New "UIListLayout" {
			SortOrder = "LayoutOrder"
		},

		Component {}
	}
}
```

When using a state or computed object as a child, it will be bound; when the
value of the state object changes, it'll unparent the old children and parent
the new children.

!!! note
	As with bound properties, updates are deferred to the next render step, and
	so parenting won't occur right away.

```Lua
local child1 = New "Folder" {
	Name = "Child one"
}
local child2 = New "Folder" {
	Name = "Child two"
}

local childState = State(child1)

local parent = New "Folder" {
	[Children] = childState
}

print(parent:GetChildren()) -- { Child one }

childState:set(child2)
wait(1) -- wait for deferred updates to run

print(parent:GetChildren()) -- { Child two }
```

!!! warning
	When using state objects, note that old children *won't* be destroyed, only
	unparented - it's up to you to decide if/when children need to be destroyed.

	If you're using a helper like [ComputedPairs](../computedpairs), instance
	cleanup is handled for you by default (though this is configurable).