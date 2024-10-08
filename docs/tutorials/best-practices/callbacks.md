Normally, components are controlled by the code creating them. This is called
top-down control, and is the primary flow of control in Fusion.

![Diagram of top-down control in an inventory UI.](Top-Down-Control-Dark.svg#only-dark)
![Diagram of top-down control in an inventory UI.](Top-Down-Control-Light.svg#only-light)

However, sometimes components need to talk back to their controlling code, for
example to report when button clicks occur.

-----

## In Luau

Callbacks are functions which you pass into other functions. They're useful
because they allow the function to 'call back' into your code, so your code can
do something in response:

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

=== "Luau code"

    ```Lua
    local function fiveTimes(
		callback: (number) -> ()
	)
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

```Lua hl_lines="17"
local function Button(
	scope: Fusion.Scope,
	props: {
		Position: UsedAs<UDim2>?,
		Size: UsedAs<UDim2>?,
		Text: UsedAs<string>?
	}
)
    return scope:New "TextButton" {
        BackgroundColor3 = Color3.new(0.25, 0.5, 1),
        Position = props.Position,
        Size = props.Size,

        Text = props.Text,
        TextColor3 = Color3.new(1, 1, 1),

        [OnEvent "Activated"] = -- ???
    }
end
```

It can ask the controlling code to provide an `OnClick` callback in `props`.

```Lua
local button = scope:Button {
    Text = "Hello, world!",
    OnClick = function()
        print("The button was clicked")
    end
}
```

Assuming that callback is passed in, the callback can be passed directly into
`[OnEvent]`, because `[OnEvent]` accepts functions. It can even be optional -
Luau won't add the key to the table if the value is `nil`.

```Lua hl_lines="7 18"
local function Button(
	scope: Fusion.Scope,
	props: {
		Position: UsedAs<UDim2>?,
		Size: UsedAs<UDim2>?,
		Text: UsedAs<string>?,
		OnClick: (() -> ())?
	}
)
    return scope:New "TextButton" {
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

```Lua hl_lines="19-23"
local function Button(
	scope: Fusion.Scope,
	props: {
		Position: UsedAs<UDim2>?,
		Size: UsedAs<UDim2>?,
		Text: UsedAs<string>?,
		Disabled: UsedAs<boolean>?,
		OnClick: (() -> ())?
	}
)
    return scope:New "TextButton" {
        BackgroundColor3 = Color3.new(0.25, 0.5, 1),
        Position = props.Position,
        Size = props.Size,

        Text = props.Text,
        TextColor3 = Color3.new(1, 1, 1),

        [OnEvent "Activated"] = function()
            if props.OnClick ~= nil and not peek(props.Disabled) then
                props.OnClick()
            end
        end
    }
end
```

This is the primary way components talk to their controlling code in Fusion.

-----

## Children Callbacks

There's a special kind of callback that's often used when you need more control
over the children you're putting inside of a component.

When your component asks for `[Children]`, the controlling code will construct
some children for you ahead of time, and pass it into that `[Children]` key. You
don't have any control over what that process looks like.

```Lua
-- This snippet...
local dialog = scope:Dialog {
	[Children] = {
		scope:Button {
			Text = "Hello, world!" 
		},
		scope:Text {
			Text = "I am pre-fabricated!" 
		}
	}
}

-- ...is equivalent to this code.
local children = {
	scope:Button {
		Text = "Hello, world!" 
	},
	scope:Text {
		Text = "I am pre-fabricated!" 
	}
}

local dialog = scope:Dialog {
	[Children] = children
}
```

However, if your component asks for a callback instead, you can create those
children on demand, as many times as you'd like, with whatever parameters you
want to pass in.

This callback should be given a descriptive name like `Build`, `Render`, or
whatever terminology fits your code base. Try and be consistent across all of
your components.

```Lua
local dialog = scope:Dialog {
	-- Use a `scope` parameter here so that the component can change when these
	-- children are destroyed if it needs to. This is especially important for
	-- components that create multiple sets of children over time.
	Build = function(scope)
		return {
			scope:Button {
				Text = "Hello, world!" 
			},
			scope:Text {
				Text = "I am created on the fly!" 
			}
		}
	end
}
```

!!! warning
	Don't use `[Children]` to store a function. In general, avoid using special
	keys unless you're actually passing the values through, because changing how
	a special key appears to behave can make code confusing to follow.

	In this case, using a dedicated naming convention like `Build` ensures that
	users understand that their children are not being created ahead of time.

Children callbacks are especially useful if the controlling code needs more
information to build the rest of the UI. For example, you might want to share
some layout information so children can fit into the component more neatly.

```Lua hl_lines="2 6 10"
local dialog = scope:Dialog {
	Build = function(scope, textSize)
		return {
			scope:Button {
				Text = "Hello, world!",
				TextSize = textSize
			},
			scope:Text {
				Text = "I am created on the fly!",
				TextSize = textSize
			}
		}
	end
}
```

This is also useful for [sharing values to all children](../sharing-values),
which will be covered on a later page.
