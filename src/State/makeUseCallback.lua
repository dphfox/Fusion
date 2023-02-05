--!strict

--[[
	Constructs a 'use callback' for the purposes of collecting dependencies.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local xtypeof = require(Package.Utility.xtypeof)

local function makeUseCallback(owner: PubTypes.Dependent)
	local function use<T>(target: PubTypes.CanBeState<T>): T
		if xtypeof(target) == "State" then
			owner.dependencySet[target] = true
			return (target :: Types.StateObject<T>):_peek()
		else
			return target
		end
	end
	return use
end

return makeUseCallback