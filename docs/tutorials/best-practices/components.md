You can use functions to create self-contained, reusable blocks of code. In the
world of UI, you may think of them as *components* - though they can be used for
much more than just UI.

For example, consider this function, which generates a button based on some
`props` the user passes in:

```Lua
type UsedAs<T> = Fusion.UsedAs<T>

local function Button(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Position: UsedAs<UDim2>?,
		AnchorPoint: UsedAs<Vector2>?,
		Size: UsedAs<UDim2>?,
		LayoutOrder: UsedAs<number>?,
		ButtonText: UsedAs<string>
	}
)
    return scope:New "TextButton" {
        BackgroundColor3 = Color3.new(0, 0.25, 1),
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        Size = props.Size,
        LayoutOrder = props.LayoutOrder,

        Text = props.ButtonText,
        TextSize = 28,
        TextColor3 = Color3.new(1, 1, 1),

        [Children] = UICorner { CornerRadius = UDim2.new(0, 8) }
    }
end
```

You can call this function later to generate as many buttons as you need.

```Lua
local helloBtn = Button(scope, {
    ButtonText = "Hello",
    Size = UDim2.fromOffset(200, 50)
})

helloBtn.Parent = Players.LocalPlayer.PlayerGui.ScreenGui
```

Since the `scope` is the first parameter, it can even be used with `scoped()`
syntax.

```Lua
local scope = scoped(Fusion, {
	Button = Button
})

local helloBtn = scope:Button {
    ButtonText = "Hello",
    Size = UDim2.fromOffset(200, 50)
}

helloBtn.Parent = Players.LocalPlayer.PlayerGui.ScreenGui
```

This is the primary way of writing components in Fusion. You create functions
that accept `scope` and `props`, then return some content from them.

-----

## Properties

If you don't say what `props` should contain, it might be hard to figure
out how to use it.

You can specify your list of properties by adding a type to `props`, which gives
you useful autocomplete and type checking.

```Lua
local function Cake(
	-- ... some stuff here ...
	props: {
		Size: Vector3,
		Colour: Color3,
		IsTasty: boolean
	}
)
	-- ... some other stuff here ...
end
```

Note that the above code only accepts constant values, not state objects. If you
want to accept *either* a constant or a state object, you can use the 
`UsedAs` type.

```Lua
type UsedAs<T> = Fusion.UsedAs<T>

local function Cake(
	-- ... some stuff here ...
	props: {
		Size: UsedAs<Vector3>,
		Colour: UsedAs<Color3>,
		IsTasty: UsedAs<boolean>
	}
)
	-- ... some other stuff here ...
end
```

This is usually what you want, because it means the user can easily switch
a property to dynamically change over time, while still writing properties
normally when they don't change over time. You can mostly treat `UsedAs`
properties like they're state objects, because functions like `peek()` and
`use()` automatically choose the right behaviour for you.

You can use the rest of Luau's type checking features to do more complex
things, like making certain properties optional, or restricting that values
are valid for a given property. Go wild!

!!! warning "Be mindful of the angle brackets"
	Remember that, when working with `UsedAs`, you should be mindful of whether
	you're putting things inside the angled brackets, or outside of them.
	Putting some things inside of the angle brackets can change their meaning,
	compared to putting them outside of the angle brackets.
	
	Consider these two type definitions carefully:

	```Lua
	-- A Vector3, or a state object storing Vector3, or nil.
	UsedAs<Vector3>?

	-- A Vector3?, or a state object storing Vector3?
	UsedAs<Vector3?>
	```

	The first type is best for *optional properties*, where you provide a
	default value if it isn't specified by the user. If the user *does* specify
	it, they're forced to always give a valid value for it.

	The second type is best if the property understands `nil` as a valid value.
	This means the user can set it to `nil` at any time.
	
-----

## Scopes

In addition to `props`, you should also ask for a `scope`. The `scope`
parameter should come first, so that your users can use `scoped()` syntax to
create it.

