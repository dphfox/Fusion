<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-key-24:</span>
	<span class="fusiondoc-api-name">Children</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">special key</span>
		<span class="fusiondoc-api-pill-since">since v0.1</span>
	</span>
</h1>

Allows parenting children to an instance, both statically and dynamically.

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
- a [state object](../../state/stateobject) containing children
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

When using a state object as a child, `Children` will interpret the stored value
as children and watch for changes. When the value of the state object changes,
it'll unparent the old children and parent the new children.

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

	If you're using a helper like [ForValues](../../state/forvalues), instance
	cleanup is handled for you by default (though this is configurable).

-----

## Technical Details

This special key runs at the `descendants` stage.

On cleanup, all children are unparented, as if wrapped in a state object that
has changed to nil.