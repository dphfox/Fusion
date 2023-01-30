Using components, you can assemble more complex instance hierarchies by
combining simpler, self-contained parts. To do that, you should pay attention to
how instances are passed between components.

-----

## Returning Children

Components return a child when you call them. That means anything you return
from a component should be supported by `[Children]`.

That means you can return *one* (and only one):

- instance
- array of children
- or state object containing a child

This should be familiar from parenting instances using `[Children]`. To recap:

!!! success "Allowed"
    You can return one value per component.
    ```Lua
    -- returns *one* instance
    local function Component()
        return New "Frame" {}
    end
    ```
    ```Lua
    -- returns *one* array
    local function Component()
        return {
            New "Frame" {},
            New "Frame" {},
            New "Frame" {}
        }
    end
    ```
    ```Lua
    -- returns *one* state object
    local function Component()
        return ForValues({1, 2, 3}, function()
            return New "Frame" {}
        end)
    end
    ```
!!! success "Allowed"
    Inside arrays or state objects, you can mix and match different children.
    ```Lua
    -- mix of arrays, instances and state objects
    local function Component()
        return {
            New "Frame" {},
            {
                New "Frame" {},
                ForValues( ... )
            }
            ForValues( ... )
        }
    end
    ```
!!! fail "Not allowed"
    Don't return multiple values straight from your function. Prefer to use an
    array instead.
    ```Lua
    -- returns *multiple* instances (not surrounded by curly braces!)
    local function Component()
        return
            New "Frame" {},
            New "Frame" {},
            New "Frame" {}
    end
    ```
    Luau does not support multiple return values consistently. They can get lost
    easily if you're not careful.

-----

## Parenting Components

Components return the same values which `[Children]` uses. That means they're
directly compatible, and you can insert a component anywhere you'd normally
insert an instance.

You can pass in one component on its own...

```Lua
local ui = New "ScreenGui" {
    [Children] = Button {
        Text = "Hello, world!"
    }
}
```

...you can include components as part of an array..

```Lua
local ui = New "ScreenGui" {
    [Children] = {
        New "UIListLayout" {},
        Button {
            Text = "Hello, world!"
        },
        Button {
            Text = "Hello, again!"
        }
    }
}
```

...and you can return them from state objects, too.

```Lua
local ui = New "ScreenGui" {
    [Children] = {
        New "UIListLayout" {},
        
        ForValues({"Hello", "world", "from", "Fusion"}, function(text)
            return Button {
                Text = text
            }
        end)
    }
}
```

-----

## Accepting Children

Some components, for example pop-ups, might contain lots of different content:

![Examples of pop-ups with different content.](Popups-Dark.svg#only-dark)
![Examples of pop-ups with different content.](Popups-Light.svg#only-light)

Ideally, you would be able to reuse the pop-up 'container', while placing your
own content inside.

![Separating the pop-up container from the pop-up contents.](Popup-Exploded-Dark.svg#only-dark)
![Separating the pop-up container from the pop-up contents.](Popup-Exploded-Light.svg#only-light)

The simplest way to do this is to pass children through to `[Children]`. For
example, if you accept a table of `props`, you can add a `[Children]` key:

```Lua hl_lines="7"
local function PopUp(props)
    return New "Frame" {
        -- ... some other properties ...

        -- Since `props` is a table, and `[Children]` is a key, you can use it
        -- yourself as a key in `props`:
        [Children] = props[Children]
    }
end
```

Later on, when a pop-up is created, children can now be parented into that
instance:

```Lua
local popUp = PopUp {
    [Children] = {
        Label {
            Text = "New item collected"
        },
        ItemPreview {
            Item = Items.BRICK
        },
        Button {
            Text = "Add to inventory"
        }
    }
}
```

You're not limited to passing it straight into `[Children]`. If you need to add
other children, you can still use arrays and state objects as normal:

```Lua hl_lines="5-13"
local function PopUp(props)
    return New "Frame" {
        -- ... some other properties ...

        [Children] = {
            -- the component provides some children here
            New "UICorner" {
                CornerRadius = UDim.new(0, 8)
            },

            -- include children from outside the component here
            props[Children]
        }
    }
end
```