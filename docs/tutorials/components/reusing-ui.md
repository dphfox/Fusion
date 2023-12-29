Up until this point, you have been creating and parenting instances directly
without much organisation or code reuse. However, those two factors will become
increasingly important as you start building more game-ready UIs.

These next few pages won't introduce new features of Fusion, but instead will
focus on techniques for making your UI more modular, portable and easy to
maintain.

-----

## Components

One of the greatest advantages of libraries like Fusion is that UI and code are
the same thing. Any tool you can use on one, you can use on the other.

To reduce repetition in your codebases, you'll often use functions to run small
reusable blocks of code, sometimes with parameters you can change. You can use
functions to organise your UI code, too.

For example, consider this function, which generates a button based on some
`props` the user passes in:

```Lua
local function Button(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Position: Fusion.CanBeState<UDim2>?,
		AnchorPoint: Fusion.CanBeState<Vector2>?,
		Size: Fusion.CanBeState<UDim2>?,
		LayoutOrder: Fusion.CanBeState<number>?,
		ButtonText: Fusion.CanBeState<string>
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

You can call this function later to generate as many buttons as you need:

```Lua
local helloBtn = Button(scope, {
    ButtonText = "Hello",
    Size = UDim2.fromOffset(200, 50)
})

helloBtn.Parent = Players.LocalPlayer.PlayerGui.ScreenGui
```

This is the primary way UI is reused in Fusion. These kinds of functions are
common enough that they have a special name: **components**. Specifically,
components are functions which return a child.

In the above example, `Button` is a component, because it's a function that
returns a TextButton.

!!! tip "Components can be scoped, too"
	You may remember that `scoped()` lets you add functions as methods, so long
	as the function takes a scope as its first parameter.

	If you define your components with `(scope, props)` as its arguments - like
	above - then you can add it to `scoped()` too.

	```Lua
	local scope = scoped(Fusion, {
		Button = Button
	})
	```

	This gives you the same clean syntax as all other objects in Fusion.

	```Lua
	local helloBtn = scope:Button({
		ButtonText = "Hello",
		Size = UDim2.fromOffset(200, 50)
	})
	```

	In addition, much like `New`, you can remove the parentheses for clean and
	visually consistent code.

	```Lua
	local helloBtn = scope:Button {
		ButtonText = "Hello",
		Size = UDim2.fromOffset(200, 50)
	}
	```

-----

## Modules

It's common to save different components inside of different ModuleScripts.
There's a number of advantages to this:

- it's easier to find the source code for a specific component
- it keep each script shorter and simpler
- it makes sure components are properly independent, and can't interfere
- it encourages reusing components everywhere, not just in one script

Here's an example of how you could split up some components into modules:

=== "Main script"

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

    local function PopUp(
		outerScope: Fusion.Scope<{}>, 
		props: {
			Message: Fusion.CanBeState<string>,
			DismissText: Fusion.CanBeState<string>
		}
	)
		local scope = scoped(Fusion, {
			Message = require(script.Parent.Message),
			Button = require(script.Parent.Button)
		})
		table.insert(outerScope, scope)

        return scope:New "Frame" {
            -- ...some properties...
            
            [Children] = {
                scope:Message {
					Scope = scope,
                    Text = props.Message
                }
                scope:Button {
					Scope = scope,
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

    local function Message(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Text: Fusion.CanBeState<string>
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

    local function Button(
		scope: Fusion.Scope<typeof(Fusion)>,
		props: {
			Text: Fusion.CanBeState<string>
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

!!! success "Provide a list of properties"
	If you don't provide a list of properties for your component anywhere, it
	might be hard to figure out how to use it.

	The best way to do this is using Luau types. You can specify your list of
	properties inline with your function definition:

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

	This isn't just good documentation - it also gives you useful autocomplete.
	If you try to use properties incorrectly inside the function body, it will
	raise a type checking error. Similarly, you'll get useful errors if you
	accidentally leave out a property when you use the component later.

	Note that the above code only accepts constant values, not state objects.

	If you want to accept *either* a constant or a state object, you can use the
	`CanBeState` type.

	```Lua
	local function Cake(
		-- ... some stuff here ...
		props: {
			Size: Fusion.CanBeState<Vector3>,
			Colour: Fusion.CanBeState<Color3>,
			IsTasty: Fusion.CanBeState<boolean>
		}
	)
		-- ... some other stuff here ...
	end
	```

	This is usually what you want, because it means the user can easily switch
	a property to dynamically change over time, while still writing properties
	normally when they don't change over time. You can mostly treat `CanBeState`
	properties like they're state objects, because functions like `peek()` and
	`use()` automatically choose the right behaviour for you.

	If something *absolutely must* be a state object, you can use the
	`StateObject` type instead. You should only consider this when it doesn't
	make sense for the property to stay the same forever.

	```Lua
	local function Cake(
		-- ... some stuff here ...
		props: {
			Size: Fusion.StateObject<Vector3>,
			Colour: Fusion.StateObject<Color3>,
			IsTasty: Fusion.StateObject<boolean>
		}
	)
		-- ... some other stuff here ...
	end
	```

	You can use the rest of Luau's type checking features to do more complex
	things, like making certain properties optional, or restricting that values
	are valid for a given property. Go wild!

	Remember that, when working with `StateObject` and `CanBeState`, you should
	be mindful of whether you're putting things inside the angled brackets, or
	outside of them. Consider these two type definitions carefully:

	```Lua
	-- always a state object, which stores either Vector3 or nil
	Fusion.StateObject<Vector3?>

	-- either nil, or a state object which always stores Vector3
	Fusion.StateObject<Vector3>?
	```

!!! tip "How to ask for a scope"
	In addition to `props`, it's strongly recommended to provide a type for the
	`scope` parameter.

	The type will look something like this:

	```Lua
	scope: Fusion.Scope<YourMethodsHere>
	```

	This naturally leads to two strategies for dealing with scopes.
	
	The first strategy is to ask for certain methods. In  `Button` and `Message`,
	they ask for a scope containing Fusion methods, so they can easily access
	Fusion with no extra effort.

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

	The second strategy is not to ask for any methods. Instead, you create your
	own scope with what you need, and add it to the scope the user gives you.
	This is what `PopUp` does.

	```Lua hl_lines="2 5-9"
	local function Component(
		outerScope: Fusion.Scope<{}>,
		props: {}
	)
		local scope = scoped(Fusion, {
			SpecialThing1 = require(script.SpecialThing1),
			SpecialThing2 = require(script.SpecialThing2),
		})
		table.insert(outerScope, scope)

		return scope:SpecialThing1 {
			-- ... rest of code here ...
		}
	end
	```

	The general advice is to only ask for methods if they're very common - for
	example, if you only need access to the Fusion library, it can be convenient
	to simply ask for it to be there. The user's scope probably has it already.
	
	If you need to access specialised things like other components, it's better
	to create a new scope internally so users of your component don't have to
	worry about those internal components.