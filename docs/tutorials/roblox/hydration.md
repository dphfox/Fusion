!!! warning "Intent to replace"
	While the contents of this page still apply (and are useful for explaining
	other features), `Hydrate` itself will be replaced by other primitives in
	the near future.
	[See this issue on GitHub for further details.](https://github.com/dphfox/Fusion/issues/206)

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
of properties. If you pass in Fusion objects, changes will be applied
immediately:

```Lua
local showUI = scope:Value(false)

local ui = scope:Hydrate(StarterGui.Template:Clone()) {
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

The `Hydrate` function is called in two parts. First, call the function with the
instance you want to hydrate, then pass in the property table:

```Lua
local instance = workspace.Part

scope:Hydrate(instance)({
	Color = Color3.new(1, 0, 0)
})
```

If you're using curly braces `{}` to pass your properties in, the extra
parentheses `()` are optional:

```Lua
local instance = workspace.Part

-- This only works when you're using curly braces {}!
scope:Hydrate(instance) {
	Color = Color3.new(1, 0, 0)
}
```

`Hydrate` returns the instance you give it, so you can use it in declarations:

```Lua
local instance = scope:Hydrate(workspace.Part) {
	Color = Color3.new(1, 0, 0)
}
```

If you pass in constant values for properties, they'll be applied to the
instance directly. However, if you pass in a Fusion object (like `Value`), then
changes will be applied immediately:

```Lua
local message = scope:Value("Loading...")

scope:Hydrate(PlayerGui.LoadingText) {
	Text = message
}

print(PlayerGui.Message.Text) --> Loading...

message:set("All done!")
task.wait() -- important: changes are applied on the next frame!
print(PlayerGui.Message.Text) --> All done!
```