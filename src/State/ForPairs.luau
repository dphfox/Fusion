--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs and returns a new For state object which processes keys and
	values in pairs.

	https://elttob.uk/Fusion/0.3/api-reference/state/members/forpairs/

	TODO: the sub objects constructed here can be more efficiently implemented
	as a dedicated state object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- State
local For = require(Package.State.For)
local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)
local ForTypes = require(Package.State.For.ForTypes)
-- Logging
local parseError = require(Package.Logging.parseError)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local SUB_OBJECT_META = {
	__index = {
		roamKeys = false,
		roamValues = false,
		invalidateInputKey = function(self): ()
			self._inputKeyState:set(self.inputKey)
		end,
		invalidateInputValue = function(self): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function(self, use)
			local pair = use(self._outputPairState)
			return pair.key, pair.value
		end
	}
}

local function SubObject<KI, KO, VI, VO, S>(
	scope: Types.Scope<S>,
	initialKey: KI,
	initialValue: VI,
	processor: (Types.Use, Types.Scope<S>, KI, VI) -> (KO, VO)
): ForTypes.SubObject<S, KI, KO, VI, VO>
	local self = {}
	self.maybeScope = scope
	self.inputKey = initialKey
	self.inputValue = initialValue
	self._inputKeyState = Value(scope, initialKey)
	self._inputValueState = Value(scope, initialValue)
	self._processor = processor
	self._outputPairState = Computed(scope, function(use, scope): {key: KO?, value: VO?}
		local inputKey = use(self._inputKeyState)
		local inputValue = use(self._inputValueState)
		local ok, outputKey, outputValue = xpcall(self._processor, parseError, use, scope, inputKey, inputValue)
		if ok then
			return {key = outputKey, value = outputValue}
		else
			local error: Types.Error = outputKey :: any
			error.context = `while processing key {tostring(inputValue)} and value {tostring(inputValue)}`
			External.logErrorNonFatal("callbackError", error)
			doCleanup(scope)
			table.clear(scope)
			return {key = nil, value = nil}
		end
	end)
	return setmetatable(self, SUB_OBJECT_META) :: any
end

local function ForPairs<KI, KO, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
	processor: (Types.Use, Types.Scope<S>, KI, VI) -> (KO, VO),
	destructor: unknown?
): Types.For<KO, VO>
	if typeof(inputTable) == "function" then
		External.logError("scopeMissing", nil, "ForPairs", "myScope:ForPairs(inputTable, function(scope, use, key, value) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "ForPairs")
	end
	return For(
		scope,
		inputTable,
		function(scope, initialKey, initialValue)
			return SubObject(scope, initialKey, initialValue, processor)
		end
	)
end

return ForPairs :: Types.ForPairsConstructor