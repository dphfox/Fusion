--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new For object which maps pairs of a table using a `processor`
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

local function ForPairs<KI, KO, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
	processor: (Types.Use, Types.Scope<S>, KI, VI) -> (KO, VO),
	destructor: unknown?
): Types.For<KO, VO>
	if typeof(inputTable) == "function" then
		External.logError("scopeMissing", nil, "ForPairs", "myScope:ForPairs(inputTable, function(use, scope, key, value) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "ForPairs")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			inputPair: Types.StateObject<{key: KI, value: VI}>
		)
			return Computed(scope, function(use, scope): {key: KO?, value: VO?}
				local ok, key, value = xpcall(processor, parseError, use, scope, use(inputPair).key, use(inputPair).value)
				if ok then
					return {key = key, value = value}
				else
					local errorObj = (key :: any) :: Types.Error
					External.logErrorNonFatal("callbackError", errorObj)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
		end
	)
end

return ForPairs