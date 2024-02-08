`OnChange` is a function that returns keys to use when hydrating or creating an
instance. Those keys let you connect functions to property changed events on the
instance.

```Lua
local input = scope:New "TextBox" {
    [OnChange "Text"] = function(newText)
        print("You typed:", newText)
    end
}
```

-----

## Usage

`OnChange` doesn't need a scope - import it into your code from Fusion directly.

```Lua
local OnChange = Fusion.OnChange
```

When you call `OnChange` with a property name, it will return a special key:

```Lua
local key = OnChange("Text")
```

When used in a property table, you can pass in a handler and it will be run when
that property changes.

!!! info "Arguments are different to Roblox API"
	Normally in the Roblox API, when using `:GetPropertyChangedSignal()` on an
	instance, the callback will not receive any arguments.

	To make working with change events easier, `OnChange` will pass the new value of
	the property to the callback.

```Lua
local input = scope:New "TextBox" {
    [OnChange("Text")] = function(newText)
        print("You typed:", newText)
    end
}
```

If you're using quotes `'' ""` for the event name, the extra parentheses `()`
are optional:

```Lua
local input = scope:New "TextBox" {
    [OnChange "Text"] = function(newText)
        print("You typed:", newText)
    end
}
```

