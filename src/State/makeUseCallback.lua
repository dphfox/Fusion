--!strict

--[[
	Constructs a 'use callback' for the purposes of collecting dependencies.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local xtypeof = require(Package.Utility.xtypeof)

type Set<T> = {[T]: any}

local function makeUseCallback(dependencySet: Set<PubTypes.Dependency>)
	local function use<T>(target: PubTypes.CanBeState<T>): T
		if xtypeof(target) == "State" then
			dependencySet[target] = true
			return (target :: Types.StateObject<T>):_peek()
		else
			return target
		end
	end
	return use
end

return makeUseCallback