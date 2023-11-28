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
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForPairs<KI, KO, VI, VO, S>(
	scope: PubTypes.Scope<S>,
	inputTable: PubTypes.CanBeState<{[KI]: VI}>,
	processor: (PubTypes.Scope<S>, PubTypes.Use, KI, VI) -> (KO, VO)
): Types.For<KI, KO, VI, VO>

	return For(
		scope,
		inputTable,
		function(scope, inputKey, inputValue)
			local pair = Computed(scope, function(scope, use)
				local ok, key, value = xpcall(processor, parseError, scope, use, use(inputKey), use(inputValue))
				if ok then
					return {key = key, value = value}
				else
					logErrorNonFatal("forProcessorError", parseError)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
			return Computed(scope, function(_, use)
				return use(pair).key
			end), Computed(scope, function(_, use)
				return use(pair).value
			end)
		end
	)
end

return ForPairs