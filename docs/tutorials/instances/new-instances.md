Fusion provides a `New` function when you're hydrating newly-made instances. It
creates a new instance, applies some default properties, then hydrates it with
a property table.

```Lua
local message = Value("Hello there!")

local ui = New "TextLabel" {
	Name = "Greeting",
	Parent = PlayerGui.ScreenGui,

	Text = message
}

print(ui.Name) --> Greeting
print(ui.Text) --> Hello there!

message:set("Goodbye friend!")
task.wait() -- important: changes are applied on the next frame!
print(ui.Text) --> Goodbye friend!
```

-----

## Usage

To use `New` in your code, you first need to import it from the Fusion module,
so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
```

The `New` function is called in two parts. First, call the function with the
type of instance, then pass in the property table:

```Lua
local instance = New("Part")({
	Parent = workspace,
	Color = Color3.new(1, 0, 0)
})
```

If you're using curly braces `{}` for your properties, and quotes `'' ""` for
your class type, the extra parentheses `()` are optional:

```Lua
-- This only works when you're using curly braces {} and quotes '' ""!
local instance = New "Part" {
	Parent = workspace,
	Color = Color3.new(1, 0, 0)
}
```

By design, `New` works just like `Hydrate` - it will apply properties the same
way. [See the Hydrate tutorial to learn more.](../hydration)

-----

## Default Properties

When you create an instance using `Instance.new()`, Roblox will give it some
default properties. However, these tend to be outdated and aren't useful for
most people, leading to repetitive boilerplate needed to disable features that
nobody wants to use.

The `New` function will apply some of it's own default properties to fix this.
For example, by default borders on UI are disabled, automatic colouring is
turned off and default content is removed.

![Showing the difference between a text label made with Instance.new and Fusion's New function.](Default-Props-Dark.svg#only-dark)
![Showing the difference between a text label made with Instance.new and Fusion's New function.](Default-Props-Light.svg#only-light)

For a complete list, [take a look at Fusion's default properties file.](https://github.com/Elttob/Fusion/blob/main/src/Instances/defaultProps.lua)
