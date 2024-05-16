--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs and returns a new For state object which processes values and
	preserves keys.

	https://elttob.uk/Fusion/0.3/api-reference/state/members/forvalues/

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
		roamKeys = true,
		roamValues = false,
		invalidateInputKey = function(self): ()
			-- do nothing
		end,
		invalidateInputValue = function(self): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function(self, use)
			return self.inputKey, use(self._outputValueState)
		end
	}
}

local function SubObject<K, VI, VO, S>(
	scope: Types.Scope<S>,
	initialKey: K,
	initialValue: VI,
	processor: (Types.Use, Types.Scope<S>, VI) -> VO
): ForTypes.SubObject<S, K, K, VI, VO>
	local self = {}
	self.maybeScope = scope
	self.inputKey = initialKey
	self.inputValue = initialValue
	self._inputValueState = Value(scope, initialValue)
	self._processor = processor
	self._outputValueState = Computed(scope, function(use, scope): VO?
		local inputValue = use(self._inputValueState)
		local ok, outputValue = xpcall(self._processor, parseError, use, scope, inputValue)
		if ok then
			return outputValue
		else
			local error: Types.Error = outputValue :: any
			error.context = `while processing value {tostring(inputValue)}`
			External.logErrorNonFatal("callbackError", error)
			doCleanup(scope)
			table.clear(scope)
			return nil
		end
	end)
	return setmetatable(self, SUB_OBJECT_META) :: any
end

local function ForValues<K, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[K]: VI}>,
	processor: (Types.Use, Types.Scope<S>, VI) -> VO,
	destructor: unknown?
): Types.For<K, VO>
	if typeof(inputTable) == "function" then
		External.logError("scopeMissing", nil, "ForValues", "myScope:ForValues(inputTable, function(scope, use, value) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "ForValues")
	end
	return For(
		scope,
		inputTable,
		function(scope, initialKey, initialValue)
			return SubObject(scope, initialKey, initialValue, processor)
		end
	)
end

return ForValues :: Types.ForValuesConstructor