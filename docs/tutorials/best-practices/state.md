Components can hold their own data privately using state objects. This can be
useful, but you should be careful when adding state.

-----

## Creation

You can create state objects inside components as you would anywhere else.

```Lua hl_lines="10 13-15"
local HOVER_COLOUR = Color3.new(0.5, 0.75, 1)
local REST_COLOUR = Color3.new(0.25, 0.5, 1)

local function Button(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		-- ... some properties ...
	}
)
    local isHovering = scope:Value(false)

    return scope:New "TextButton" {
        BackgroundColor3 = scope:Computed(function(use)
            return if use(isHovering) then HOVER_COLOUR else REST_COLOUR
        end),

        -- ... ... some more code ...
    }
end
```

Because these state objects are made with the same `scope` as the rest of the
component, they're destroyed alongside the rest of the component.

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

It might *seem* logical to store the state object inside the check box, but
this causes a few problems:

- because the state is hidden, it's awkward to read and write from outside
- often, the user already has a state object representing the same setting, so
now there's two state objects where one would have sufficed

```Lua hl_lines="7"
local function CheckBox(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		-- ... some properties ...
	}
)
    local isChecked = scope:Value(false) -- problematic

    return scope:New "ImageButton" {
		[OnEvent "Activated"] = function()
			isChecked:set(not peek(isChecked))
		end,

        -- ... some more code ...
    }
end
```

A *slightly better* solution is to pass the state object in. This ensures the
controlling code has easy access to the state if it needs it. However, this is
not a complete solution:

- the user is forced to store the state in a `Value` object, but they might be
computing the value dynamically with other state objects instead
- the behaviour of clicking the check box is hardcoded; the user cannot
intercept the click or toggle a different state

```Lua hl_lines="4"
local function CheckBox(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		IsChecked: Fusion.Value<boolean> -- slightly better
	}
)
    return scope:New "ImageButton" {
		[OnEvent "Activated"] = function()
			props.IsChecked:set(not peek(props.IsChecked))
		end,

        -- ... some more code ...
    }
end
```

That's why the *best* solution is to use `UsedAs` to create read-only
properties, and add callbacks for signalling actions and events.

- because `UsedAs` is read-only, it lets the user plug in any data source,
including dynamic computations
- because the callback is provided by the user, the behaviour of clicking the
check box is completely customisable

```Lua hl_lines="4-5 10"
local function CheckBox(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		IsChecked: UsedAs<boolean>, -- best
		OnClick: () -> ()
	}
)
    return scope:New "ImageButton" {
		[OnEvent "Activated"] = function()
			props.OnClick()
		end,

        -- ... some more code ...
    }
end
```

The control is always top-down here; the check box's appearance is fully
controlled by the creator. The creator of the check box *decides* to switch the
setting when the check box is clicked.

### In Practice

Setting up your components in this way makes extending their behaviour
incredibly straightforward.

Consider a scenario where you wish to group multiple options under a 'main'
check box, so you can turn them all on/off at once.

![Showing check boxes connected to Value objects.](Master-Check-Box-Dark.svg#only-dark)
![Showing check boxes connected to Value objects.](Master-Check-Box-Light.svg#only-light)

The appearance of that check box would not be controlled by a single state, but
instead reflects the combination of multiple states. Because the code uses
`UsedAs`, you can represent this with a `Computed` object.

```Lua hl_lines="7-18"
local playMusic = scope:Value(true)
local playSFX = scope:Value(false)
local playNarration = scope:Value(true)

local checkBox = scope:CheckBox {
    Text = "Play sounds",
    IsChecked = scope:Computed(function(use)
        local anyChecked = use(playMusic) or use(playSFX) or use(playNarration)
        local allChecked = use(playMusic) and use(playSFX) and use(playNarration)

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

You can then implement the 'check all'/'uncheck all' behaviour inside `OnClick`:

```Lua hl_lines="7-13"
local playMusic = scope:Value(true)
local playSFX = scope:Value(false)
local playNarration = scope:Value(true)

local checkBox = scope:CheckBox {
    -- ... same properties as before ...
    OnClick = function()
        local allChecked = peek(playMusic) and peek(playSFX) and peek(playNarration)

        playMusic:set(not allChecked)
        playSFX:set(not allChecked)
        playNarration:set(not allChecked)
    end
}
```

Because the check box was written to be flexible, it can handle complex usage
easily.

-----

## Best Practices

Those examples lead us to the golden rule of reusable components:

!!! tip "Golden Rule"
    Reusable components should *reflect* program state. They should
    not *control* program state.

At the bottom of the chain of control, components shouldn't be massively
responsible. At these levels, reflective components are easier to work with.

As you go up the chain of control, components get broader in scope and less
reusable; those places are often suitable for controlling components.

A well-balanced codebase places controlling components at key, strategic
locations. They allow higher-up components to operate without special knowledge
about what goes on below.

At first, this might be difficult to do well, but with experience you'll have a
better intuition for it. Remember that you can always rewrite your code if it
becomes a problem!