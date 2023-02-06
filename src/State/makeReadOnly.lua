--!strict

--[[
	A wrapper function which makes a Value object read-only.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Value = require(Package.State.Value)
local xtypeof = require(Package.Utility.xtypeof)

function makeReadOnly(value: PubTypes.CanBeState<T>): T
	if xtypeof(value) == "State" then
		value._readOnly = true
		return value
	else
		local wrapped = Value(value)
		wrapped._readOnly = true

		return wrapped
	end
end