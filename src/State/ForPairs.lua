--!strict

--[[
	Constructs a new For object which maps pairs of a table using a `processor`
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
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForPairs<KI, KO, VI, VO, S>(
	scope: PubTypes.Scope<S>,
	inputTable: PubTypes.CanBeState<{[KI]: VI}>,
	processor: (PubTypes.Scope<S>, PubTypes.Use, KI, VI) -> (KO, VO),
	destructor: any?
): Types.For<KI, KO, VI, VO>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForPairs", "myScope:ForPairs(inputTable, function(scope, use, key, value) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForPairs")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: PubTypes.Scope<any>,
			inputPair: PubTypes.StateObject<{key: KI, value: VI}>
		)
			return Computed(scope, function(scope, use): {key: KO?, value: VO?}
				local ok, key, value = xpcall(processor, parseError, scope, use, use(inputPair).key, use(inputPair).value)
				if ok then
					return {key = key, value = value}
				else
					logErrorNonFatal("forProcessorError", key :: any)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
		end
	)
end

return ForPairs