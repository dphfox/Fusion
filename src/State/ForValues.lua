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

local function ForValues<K, VI, VO, M>(
	scope: {PubTypes.Task},
	inputTable: PubTypes.CanBeState<{[K]: VI}>,
	processor: (PubTypes.Use, VI) -> (VO, M?),
	destructor: (VO, M?) -> ()?
): Types.For<K, K, VI, VO>

	return For(
		scope,
		inputTable,
		function(scope, _, inputValue)
			return nil, Computed(scope, function(use)
				local ok, value, meta = xpcall(processor, parseError, use, use(inputValue))
				if ok then
					return value, meta
				else
					logErrorNonFatal("forProcessorError", parseError)
					return nil
				end
			end, destructor)
		end
	)
end

return ForValues