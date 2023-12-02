--!strict

--[[
	Constructs a new For object which maps keys of a table using a `processor`
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

local function ForKeys<KI, KO, V, S>(
	scope: PubTypes.Scope<S>,
	inputTable: PubTypes.CanBeState<{[KI]: V}>,
	processor: (PubTypes.Scope<S>, PubTypes.Use, KI) -> KO,
	destructor: any?
): Types.For<KI, KO, V, V>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForKeys", "myScope:ForKeys(inputTable, function(scope, use, key) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForKeys")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: PubTypes.Scope<any>,
			inputPair: PubTypes.StateObject<{key: KI, value: V}>
		)
			local inputKey = Computed(scope, function(scope, use): KI
				return use(inputPair).key
			end)
			local outputKey = Computed(scope, function(scope, use): KO?
				local ok, key = xpcall(processor, parseError, scope, use, use(inputKey))
				if ok then
					return key
				else
					logErrorNonFatal("forProcessorError", key :: any)
					doCleanup(scope)
					table.clear(scope)
					return nil
				end
			end)
			return Computed(scope, function(scope, use)
				return {key = use(outputKey), value = use(inputPair).value}
			end)
		end
	)
end

return ForKeys