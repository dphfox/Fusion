Normally, components are controlled by the code creating them. This is called
top-down control, and is the primary flow of control in Fusion.

![Diagram of top-down control in an inventory UI.](Top-Down-Control-Dark.svg#only-dark)
![Diagram of top-down control in an inventory UI.](Top-Down-Control-Light.svg#only-light)

However, sometimes components need to talk back to their controlling code, for
example to report when button clicks occur.

-----

## In Luau

Callbacks are functions which you pass into other functions. They're part of
normal Luau code.

```Lua
workspace.ChildAdded:Connect(function()
    -- this function is a callback!
end)
```

They're useful because they allow the function to 'call back' into your code,
so your code can do something in response:

```Lua
local function printMessage()
    print("Hello, world!")
end

-- Here, we're passing `printMessage` as a callback
-- `task.delay` will call it after 5 seconds
task.delay(5, printMessage)
```

If your function accepts a callback, then you can call it like any other
function. Luau will execute the function, then return to your code.

In this example, the `fiveTimes` function calls a callback five times:

=== "Script code"

    ```Lua
    local function fiveTimes(callback)
        for x=1, 5 do
            callback(x)
        end
    end

    fiveTimes(function(num)
        print("The number is", num)
    end)
    ```

=== "Output"

    ```
    The number is 1
    The number is 2
    The number is 3
    The number is 4
    The number is 5
    ```

-----

## In Fusion

Components can use callbacks the same way. Consider this button component; when
the button is clicked, the button needs to run some external code:

```Lua
local function Button(props)
    return New "TextButton" {
        BackgroundColor3 = Color3.new(0.25, 0.5, 1),
        Position = props.Position,
        Size = props.Size,

        Text = props.Text,
        TextColor3 = Color3.new(1, 1, 1),

        [OnEvent "Activated"] = -- ???
    }
end
```

It can ask the controlling code to provide a callback in `props`, called OnClick:

```Lua hl_lines="3-5"
local button = Button {
    Text = "Hello, world!",
    OnClick = function()
        print("The button was clicked")
    end
}
```

Assuming that callback is passed in, the callback can be passed directly into
`[OnEvent]`, because `[OnEvent]` accepts functions:

```Lua hl_lines="10"
local function Button(props)
    return New "TextButton" {
        BackgroundColor3 = Color3.new(0.25, 0.5, 1),
        Position = props.Position,
        Size = props.Size,

        Text = props.Text,
        TextColor3 = Color3.new(1, 1, 1),

        [OnEvent "Activated"] = props.OnClick
    }
end
```

Alternatively, we can call `props.OnClick` manually, which is useful if you want
to do your own processing first:

```Lua hl_lines="10-15"
local function Button(props)
    return New "TextButton" {
        BackgroundColor3 = Color3.new(0.25, 0.5, 1),
        Position = props.Position,
        Size = props.Size,

        Text = props.Text,
        TextColor3 = Color3.new(1, 1, 1),

        [OnEvent "Activated"] = function()
            -- don't send clicks if the button is disabled
            if not props.Disabled:get() then
                props.OnClick()
            end
        end
    }
end
```

This is the primary way components talk to their controlling code in Fusion.