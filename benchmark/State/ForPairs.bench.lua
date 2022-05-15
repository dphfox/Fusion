local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.Core.Value)
local ForPairs = require(Package.State.ForValues)

local function callback()
	return true
end

local function constantOutput(key, value)
	return key, value
end

local function dynamicOutput(key, value)
	return {key}, {value}
end

return {
	{
		name = "ForPairs with blank input table",
		calls = 20000,

		run = function()
			ForPairs({}, callback)
		end,
	},

	{
		name = "ForPairs with input table - constant output",
		calls = 20000,
		run = function()
			ForPairs({ ["Foo"] = "bar" }, constantOutput)
		end,
	},

	{
		name = "ForPairs with input table - dynamic output",
		calls = 20000,

		run = function()
			ForPairs({ ["Foo"] = "bar" }, dynamicOutput)
		end,
	},

	{
		name = "ForPairs with input state - constant output",
		calls = 20000,

		run = function()
			ForPairs(Value({ ["Foo"] = "bar" }), constantOutput)
		end,
	},

	{
		name = "ForPairs with input state - dynamic output",
		calls = 20000,

		run = function()
			ForPairs(Value({ ["Foo"] = "bar" }), dynamicOutput)
		end,
	},

	{
		name = "ForPairs with changed input table - constant output",
		calls = 20000,

		run = function()
			local computed = ForPairs({ ["Foo"] = "bar" }, constantOutput)
			computed.__inputTable = { ["Bar"] = "foo" }
			computed:update()
		end,
	},

	{
		name = "ForPairs with changed input table - dynamic output",
		calls = 20000,

		run = function()
			local computed = ForPairs({ ["Foo"] = "bar" }, dynamicOutput)
			computed.__inputTable = { ["Bar"] = "foo" }
			computed:update()
		end,
	},

	{
		name = "ForPairs with changed input state - constant output",
		calls = 20000,

		run = function()
			local state = Value({ ["Foo"] = "bar" })
			ForPairs(state, constantOutput)
			state:set({ ["Bar"] = "foo" })
		end,
	},

	{
		name = "ForPairs with changed input state - dynamic output",
		calls = 20000,

		run = function()
			local state = Value({ ["Foo"] = "bar" })
			ForPairs(state, dynamicOutput)
			state:set({ ["Bar"] = "foo" })
		end,
	},
}
