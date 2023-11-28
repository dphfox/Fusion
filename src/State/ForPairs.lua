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
-- Memory
local doNothing = require(Package.Memory.doNothing)

local function ForPairs<KI, KO, VI, VO, M>(
	scope: {PubTypes.Task},
	inputTable: PubTypes.CanBeState<{[KI]: VI}>,
	processor: (PubTypes.Use, KI, VI) -> (KO, VO, M?),
	destructor: (KO, VO, M?) -> ()?
): Types.For<KI, KO, VI, VO>

	return For(
		scope,
		inputTable,
		function(scope, inputKey, inputValue)
			local pair = Computed(scope, function(use)
				-- TODO: error checking
				local key, value, meta = processor(use, use(inputKey), use(inputValue))
				return {key = key, value = value}, meta
			end, function(data, meta)
				-- TODO: error checking
				destructor(data.key, meta)
			end)
			return Computed(function(use)
				return use(pair).key
			end, doNothing), Computed(function(use)
				return use(pair).value
			end, doNothing)
		end
	)
end

return ForPairs