local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.Core.Value)
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

		run = function()
			ForKeys({ ["Foo"] = "bar" }, constantOutput)
		end,
	},

	{
		name = "ForKeys with input table - dynamic output",
		calls = 20000,

		run = function()
			ForKeys({ ["Foo"] = "bar" }, dynamicOutput)
		end,
	},


	{
		name = "ForKeys with input state - constant output",
		calls = 20000,

		run = function()
			ForKeys(Value({ ["Foo"] = "bar" }), constantOutput)
		end,
	},

	{
		name = "ForKeys with input state - dynamic output",
		calls = 20000,

		run = function()
			ForKeys(Value({ ["Foo"] = "bar" }), dynamicOutput)
		end,
	},

	{
		name = "ForKeys with changed input table - constant output",
		calls = 20000,

		run = function()
			local computed = ForKeys({ ["Foo"] = "bar" }, constantOutput)
			computed.__inputTable = { ["Bar"] = "foo" }
			computed:update()
		end,
	},

	{
		name = "ForKeys with changed input table - dynamic output",
		calls = 20000,

		run = function()
			local computed = ForKeys({ ["Foo"] = "bar" }, dynamicOutput)
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
