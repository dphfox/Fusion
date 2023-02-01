The process of connecting your scripts to a pre-made UI template is known as
*hydration*. This is where logic in your scripts translate into UI effects, for
example setting a message inside a TextLabel, moving menus around, or showing
and hiding buttons.


<figure markdown>
![A diagram showing hydration - an 'ammo' variable is sent from the script and placed inside various UI and game elements.](Hydration-Basic-Dark.svg#only-dark)
![A diagram showing hydration - an 'ammo' variable is sent from the script and placed inside various UI and game elements.](Hydration-Basic-Light.svg#only-light)
<figcaption>Screenshot: GameUIDatabase (Halo Infinite)</figcaption>
</figure>

Fusion provides a `Hydrate` function for hydrating an instance using a table
of properties. If you pass in Fusion objects, changes will be applied on the
next frame:

```Lua
local showUI = Value(false)

local ui = Hydrate(StarterGui.Template:Clone()) {
	Name = "MainGui",
	Enabled = showUI
}

print(ui.Name) --> MainGui
print(ui.Enabled) --> false

showUI:set(true)
task.wait() -- important: changes are applied on the next frame!
print(ui.Enabled) --> true
```

-----

## Usage

To use `Hydrate` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Hydrate = Fusion.Hydrate
```

The `Hydrate` function is called in two parts. First, call the function with the
instance you want to hydrate, then pass in the property table:

```Lua
local instance = workspace.Part

Hydrate(instance)({
	Color = Color3.new(1, 0, 0)
})
```

If you're using curly braces `{}` to pass your properties in, the extra
parentheses `()` are optional:

```Lua
local instance = workspace.Part

-- This only works when you're using curly braces {}!
Hydrate(instance) {
	Color = Color3.new(1, 0, 0)
}
```

`Hydrate` returns the instance you give it, so you can use it in declarations:

```Lua
local instance = Hydrate(workspace.Part) {
	Color = Color3.new(1, 0, 0)
}
```

If you pass in constant values for properties, they'll be applied to the
instance directly. However, if you pass in a Fusion object (like `Value`), then
changes will be applied on the next frame:

```Lua
local message = Value("Loading...")

Hydrate(PlayerGui.LoadingText) {
	Text = message
}

print(PlayerGui.Message.Text) --> Loading...

message:set("All done!")
task.wait() -- important: changes are applied on the next frame!
print(PlayerGui.Message.Text) --> All done!
```