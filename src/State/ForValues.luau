--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new For object which maps values of a table using a `processor`
	function.

	Optionally, a `destructor` function can be specified for cleaning up output.

	Additionally, a `meta` table/value can optionally be returned to pass data
	created when running the processor to the destructor when the created object
	is cleaned up.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- State
local For = require(Package.State.For)
local Computed = require(Package.State.Computed)
-- Logging
local parseError = require(Package.Logging.parseError)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForValues<K, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[K]: VI}>,
	processor: (Types.Use, Types.Scope<S>, VI) -> VO,
	destructor: unknown?
): Types.For<K, VO>
	if typeof(inputTable) == "function" then
		External.logError("scopeMissing", nil, "ForValues", "myScope:ForValues(inputTable, function(use, scope, value) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "ForValues")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			inputPair: Types.StateObject<{key: K, value: VI}>
		)
			local inputValue = Computed(scope, function(use, scope): VI
				return use(inputPair).value
			end)
			return Computed(scope, function(use, scope): {key: nil, value: VO?}
				local ok, value = xpcall(processor, parseError, use, scope, use(inputValue))
				if ok then
					return {key = nil, value = value}
				else
					local errorObj = (value :: any) :: Types.Error
					External.logErrorNonFatal("callbackError", errorObj)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
		end
	)
end

return ForValues