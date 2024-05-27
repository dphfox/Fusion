--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new For object which maps keys of a table using a `processor`
	function.

	Optionally, a `destructor` function can be specified for cleaning up output.

	Additionally, a `meta` table/value can optionally be returned to pass data
	created when running the processor to the destructor when the created object
	is cleaned up.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
<<<<<<< HEAD
local InternalTypes = require(Package.InternalTypes)
=======
local External = require(Package.External)
>>>>>>> upstream/main
-- State
local For = require(Package.State.For)
local Computed = require(Package.State.Computed)
-- Logging
local parseError = require(Package.Logging.parseError)
<<<<<<< HEAD
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
=======
>>>>>>> upstream/main
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForKeys<KI, KO, V, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: V}>,
	processor: (Types.Use, Types.Scope<S>, KI) -> KO,
	destructor: unknown?
): Types.For<KO, V>
	if typeof(inputTable) == "function" then
<<<<<<< HEAD
		logError("scopeMissing", nil, "ForKeys", "myScope:ForKeys(inputTable, function(scope, use, key) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForKeys")
=======
		External.logError("scopeMissing", nil, "ForKeys", "myScope:ForKeys(inputTable, function(scope, use, key) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "ForKeys")
>>>>>>> upstream/main
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			inputPair: Types.StateObject<{key: KI, value: V}>
		)
			local inputKey = Computed(scope, function(use, scope): KI
				return use(inputPair).key
			end)
			local outputKey = Computed(scope, function(use, scope): KO?
				local ok, key = xpcall(processor, parseError, use, scope, use(inputKey))
				if ok then
					return key
				else
<<<<<<< HEAD
					local errorObj = (key :: any) :: InternalTypes.Error
					logErrorNonFatal("callbackError", errorObj)
=======
					local errorObj = (key :: any) :: Types.Error
					External.logErrorNonFatal("callbackError", errorObj)
>>>>>>> upstream/main
					doCleanup(scope)
					table.clear(scope)
					return nil
				end
			end)
			return Computed(scope, function(use, scope)
				return {key = use(outputKey), value = use(inputPair).value}
			end)
		end
	)
end

return ForKeys