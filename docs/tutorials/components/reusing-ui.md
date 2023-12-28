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
type Dependencies = typeof(Fusion)

local function Button(
	scope: Fusion.Scope<Dependencies>,
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
		PopUp = require(script.Parent.PopUp),
		Message = require(script.Parent.Message),
		Button = require(script.Parent.Button)
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

	type Dependencies = typeof(Fusion) & {
		Message: typeof(require(script.Parent.Message)),
		Button: typeof(require(script.Parent.Button)),
	}

    local function PopUp(
		scope: Fusion.Scope<Dependencies>, 
		props: {
			Message: Fusion.CanBeState<string>,
			DismissText: Fusion.CanBeState<string>
		}
	)
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

	type Dependencies = typeof(Fusion)

    local function Message(
		scope: Fusion.Scope<Dependencies>,
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

	type Dependencies = typeof(Fusion)

    local function Button(
		scope: Fusion.Scope<Dependencies>,
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

??? tip "Type checking with components & scopes"
	You might notice the large type definition at the top of `PopUp`.

	```Lua
	type Dependencies = typeof(Fusion) & {
		Message: typeof(require(script.Parent.Message)),
		Button: typeof(require(script.Parent.Button)),
	}
	```	

	This type merges together the `Fusion` table with a second table containing
	`Message` and `Button`.

	It'd be a bit like writing this out:

	```Lua
	type Dependencies = {
		Message: (scope, props) -> Instance,
		Button: (scope, props) -> Instance,
		Value: (scope, initialValue) -> Value,
		Computed: (scope, processor) -> Computed,
		-- etc...
	}
	```

	Later on, this is passed to Fusion's `Scope<T>` type. `T` is the table of
	methods you want to access with `scoped()` syntax.

	```Lua hl_lines="2"
	local function PopUp(
		scope: Fusion.Scope<Dependencies>, 
		props: {
			Message: Fusion.CanBeState<string>,
			DismissText: Fusion.CanBeState<string>
		}
	)
	```

	Because the `Dependencies` type contains all of Fusion & the `Message` and
	`Button` components, it tells Luau:

	- to reject scopes that don't have those methods
	- to show you autocomplete information for those methods while working on
	  your code
	
	The scope defined in the main script contains all of those methods, so it
	passes type checking:

	```Lua
	local scope = scoped(Fusion, {
		PopUp = require(script.Parent.PopUp),
		Message = require(script.Parent.Message),
		Button = require(script.Parent.Button)
	})

	-- this is ok
	scope:PopUp {
		Message = "Hello, world!",
		DismissText = "Close"
	}
	```

	However, removing one of the methods emits a type checking error, because
	the scope can no longer support the `PopUp` component.

	```Lua hl_lines="3"
	local scope = scoped(Fusion, {
		PopUp = require(script.Parent.PopUp),
		Message = nil,
		Button = require(script.Parent.Button)
	})

	-- the type checker will flag this up!
	scope:PopUp {
		Message = "Hello, world!",
		DismissText = "Close"
	}
	```

	A nice benefit of this system is that components only specify the type of
	the component, rather than actually loading the specific component they use.
	This means you can substitute in other components if they provide the same
	API.

	```Lua hl_lines="3-4"
	local scope = scoped(Fusion, {
		PopUp = require(script.Parent.PopUp),
		Message = require(script.Parent.Test.Message),
		Button = require(script.Parent.Test.Button)
	})

	-- works as long as `Test.Message` and `Test.Button` match the real counterparts
	scope:PopUp {
		Message = "Hello, world!",
		DismissText = "Close"
	}
	```

	This is particularly valuable for testing code in fictional environments or
	for writing reusable code that can use custom implementations provided by
	the developers using it.

It might be scary at first to see a large list of modules, but because you can
browse visually by names and folders, it's almost always better than having one
long script.