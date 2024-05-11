--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs and returns a new For state object which processes keys and
	preserves values.

	https://elttob.uk/Fusion/0.3/api-reference/state/members/forkeys/
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- State
local For = require(Package.State.For)
local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)
local ForTypes = require(Package.State.For.ForTypes)
-- Logging
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)

local function ForKeys<KI, KO, V, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: V}>,
	processor: (Types.Use, Types.Scope<S>, KI) -> KO,
	destructor: unknown?
): Types.For<KO, V>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForKeys", "myScope:ForKeys(inputTable, function(scope, use, key) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForKeys")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			initialKey: KI,
			initialValue: V
		): ForTypes.SubObject<S, KI, KO, V, V>
			local inputKey = Value(scope, initialKey)
			local inputValue = Value(scope, initialValue)
			local outputKey = Computed(scope, function(use, scope)
				return processor(use, scope, use(inputKey))
			end)
			return {
				maybeScope = scope,
				inputKey = initialKey,
				inputValue = initialValue,
				roamKeys = false,
				roamValues = true,
				invalidateInputKey = function(self): ()
					inputKey:set(self.inputKey)
				end,
				invalidateInputValue = function(self): ()
					inputValue:set(self.inputValue)
				end,
				useOutputPair = function(self, use): (KO, V)
					return use(outputKey), self.inputValue
				end
			}
		end
	)
end

return ForKeys