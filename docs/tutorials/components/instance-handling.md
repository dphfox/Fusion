Components are a good fit for Roblox instances. You can assemble complex groups
of instances by combining simpler, self-contained parts.

To ensure maximum compatibility, there are a few best practices to consider.

-----

## Returns

Anything you return from a component should be supported by
[`[Children]`](../roblox/parenting.md).

```Lua
-- returns an instance
return scope:New "Frame" {}

-- returns an array of instances
return {
	scope:New "Frame" {},
	scope:New "Frame" {},
	scope:New "Frame" {}
}

-- returns a state object containing instances
return scope:ForValues({1, 2, 3}, function(use, scope, number)
	return scope:New "Frame" {}
end)

-- mix of arrays, instances and state objects
return {
	scope:New "Frame" {},
	{
		scope:New "Frame" {},
		scope:ForValues( ... )
	}
	scope:ForValues( ... )
}
```

!!! fail "Returning multiple values is fragile"
    Don't return multiple values directly from your function. When a function
    returns multiple values directly, the extra returned values can easily get
    lost.

    ```Lua
    local function BadThing(scope, props)
		-- returns *multiple* instances (not surrounded by curly braces!)
        return
            scope:New "Frame" {},
            scope:New "Frame" {},
            scope:New "Frame" {}
    end

    local things = {
        -- Luau doesn't let you add multiple returns to a list like this.
        -- Only the first Frame will be added.
        scope:BadThing {},
        scope:New "TextButton" {}
    }
    print(things) --> { Frame, TextButton }
    ```

    Instead, you should return them inside of an array. Because the array is a
    single return value, it won't get lost.

If your returns are compatible with `[Children]` like above, you can insert a
component anywhere you'd normally insert an instance.

You can pass in one component on its own...

```Lua hl_lines="2-4"
local ui = scope:New "ScreenGui" {
    [Children] = scope:Button {
        Text = "Hello, world!"
    }
}
```

...you can include components as part of an array..

```Lua hl_lines="5-7 9-11"
local ui = scope:New "ScreenGui" {
    [Children] = {
        scope:New "UIListLayout" {},

        scope:Button {
            Text = "Hello, world!"
        },

        scope:Button {
            Text = "Hello, again!"
        }
    }
}
```

...and you can return them from state objects, too.

```Lua hl_lines="8-10"
local stuff = {"Hello", "world", "from", "Fusion"}

local ui = scope:New "ScreenGui" {
    [Children] = {
        scope:New "UIListLayout" {},

        scope:ForValues(stuff, function(use, scope, text)
            return scope:Button {
                Text = text
            }
        end)
    }
}
```

-----

## Containers

Some components, for example pop-ups, might contain lots of different content:

![Examples of pop-ups with different content.](Popups-Dark.svg#only-dark)
![Examples of pop-ups with different content.](Popups-Light.svg#only-light)

Ideally, you would be able to reuse the pop-up 'container', while placing your
own content inside.

![Separating the pop-up container from the pop-up contents.](Popup-Exploded-Dark.svg#only-dark)
![Separating the pop-up container from the pop-up contents.](Popup-Exploded-Light.svg#only-light)

The simplest way to do this is to pass instances through to `[Children]`. For
example, if you accept a table of `props`, you can add a `[Children]` key:

```Lua hl_lines="4 8"
local function PopUp(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		[typeof(Children)]: Fusion.Children
	}
)
    return scope:New "Frame" {
        [Children] = props[Children]
    }
end
```

!!! tip "Accepting multiple instances"
	If you have multiple 'slots' where you want to pass through instances, you
	can make other properties and give them the `Fusion.Children` type.

Later on, when a pop-up is created, instances can now be parented into that
pop-up:

```Lua
scope:PopUp {
    [Children] = {
        scope:Label {
            Text = "New item collected"
        },
        scope:ItemPreview {
            Item = Items.BRICK
        },
        scope:Button {
            Text = "Add to inventory"
        }
    }
}
```

If you need to add other instances, you can still use arrays and state objects
as normal. You can include instances you're given, in exactly the same way you
would include any other instances.

```Lua
scope:New "Frame" {
	-- ... some other properties ...

	[Children] = {
		-- the component provides some children here
		scope:New "UICorner" {
			CornerRadius = UDim.new(0, 8)
		},

		-- include children from outside the component here
		props[Children]
	}
}
```