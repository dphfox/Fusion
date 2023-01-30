`ForKeys` is a state object that creates a new table by processing keys from
another table.

The input table can be a state object, and the output keys can use state objects.

```Lua
local data = {Red = "foo", Blue = "bar"}
local prefix = Value("Key_")

local renamed = ForKeys(data, function(key)
	return prefix:get() .. key
end)

print(renamed:get()) --> {Key_Red = "foo", Key_Blue = "bar"}

prefix:set("colour")
print(renamed:get()) --> {colourRed = "foo", colourBlue = "bar"}
```

-----

## Usage

To use `ForKeys` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local ForKeys = Fusion.ForKeys
```

### Basic Usage

To create a new `ForKeys` object, call the constructor with an input table and
a processor function:

```Lua
local data = {red = "foo", blue = "bar"}
local renamed = ForKeys(data, function(key)
	return string.upper(key)
end)
```

This will generate a new table, where each key is replaced using the processor
function. You can get the table using the `:get()` method:

```Lua hl_lines="6"
local data = {red = "foo", blue = "bar"}
local renamed = ForKeys(data, function(key)
	return string.upper(key)
end)

print(renamed:get()) --> {RED = "foo", BLUE = "bar"}
```

### State Objects

The input table can be provided as a state object instead, and the output table
will update as the input table is changed:

```Lua
local playerSet = Value({})
local userIdSet = ForKeys(playerSet, function(player)
	return player.UserId
end)

playerSet:set({ [Players.Elttob] = true })
print(userIdSet:get()) --> {[1670764] = true}

playerSet:set({ [Players.boatbomber] = true, [Players.EgoMoose] = true })
print(userIdSet:get()) --> {[33655127] = true, [2155311] = true}
```

Additionally, you can use state objects in your calculations, just like a
computed:

```Lua
local playerSet = { [Players.boatbomber] = true, [Players.EgoMoose] = true }
local prefix = Value("User_")
local userIdSet = ForKeys(playerSet, function(player)
	return prefix .. player.UserId
end)

print(userIdSet:get()) --> {User_33655127 = true, User_2155311 = true}

prefix:set("player")
print(userIdSet:get()) --> {player33655127 = true, player2155311 = true}
```

### Cleanup Behaviour

Similar to computeds, if you want to run your own code when values are removed,
you can pass in a second 'destructor' function:

```Lua hl_lines="15-19"
local eventSet = Value({
	[RunService.RenderStepped] = true,
	[RunService.Heartbeat] = true
})

local connectionSet = ForKeys(eventSet, 
	-- processor
	function(event)
		local eventName = tostring(event)
		local connection = event:Connect(function(...)
			print(eventName, "fired with arguments:", ...)
		end)
		return connection
	end,
	-- destructor
	function(connection)
		print("Disconnecting the event!")
		connection:Disconnect() -- don't forget we're overriding the default cleanup
	end
)

-- remove Heartbeat from the event set
-- this will run the destructor with the Heartbeat connection
eventSet:set({ [RunService.RenderStepped] = true }) --> Disconnecting the event!
```

When using a custom destructor, you can send one extra return value to your
destructor without including it in the output table:

```Lua hl_lines="13 16"
local eventSet = Value({
	[RunService.RenderStepped] = true,
	[RunService.Heartbeat] = true
})

local connectionSet = ForKeys(eventSet, 
	-- processor
	function(event)
		local eventName = tostring(event)
		local connection = event:Connect(function(...)
			print(eventName, "fired with arguments:", ...)
		end)
		return connection, eventName
	end,
	-- destructor
	function(connection, eventName)
		print("Disconnecting " .. eventName .. "!")
		connection:Disconnect()
	end
)

eventSet:set({ [RunService.RenderStepped] = true }) --> Disconnecting Signal Heartbeat!
```

-----

## Optimisations

!!! help "Optional"
	You don't have to memorise these optimisations to use `ForKeys`, but it
	can be helpful if you have a performance problem.

Rather than creating a new output table from scratch every time the input table
is changed, `ForKeys` will try and reuse as much as possible to improve
performance.

For example, let's say we're converting an array to a dictionary:

```Lua
local array = Value({"Fusion", "Knit", "Matter"})
local dict = ForKeys(array, function(index)
	return "Value" .. index
end)

print(dict:get()) --> {Value1 = "Fusion", Value2 = "Knit", Value3 = "Matter"}
```

Because `ForKeys` only operates on the keys, changing the values in the array
doesn't affect the keys. Keys are only added or removed as needed:

```Lua
local array = Value({"Fusion", "Knit", "Matter"})
local dict = ForKeys(array, function(index)
	return "Value" .. index
end)

print(dict:get()) --> {Value1 = "Fusion", Value2 = "Knit", Value3 = "Matter"}

array:set({"Roact", "Rodux"})
print(dict:get()) --> {Value1 = "Roact", Value2 = "Rodux"}
```

`ForKeys` takes advantage of this - when a value changes, it's copied into the
output table without recalculating the key. Keys are only calculated when a
value is assigned to a new key.