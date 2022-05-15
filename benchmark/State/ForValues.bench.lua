local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.Core.Value)
local ForValues = require(Package.State.ForValues)

local function callback()
	return true
end

local function constantOutput(val)
	return val
end

local function dynamicOutput(val)
	return {val}
end

return {
	{
		name = "ForValues with blank input table",
		calls = 20000,

		run = function()
			ForValues({}, callback)
		end,
	},

	{
		name = "ForValues with input table - constant output",
		calls = 20000,

		run = function()
			ForValues({ 1 }, constantOutput)
		end,
	},

	{
		name = "ForValues with input table - dynamic output",
		calls = 20000,

		run = function()
			ForValues({ 1 }, dynamicOutput)
		end,
	},


	{
		name = "ForValues with input state - constant output",
		calls = 20000,

		run = function()
			ForValues(Value({ 1 }), constantOutput)
		end,
	},

	{
		name = "ForValues with input state - dynamic output",
		calls = 20000,

		run = function()
			ForValues(Value({ 1 }), dynamicOutput)
		end,
	},

	{
		name = "ForValues with changed input table - constant output",
		calls = 20000,

		run = function()
			local computed = ForValues({ 1 }, constantOutput)
			computed.__inputTable = { 2 }
			computed:update()
		end,
	},

	{
		name = "ForValues with changed input table - dynamic output",
		calls = 20000,

		run = function()
			local computed = ForValues({ 1 }, dynamicOutput)
			computed.__inputTable = { 2 }
			computed:update()
		end,
	},

	{
		name = "ForValues with changed input state - constant output",
		calls = 20000,

		run = function()
			local state = Value({ 1 })
			ForValues(state, constantOutput)
			state:set({ 2 })
		end,
	},

	{
		name = "ForValues with changed input state - dynamic output",
		calls = 20000,

		run = function()
			local state = Value({ 1 })
			ForValues(state, dynamicOutput)
			state:set({ 2 })
		end,
	},
}
