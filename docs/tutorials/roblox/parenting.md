The `[Children]` key allows you to add children when hydrating or creating an
instance.

It accepts instances, arrays of children, and state objects containing children
or `nil`.

```Lua
local folder = scope:New "Folder" {
    [Children] = {
        New "Part" {
            Name = "Gregory",
            Color = Color3.new(1, 0, 0)
        },
        New "Part" {
            Name = "Sammy",
            Material = "Glass"
        }
    }
}
```

-----

## Usage

`Children` doesn't need a scope - import it into your code from Fusion
directly.

```Lua
local Children = Fusion.Children
```

When using `New` or `Hydrate`, you can use `[Children]` as a key in the property
table. Any instance you pass in will be parented:

```Lua
local folder = scope:New "Folder" {
    -- The part will be moved inside of the folder
    [Children] = workspace.Part
}
```

Since `New` and `Hydrate` both return their instances, you can nest them:

```Lua
-- Makes a Folder, containing a part called Gregory
local folder = scope:New "Folder" {
    [Children] = scope:New "Part" {
        Name = "Gregory",
        Color = Color3.new(1, 0, 0)
    }
}
```

If you need to parent multiple children, arrays of children are accepted:

```Lua
-- Makes a Folder, containing parts called Gregory and Sammy
local folder = scope:New "Folder" {
    [Children] = {
        scope:New "Part" {
            Name = "Gregory",
            Color = Color3.new(1, 0, 0)
        },
        scope:New "Part" {
            Name = "Sammy",
            Material = "Glass"
        }
    }
}
```

Arrays can be nested to any depth; all children will still be parented:

```Lua
local folder = scope:New "Folder" {
    [Children] = {
        {
            {
                {
                    scope:New "Part" {
                        Name = "Gregory",
                        Color = Color3.new(1, 0, 0)
                    }
                }
            }
        }
    }
}
```

State objects containing children or `nil` are also allowed:

```Lua
local value = scope:Value()

local folder = scope:New "Folder" {
    [Children] = value
}

value:set(
    scope:New "Part" {
        Name = "Clyde",
        Transparency = 0.5
    }
)
```

You may use any combination of these to parent whichever children you need:

```Lua
local modelChildren = workspace.Model:GetChildren()
local includeModel = scope:Value(true)

local folder = scope:New "Folder" {
    -- array of children
    [Children] = {
        -- single instance
        scope:New "Part" {
            Name = "Gregory",
            Color = Color3.new(1, 0, 0)
        },
        -- state object containing children (or nil)
        scope:Computed(function(use)
            return if use(includeModel)
                then modelChildren:GetChildren() -- array of children
                else nil
        end)
    }
}
```