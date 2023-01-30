`OnEvent` is a function that returns keys to use when hydrating or creating an
instance. Those keys let you connect functions to events on the instance.

```Lua
local button = New "TextButton" {
    [OnEvent "Activated"] = function(_, numClicks)
        print("The button was pressed", numClicks, "time(s)!")
    end
}
```

-----

## Usage

To use `OnEvent` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local OnEvent = Fusion.OnEvent
```

When you call `OnEvent` with an event name, it will return a special key:

```Lua
local key = OnEvent("Activated")
```

When that key is used in a property table, you can pass in a handler and it will
be connected to the event for you:

```Lua
local button = New "TextButton" {
    [OnEvent("Activated")] = function(_, numClicks)
        print("The button was pressed", numClicks, "time(s)!")
    end
}
```

If you're using quotes `'' ""` for the event name, the extra parentheses `()`
are optional:

```Lua
local button = New "TextButton" {
    [OnEvent "Activated"] = function(_, numClicks)
        print("The button was pressed", numClicks, "time(s)!")
    end
}
```