```Lua
-- barebones syntax
local thing = Component(scope, { 
	-- ... some properties here ...
})

-- scoped() syntax
local thing = scope:Component { 
	-- ... some properties here ...
}
```

It's a good idea to provide a type for `scope`. This lets you specify what
methods you need the scope to have.

```Lua
scope: Fusion.Scope<YourMethodsHere>
```

If you don't know what methods to ask for, consider these two strategies.

1. If you use common methods (like Fusion's constructors) then it's a safe 
assumption that the user will also have those methods. You can ask for a
scope with those methods pre-defined.

	```Lua hl_lines="2"
	local function Component(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {}
	)
		return scope:New "Thing" {
			-- ... rest of code here ...
		}
	end
	```

2. If you need more specific or niche things that the user likely won't have
(for example, components you use internally), then you should not ask for those.
Instead, create a new inner scope with the methods you need.

	```Lua hl_lines="5-8"
	local function Component(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {}
	)
		local scope = scope:innerScope {
			SpecialThing1 = require(script.SpecialThing1),
			SpecialThing2 = require(script.SpecialThing2),
		}

		return scope:SpecialThing1 {
			-- ... rest of code here ...
		}
	end
	```

If you're not sure which strategy to pick, the second is always a safe fallback,
because it assumes less about your users and helps hide implementation details.


-----

## Modules

It's common to save different components inside of different files.
There's a number of advantages to this:

- it's easier to find the source code for a specific component
- it keep each file shorter and simpler
- it makes sure components are properly independent, and can't interfere
- it encourages reusing components everywhere, not just in one file

Here's an example of how you could split up some components into modules:

=== "Main file"

    ```Lua linenums="1"
	local Fusion = require(game:GetService("ReplicatedStorage").Fusion)
	local scoped, doCleanup = Fusion.scoped, Fusion.doCleanup

	local scope = scoped(Fusion, {
		PopUp = require(script.Parent.PopUp)
	})

    local ui = scope:New "ScreenGui" {
        -- ...some properties...

        [Children] = scope:PopUp {
            Message = "Hello, world!",
            DismissText = "Close"
        }
    }
    ```
=== "PopUp"

    ```Lua linenums="1"
	local Fusion = require(game:GetService("ReplicatedStorage").Fusion)
	type UsedAs<T> = Fusion.UsedAs<T>

    local function PopUp(
		scope: Fusion.Scope<typeof(Fusion)>, 
		props: {
			Message: UsedAs<string>,
			DismissText: UsedAs<string>
		}
	)
		local scope = scope:innerScope {
			Message = require(script.Parent.Message),
			Button = require(script.Parent.Button)
		}

        return scope:New "Frame" {
            -- ...some properties...
            
            [Children] = {
                scope:Message {
                    Text = props.Message
                }
                scope:Button {
                    Text = props.DismissText
                }
            }
        }
    end

    return PopUp
    ```

=== "Message"

    ```Lua linenums="1"
	local Fusion = require(game:GetService("ReplicatedStorage").Fusion)
	type UsedAs<T> = Fusion.UsedAs<T>

    local function Message(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Text: UsedAs<string>
		}
	)
        return scope:New "TextLabel" {
            AutomaticSize = "XY",
            BackgroundTransparency = 1,

             -- ...some properties...

            Text = props.Text
        }
    end

    return Message
    ```

=== "Button"

    ```Lua linenums="1"
	local Fusion = require(game:GetService("ReplicatedStorage").Fusion)
	type UsedAs<T> = Fusion.UsedAs<T>

    local function Button(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Text: UsedAs<string>
		}
	)
        return scope:New "TextButton" {
            BackgroundColor3 = Color3.new(0.25, 0.5, 1),
            AutoButtonColor = true,

             -- ...some properties...

            Text = props.Text
        }
    end

    return Button
    ```
