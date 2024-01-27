The `[Cleanup]` key allows you to add cleanup code to an instance you're
hydrating or creating. You can also pass in instances or event connections to
destroy.

```Lua
local connection = RunService.Heartbeat:Connect(function()
    print("Blah blah...")
end)

local part = New "Part" {
    [Cleanup] = connection
}
```

```Lua
local box = New "SelectionBox" {
    Parent = PlayerGui
}

local part = New "Part" {
    [Cleanup] = box
}
```

```Lua
local part = New "Part" {
    [Cleanup] = {
        function()
            print("Oh no, I got destroyed. Ouch :(")
        end,
        connection,
        box
    }
}
```

-----

## Usage

To use `Cleanup` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Cleanup = Fusion.Cleanup
```

When using `New` or `Hydrate`, you can use `[Cleanup]` as a key in the property
table. Any function you pass in will be run when the instance is destroyed:

```Lua
local folder = New "Folder" {
    [Cleanup] = function()
        print("This folder was destroyed")
    end
}
```

Arrays are supported - their contents will be cleaned up in order:

```Lua
local folder = New "Folder" {
    [Cleanup] = {
        function()
            print("This will run first")
        end,
        function()
            print("This will run next")
        end,
        function()
            print("This will run last")
        end
    }
}
```

You may also nest arrays up to any depth - sub-arrays are also run in order:

```Lua
local folder = New "Folder" {
    [Cleanup] = {
        function()
            print("This will run first")
        end,
        {
            function()
                print("This will run next")
            end,
            function()
                print("This will run second-to-last")
            end,
        },
        function()
            print("This will run last")
        end
    }
}
```

For convenience, `Cleanup` allows you to pass some types of value in directly.
Passing in an instance will destroy it:

```Lua
local box = New "SelectionBox" {
    Parent = PlayerGui
}

local part = New "Part" {
    -- `box` will be destroyed when the part is destroyed
    [Cleanup] = box
}
```

Passing in an event connection will disconnect it:

```Lua
local connection = RunService.Heartbeat:Connect(function()
    print("Blah blah...")
end)

local part = New "Part" {
    -- `connection` will be disconnected when the part is destroyed
    [Cleanup] = connection
}
```

Finally, passing in anything with a `:destroy()` or `:Destroy()` method will
have that method called:

```Lua
-- you might receive an object like this from a third party library
local object = {}
function object:destroy()
    print("I was destroyed!")
end

local part = New "Part" {
    -- `object:destroy()` will be called when the part is destroyed
    [Cleanup] = object
}
```

Any other kind of value will do nothing by default.

-----

## Don't Use Destroyed

While Roblox does provide it's own `Destroyed` event, it should *not* be relied
upon for cleaning up correctly in all cases. It only fires when the `Destroy`
method is called, meaning other kinds of destruction are ignored.

For example, notice only one of these parts runs their cleanup code:

=== "Script code"

    ```Lua linenums="1"
    local part1 = New "Part" {
        [OnEvent "Destroyed"] = function()
            print("=> Part 1 cleaned up")
        end
    }
    
    local part2 = New "Part" {
        [OnEvent "Destroyed"] = function()
            print("=> Part 2 cleaned up")
        end
    }

    print("Destroying part 1...")
    part1:Destroy()

    print("Setting part 2 to nil...")
    part2 = nil
    ```

=== "Output"

    ```
    Destroying part 1...
    => Part 1 cleaned up
    Setting part 2 to nil...
    ```

Meanwhile, Fusion's `[Cleanup]` will work regardless of how your instances were
destroyed, meaning you can avoid serious memory leaks:

=== "Script code"

    ```Lua linenums="1"
    local part1 = New "Part" {
        [Cleanup] = function()
            print("=> Part 1 cleaned up")
        end
    }
    
    local part2 = New "Part" {
        [Cleanup] = function()
            print("=> Part 2 cleaned up")
        end
    }

    print("Destroying part 1...")
    part1:Destroy()

    print("Setting part 2 to nil...")
    part2 = nil
    ```

=== "Output"

    ```
    Destroying part 1...
    => Part 1 cleaned up
    Setting part 2 to nil...
    => Part 2 cleaned up
    ```