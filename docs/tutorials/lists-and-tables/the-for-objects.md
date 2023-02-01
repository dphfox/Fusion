Often when building UI, you need to deal with lists, arrays and tables. For
example:

- creating an array of TextLabels for a player list
- generating a settings page from pairs of keys and values in a configuration
- filling a grid with inventory slots and items

Most of these use cases involve processing one table into another:

- converting an array of player names into an array of TextLabels
- converting a table of settings into a table of UI controls
- converting an array of inventory items into an array of slot UIs

So, to assist with these use cases, Fusion has a few state objects which are
specially designed for working with arrays and tables. These are known as the
`For` objects.

-----

## The Problem

To start, let's try making a player list using the basic state objects from
before. Let's define a changeable list of player names and some basic UI:

```Lua linenums="1"
local playerNames = Value({"Elttob", "boatbomber", "thisfall", "AxisAngles"})

local textLabels = {} -- TODO: implement this

local ui = New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,

    [Children] = New "Frame" {
        Name = "PlayerList",

        Position = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.fromOffset(200, 0),
        AutomaticSize = "Y",

        [Children] = {
            New "UIListLayout" {
                SortOrder = "Name"
            },
            textLabels
        }
    }
}
```

Now, let's make a `Computed` which generates that list of text labels for us:

```Lua linenums="1" hl_lines="3-13"
local playerNames = Value({"Elttob", "boatbomber", "thisfall", "AxisAngles"})

local textLabels = Computed(function()
    local out = {}
    for index, playerName in playerNames:get() do
        out[index] = New "TextLabel" {
            Name = playerName,
            Size = UDim2.new(1, 0, 0, 50),
            Text = playerName
        }
    end
    return out
end, Fusion.cleanup)

local ui = New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,
```

This is alright, but there are a few problems:

- Firstly, there's a fair amount of boilerplate - in order to generate the list
of text labels, you have to create a `Computed`, initialise a new table, write a
for-loop to populate the table, then return it.
    - Boilerplate is generally annoying, and especially so for a task as common
    as dealing with lists and tables. It's less clear to read and more tedious
    to write.
- Secondly, whenever `playerNames` is changed, you reconstruct the entire list,
destroying all of your instances and any data associated with them. This is both
inefficient and also causes issues with data loss.
    - Ideally, you should only modify the text labels for players that have
    joined or left, leaving the rest of the text labels alone.

To address this shortcoming, the `For` objects provide a cleaner way to do the
same thing, except with less boilerplate and leaving unchanged values alone:

```Lua linenums="1" hl_lines="3-9"
local playerNames = Value({"Elttob", "boatbomber", "thisfall", "AxisAngles"})

local textLabels = ForValues(playerNames, function()
    return New "TextLabel" {
        Name = playerName,
        Size = UDim2.new(1, 0, 0, 50),
        Text = playerName
    }
end, Fusion.cleanup)

local ui = New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,
```

Over the next few pages, we'll take a look at three state objects:

- `ForValues`, which lets you process just the values in a table.
- `ForKeys`, which lets you process just the keys in a table.
- `ForPairs`, which lets you do both at the same time.