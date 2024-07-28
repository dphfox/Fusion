At some point, you might need to refer to another part of the UI. There are
various techniques that can let you do this.

```Lua hl_lines="5"
local ui = scope:New "Folder" {
	[Children] = {
		scope:New "SelectionBox" {
			-- the box should adorn to the part, but how do you reference it?
			Adornee = ???,
		},
		scope:New "Part" {
			Name = "Selection Target",
		}
	}
}
```

-----

## Constants

The first technique is simple - instead of creating the UI all at once, you can
extract part of the UI that you want to reference later.

In practice, that means you'll move some of the creation code into a new `local`
constant, so that you can refer to it later by name.

```Lua
-- the part is now constructed first, whereas before it was constructed second
local selectionTarget = scope:New "Part" {
	Name = "Selection Target",
}

local ui = scope:New "Folder" {
	[Children] = {
		scope:New "SelectionBox" {
			Adornee = selectionTarget
		},
		selectionTarget
	}
}
```

While this is a simple and robust technique, it has some disadvantages:

- By moving parts of your UI code into different local variables, your UI will
be constructed in a different order based on which local variables come first
- Refactoring code in this way can be bothersome and inelegant, disrupting the
structure of the code
- You can't have two pieces of UI refer to each other cyclically

Constants work well for trivial examples, but you should consider a more
flexible technique if those disadvantages are relevant.

-----

## Value Objects

Where it's impossible or inelegant to use named constants, you can use
[value objects](../../fundamentals/values) to easily set up references.

Because their `:set()` method returns the value that's passed in, you can use
`:set()` to reference part of your code without disrupting its structure:

```Lua
-- `selectionTarget` will show as `nil` to all code trying to use it, until the
-- `:set()` method is called later on.
local selectionTarget: Fusion.Value<Part?> = scope:Value(nil)

local ui = scope:New "Folder" {
	[Children] = {
		scope:New "SelectionBox" {
			Adornee = selectionTarget
		},
		selectionTarget:set(
			scope:New "Part" {
				Name = "Selection Target",
			}
		)
	}
}
```

It's important to note that the value object will briefly be `nil` (or whichever
default value you provide in the constructor). This is because it takes time to
reach the `:set()` call, so any in-between code will see the `nil`.

In the above example, the `Adornee` is briefly set to `nil`, but because
`selectionTarget` is a value object, it will change to the part instance when
the `:set()` method is called.

While dealing with the brief `nil` value can be annoying, it is also useful,
because this lets you refer to parts of your UI that haven't yet been created.
In particular, this lets you create cyclic references.

```Lua
local aliceRef: Fusion.Value<Instance?> = scope:Value(nil)
local bobRef: Fusion.Value<Instance?> = scope:Value(nil)

-- These two `ObjectValue` instances will refer to each other once the code has
-- finished running.
local alice = aliceRef:set(
	scope:New "ObjectValue" {
		Value = bobRef
	}
)
local bob = bobRef:set(
	scope:New "ObjectValue" {
		Value = aliceRef
	}
)
```

Value objects are generally easier to work with than named constants, so they're
often used as the primary way of referencing UI, but feel free to mix both
techniques based on what your code needs.