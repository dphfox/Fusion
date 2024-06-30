--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Memory
local checkLifetime = require(Package.Memory.checkLifetime)
-- State
local castToState = require(Package.State.castToState)

return {
	type = "SpecialKey",
	kind = "Ref",
	stage = "observer",
	apply = function(
		self: Types.SpecialKey,
		scope: Types.Scope<unknown>,
		value: unknown,
		applyTo: Instance
	)
		if not castToState(value) then
			External.logError("invalidRefType")
		end
		local value = value :: Types.StateObject<unknown>
		if value.kind ~= "Value" then
			External.logError("invalidRefType")
		end
		local value = value :: Types.Value<unknown>
		checkLifetime.bOutlivesA(
			scope, applyTo, 
			value.scope, value.oldestTask,
			checkLifetime.formatters.refOutputsTo
		)

		value:set(applyTo)
	end
} :: Types.SpecialKey