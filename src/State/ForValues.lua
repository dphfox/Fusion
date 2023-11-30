--!strict

--[[
	Constructs a new For object which maps values of a table using a `processor`
	function.

	Optionally, a `destructor` function can be specified for cleaning up output.

	Additionally, a `meta` table/value can optionally be returned to pass data
	created when running the processor to the destructor when the created object
	is cleaned up.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
-- State
local For = require(Package.State.For)
local Computed = require(Package.State.Computed)
-- Logging
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForValues<K, VI, VO, S>(
	scope: PubTypes.Scope<S>,
	inputTable: PubTypes.CanBeState<{[K]: VI}>,
	processor: (PubTypes.Scope<S>, PubTypes.Use, VI) -> VO,
	destructor: any?
): Types.For<K, K, VI, VO>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForValues", "myScope:ForValues(inputTable, function(scope, use, value) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForValues")
	end
	return For(
		scope,
		inputTable,
		function(scope, inputPair)
			local inputValue = Computed(scope, function(scope, use)
				return use(inputPair).value
			end)
			return Computed(scope, function(scope, use)
				local ok, value = xpcall(processor, parseError, scope, use, use(inputValue))
				if ok then
					return {key = nil, value = value}
				else
					logErrorNonFatal("forProcessorError", parseError)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
		end
	)
end

return ForValues