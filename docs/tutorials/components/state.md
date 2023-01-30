Components can hold their own data privately using state objects. This can be
useful, but you should be careful when adding state.

-----

## Creating State Objects

Inside a component, state objects can be created and used the same way as usual:

```Lua hl_lines="5 8-10 13 17"
local HOVER_COLOUR = Color3.new(0.5, 0.75, 1)
local REST_COLOUR = Color3.new(0.25, 0.5, 1)

local function Button(props)
    local isHovering = Value(false)

    return New "TextButton" {
        BackgroundColor3 = Computed(function()
            return if isHovering:get() then HOVER_COLOUR else REST_COLOUR
        end),

        [OnEvent "MouseEnter"] = function()
            isHovering:set(true)
        end,

        [OnEvent "MouseLeave"] = function()
            isHovering:set(false)
        end,

        -- ... some properties ...
    }
end
```

Like regular Luau, state objects stay around as long as they're being used. Once
your component is destroyed and your code no longer uses the objects, they'll be
cleaned up.

-----

## Top-Down Control

Remember that Fusion mainly works with a top-down flow of control. It's a good
idea to keep that in mind when adding state to components.

When you're making reusable components, it's more flexible if your component can
be controlled externally. Components that control themselves entirely are hard
to use and customise.

Consider the example of a check box. Each check box often reflects a state
object under the hood:

![Showing check boxes connected to Value objects.](Check-Boxes-Dark.svg#only-dark)
![Showing check boxes connected to Value objects.](Check-Boxes-Light.svg#only-light)

It might *seem* logical to store the state object inside the check box:

```Lua hl_lines="2"
local function CheckBox(props)
    local isChecked = Value(false)

    return New "ImageButton" {
        -- ... some properties ...
    }
end
```

However, hiding away important state in components causes a few problems:

- to control the appearance of the check box, you're forced to change the
internal state
- clicking the check box has hard-coded behaviour, which is bad if you need to
intercept the click (e.g. to show a confirmation dialogue)
- if you already had a state object for that setting, now the check box has a
duplicate state object representing the same setting

Therefore, it's better for the controlling code to hold the state object, and
use callbacks to switch the value when the check box is clicked:

```Lua
local playMusic = Value(true)

local checkBox = CheckBox {
    Text = "Play music",
    IsChecked = playMusic,
    OnClick = function()
        playMusic:set(not playMusic:get())
    end
}
```

The control is always top-down here; the check box's appearance is fully
controlled by the creator. The creator of the check box *decides* to switch the
setting when the check box is clicked. 

The check box itself is an inert, visual element; it just shows a graphic and
reports clicks.

-----

Setting up the check box this way also allows for more complex behaviour later
on. Suppose we wanted to group together multiple options under a 'main' check
box, so you can turn them all on/off at once.

![Showing check boxes connected to Value objects.](Master-Check-Box-Dark.svg#only-dark)
![Showing check boxes connected to Value objects.](Master-Check-Box-Light.svg#only-light)

The appearance of that check box would not be controlled by a single state, but
instead reflects the combination of multiple states. We can use a `Computed`
for that:

```Lua hl_lines="7-18"
local playMusic = Value(true)
local playSFX = Value(false)
local playNarration = Value(true)

local checkBox = CheckBox {
    Text = "Play sounds",
    Appearance = Computed(function()
        local anyChecked = playMusic:get() or playSFX:get() or playNarration:get()
        local allChecked = playMusic:get() and playSFX:get() and playNarration:get()

        if not anyChecked then
            return "unchecked"
        elseif not allChecked then
            return "partially-checked"
        else
            return "checked"
        end
    end)
}
```

We can then implement the 'check all'/'uncheck all' behaviour inside `OnClick`:

```Lua hl_lines="7-13"
local playMusic = Value(true)
local playSFX = Value(false)
local playNarration = Value(true)

local checkBox = CheckBox {
    -- ... same properties as before ...
    OnClick = function()
        local allChecked = playMusic:get() and playSFX:get() and playNarration:get()

        playMusic:set(not allChecked)
        playSFX:set(not allChecked)
        playNarration:set(not allChecked)
    end
}
```

By keeping the check box 'stateless', we can make it behave much more flexibly.

-----

## Best Practices

Those examples lead us into the golden rule when adding state to components.

!!! tip "Golden Rule"
    It's better for reusable components to *reflect* program state. They should
    not usually *contain* program state.

State objects are best suited to self-contained use cases, such as implementing
hover effects, animations or responsive design. As such, you should think about
whether you really need to add state to components, or whether it's better to
add it higher up.

At first, this might be difficult to do well, but with experience you'll have a
better intuition for it. Remember that you can always rewrite your code if it
becomes a problem!