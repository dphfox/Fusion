`OnEvent` is a function that returns keys to use when hydrating or creating an
instance. Those keys let you connect functions to events on the instance.

```Lua
local button = scope:New "TextButton" {
    [OnEvent "Activated"] = function(_, numClicks)
        print("The button was pressed", numClicks, "time(s)!")
    end
}
```

-----

## Usage

`OnEvent` doesn't need a scope - import it into your code from Fusion directly.

```Lua
local OnEvent = Fusion.OnEvent
```

When you call `OnEvent` with an event name, it will return a special key:

```Lua
local key = OnEvent("Activated")
```

When that key is used in a property table, you can pass in a handler and it will
be connected to the event for you:

```Lua
local button = scope:New "TextButton" {
    [OnEvent("Activated")] = function(_, numClicks)
        print("The button was pressed", numClicks, "time(s)!")
    end
}
```

If you're using quotes `'' ""` for the event name, the extra parentheses `()`
are optional:

```Lua
local button = scope:New "TextButton" {
    [OnEvent "Activated"] = function(_, numClicks)
        print("The button was pressed", numClicks, "time(s)!")
    end
}
```