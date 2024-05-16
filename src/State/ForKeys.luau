--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs and returns a new For state object which processes keys and
	preserves values.

	https://elttob.uk/Fusion/0.3/api-reference/state/members/forkeys/

	TODO: the sub objects constructed here can be more efficiently implemented
	as a dedicated state object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
-- State
local For = require(Package.State.For)
local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)
local ForTypes = require(Package.State.For.ForTypes)
-- Logging
local parseError = require(Package.Logging.parseError)

local SUB_OBJECT_META = {
	__index = {
		roamKeys = false,
		roamValues = true,
		invalidateInputKey = function(self): ()
			self._inputKeyState:set(self.inputKey)
		end,
		invalidateInputValue = function(self): ()
			-- do nothing
		end,
		useOutputPair = function(self, use)
			return use(self._outputKeyState), self.inputValue
		end
	}
}

local function SubObject<KI, KO, V, S>(
	scope: Types.Scope<S>,
	initialKey: KI,
	initialValue: V,
	processor: (Types.Use, Types.Scope<S>, KI) -> KO
): ForTypes.SubObject<S, KI, KO, V, V>
	local self = {}
	self.maybeScope = scope
	self.inputKey = initialKey
	self.inputValue = initialValue
	self._inputKeyState = Value(scope, initialKey)
	self._processor = processor
	self._outputKeyState = Computed(scope, function(use, scope): KO?
		local inputKey = use(self._inputKeyState)
		local ok, outputKey = xpcall(self._processor, parseError, use, scope, inputKey)
		if ok then
			return outputKey
		else
			local error: Types.Error = outputKey :: any
			error.context = `while processing key {tostring(inputKey)}`
			External.logErrorNonFatal("callbackError", error)
			doCleanup(scope)
			table.clear(scope)
			return nil
		end
	end)
	return setmetatable(self, SUB_OBJECT_META) :: any
end

local function ForKeys<KI, KO, V, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: V}>,
	processor: (Types.Use, Types.Scope<S>, KI) -> KO,
	destructor: unknown?
): Types.For<KO, V>
	if typeof(inputTable) == "function" then
		External.logError("scopeMissing", nil, "ForKeys", "myScope:ForKeys(inputTable, function(scope, use, key) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "ForKeys")
	end
	return For(
		scope, 
		inputTable, 
		function(scope, initialKey, initialValue)
			return SubObject(scope, initialKey, initialValue, processor)
		end
	)
end

return ForKeys :: Types.ForKeysConstructor