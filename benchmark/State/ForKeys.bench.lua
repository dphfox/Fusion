local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.State.Value)
local ForKeys = require(Package.State.ForValues)

local function callback()
	return true
end

local function constantOutput(key)
	return key
end

local function dynamicOutput(key)
	return {key}
end

return {
	{
		name = "ForKeys with blank input table",
		calls = 20000,

		run = function()
			ForKeys({}, callback)
		end,
	},

	{
		name = "ForKeys with input table - constant output",
		calls = 20000,

		preRun = function()
			return { ["Foo"] = "bar" }
		end,

		run = function(set)
			ForKeys(set, constantOutput)
		end,
	},

	{
		name = "ForKeys with input table - dynamic output",
		calls = 20000,

		preRun = function()
			return { ["Foo"] = "bar" }
		end,

		run = function(set)
			ForKeys(set, dynamicOutput)
		end,
	},


	{
		name = "ForKeys with input state - constant output",
		calls = 20000,

		preRun = function()
			return Value({ ["Foo"] = "bar" })
		end,

		run = function(state)
			ForKeys(state, constantOutput)
		end,
	},

	{
		name = "ForKeys with input state - dynamic output",
		calls = 20000,

		preRun = function()
			return Value({ ["Foo"] = "bar" })
		end,

		run = function(state)
			ForKeys(state, dynamicOutput)
		end,
	},

	{
		name = "ForKeys with changed input table - constant output",
		calls = 20000,

		preRun = function()
			return { ["Foo"] = "bar" }
		end,

		run = function(set)
			local computed = ForKeys(set, constantOutput)
			computed.__inputTable = { ["Bar"] = "foo" }
			computed:update()
		end,
	},

	{
		name = "ForKeys with changed input table - dynamic output",
		calls = 20000,

		preRun = function()
			return { ["Foo"] = "bar" }
		end,

		run = function(set)
			local computed = ForKeys(set, dynamicOutput)
			computed.__inputTable = { ["Bar"] = "foo" }
			computed:update()
		end,
	},

	{
		name = "ForKeys with changed input state - constant output",
		calls = 20000,

		run = function()
			local state = Value({ ["Foo"] = "bar" })
			ForKeys(state, constantOutput)
			state:set({ ["Bar"] = "foo" })
		end,
	},

	{
		name = "ForKeys with changed input state - dynamic output",
		calls = 20000,

		run = function()
			local state = Value({ ["Foo"] = "bar" })
			ForKeys(state, dynamicOutput)
			state:set({ ["Bar"] = "foo" })
		end,
	},
}
