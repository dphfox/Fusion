Destructors are functions that clean up values passed to them. Computed objects
use them to clean up old values when they're no longer needed.

```Lua
local function callDestroy(x)
    x:Destroy()
end

local brick = Computed(function()
    return Instance.new("Part")
end, callDestroy)
```

-----

## Memory Management

In Luau, most values clean themselves up automatically, because they're managed
by the garbage collector:

```Lua
-- This will create a new table in memory:
local x = {
    hello = "world"
}
task.wait(5)
-- The table is destroyed automatically when you stop using it.
x = nil
```

However, not all values clean themselves up. Some common 'unmanaged' types are:

1. Instances - need to be `:Destroy()`ed
2. Event connections - need to be `:Disconnect()`ed
3. Custom objects - might provide their own `:Destroy()` methods.

The garbage collector doesn't manage these for you, so if you don't clean them
up, they could stick around forever:

```Lua
-- We're creating an event connection here.
local event = workspace.Changed:Connect(function()
    print("Hello!")
end)

-- Even if we stop using the event connection in our code, it will continue to
-- receive events. It will not be disconnected for you.
event = nil
```

-----

## State Objects

Those types of values are a problem for Computed objects. For example, if they
generate fresh instances, they need to destroy those instances too:

```Lua
local className = Value("Frame")
-- `instance` will generate a Frame at first
local instance = Computed(function()
    return Instance.new(className:get())
end)
-- This will cause it to generate a TextLabel - but we didn't destroy the Frame!
className:set("TextLabel")
```

This is where destructors help out. You can provide a second function, which
Fusion will call to destroy the values we generate:

```Lua
local function callDestroy(x)
    x:Destroy()
end

local instance = Computed(function()
    return Instance.new(className:get())
end, callDestroy)
```

Destructors aren't limited to typical cleanup behaviour! You can customise what
happens during cleanup, or do no cleanup at all:

```Lua
local function moveToServerStorage(x)
    x.Parent = game:GetService("ServerStorage")
end

local function doNothing(x)
    -- intentionally left blank
end
```

-----

## Shorthand

Most of the time, you'll want to either:

1. destroy/disconnect/clean up the values you generate...
2. ...or leave them alone and do nothing.

Fusion provides default destructors for both of these situations.

### Cleanup

`Fusion.cleanup` is a function which tries to cleans up whatever you pass to it:

- given an instance, it is `:Destroy()`ed
- given an event connection, it is `:Disconnect()`ed
- given an object, any `:destroy()` or `:Destroy()` methods are run
- given a function, the function is run
- given an array, it cleans up everything inside

You can use this when generating unmanaged values:

```Lua
local instance = Computed(function()
    return Instance.new(className:get())
end, Fusion.cleanup) 
```

### Do Nothing

`Fusion.doNothing` is an empty function. It does nothing.

You can use this when passing 'through' unmanaged values that you don't control.
It makes it clear that your code is supposed to leave the values alone:

```Lua
local instance = Computed(function()
    return workspace:FindFirstChild(name:get())
end, Fusion.doNothing)
```