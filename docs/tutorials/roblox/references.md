The `[Ref]` key allows you to save a reference to an instance you're hydrating
or creating.

```Lua
local myRef = scope:Value()

local thing = scope:New "Part" {
    [Ref] = myRef
}

print(peek(myRef)) --> Part
print(peek(myRef) == thing) --> true
```

-----

## Usage

`Ref` doesn't need a scope - import it into your code from Fusion directly.

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Ref = Fusion.Ref
```

When creating an instance with `New`, `[Ref]` will save that instance to a value
object.

```Lua
local myRef = scope:Value()

scope:New "Part" {
    [Ref] = myRef
}

print(peek(myRef)) --> Part
```

Among other things, this allows you to refer to instances from other instances.

```Lua
local myPart = scope:Value()

New "SelectionBox" {
    -- the selection box should adorn to the part
    Adornee = myPart
}

New "Part" {
	-- sets `myPart` to this part, which sets the adornee to this part
    [Ref] = myPart
}
```

You can also get references to instances from deep inside function calls.

```Lua
-- this will refer to the part, once we create it
local myPart = scope:Value()

scope:New "Folder" {
    [Children] = scope:New "Folder" {
        [Children] = scope:New "Part" {
            -- save a reference into the value object
            [Ref] = myPart
        }
    }
}
```

!!! warning "Nil hazard"
	Before the part is created, the `myPart` value object will be `nil`. Be
	careful not to use it before it's created.

	If you need to know about the instance ahead of time, you should create the
	instance early, and parent it in later, when you create the rest of the
	instances.

	```Lua
	-- build the part elsewhere, so it can be saved to a variable
	local myPart = scope:New "Part" {}

	local folders = scope:New "Folder" {
		[Children] = scope:New "Folder" {
			-- parent the part into the folder here
			[Children] = myPart
		}
	}
	```