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
local function Button(props)
    return New "TextButton" {
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
-- this is just a regular Lua function call!
local helloBtn = Button {
    ButtonText = "Hello",
    Size = UDim2.fromOffset(200, 50)
}

helloBtn.Parent = Players.LocalPlayer.PlayerGui.ScreenGui
```

This is the primary way UI is reused in Fusion. These kinds of functions are
common enough that they have a special name: **components**. Specifically,
components are functions which return a child.

In the above example, `Button` is a component, because it's a function that
returns a TextButton.

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
    local PopUp = require(script.Parent.PopUp)

    local ui = New "ScreenGui" {
        -- ...some properties...

        [Children] = PopUp {
            Message = "Hello, world!",
            DismissText = "Close"
        }
    }
    ```

=== "PopUp.lua"

    ```Lua linenums="1"
    local Message = require(script.Parent.Message)
    local Button = require(script.Parent.Button)

    local function PopUp(props)
        return New "Frame" {
            -- ...some properties...
            
            [Children] = {
                Message {
                    Text = props.Message
                }
                Button {
                    Text = props.DismissText
                }
            }
        }
    end

    return PopUp
    ```

=== "Message.lua"

    ```Lua linenums="1"
    local function Message(props)
        return New "TextLabel" {
            AutomaticSize = "XY",
            BackgroundTransparency = 1,

             -- ...some properties...

            Text = props.Text
        }
    end

    return Message
    ```

=== "Button.lua"

    ```Lua linenums="1"
    local function Button(props)
        return New "TextButton" {
            BackgroundColor3 = Color3.new(0.25, 0.5, 1),
            AutoButtonColor = true,

             -- ...some properties...

            Text = props.Text
        }
    end

    return Button
    ```

You can further group your modules using folders if you need more organisation.

It might be scary at first to see a large list of modules, but because you can
browse visually by names and folders, it's almost always better than having one
long script.