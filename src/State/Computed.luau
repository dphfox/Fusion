--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A specialised state object for tracking single values computed from a
	user-defined computation.

	https://elttob.uk/Fusion/0.3/api-reference/state/types/computed/
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Logging
local parseError = require(Package.Logging.parseError)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)
local never = require(Package.Utility.never)
local nameOf = require(Package.Utility.nameOf)
-- Graph
local depend = require(Package.Graph.depend)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
local deriveScope = require(Package.Memory.deriveScope)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local scopePool = require(Package.Memory.scopePool)

type Self<T, S> = Types.Computed<T> & {
	_innerScope: Types.Scope<S>?,
	_processor: (Types.Use, Types.Scope<S>) -> T
}

local class = {}
class.type = "State"
class.kind = "Computed"
class.timeliness = "lazy"

local METATABLE = {__index = class}

local function Computed<T, S>(
	scope: S & Types.Scope<unknown>,
	processor: (Types.Use, S) -> T,
	destructor: unknown?
): Self<T, S>
	if typeof(scope) == "function" then
		External.logError("scopeMissing", nil, "Computeds", "myScope:Computed(function(use, scope) ... end)")
	elseif destructor ~= nil then
		External.logWarn("destructorRedundant", "Computed")
	end
	local self: Self<T, S> = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = nil,
			_innerScope = nil,
			_processor = processor
		}, 
		METATABLE
	) :: any
	table.insert(scope, self)
	return self
end

function class.destroy<T, S>(
	self: Self<T, S>
): ()
	if self.scope == nil then
		External.logError("destroyedTwice", nil, "Computed")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	if self._innerScope ~= nil then
		doCleanup(self._innerScope)
		scopePool.clearAndGive(self._innerScope)
	end
end

function class.get<T, S>(
	_self: Self<T, S>
): never
	External.logError("stateGetWasRemoved")
	return never()
end

function class._evaluate<T, S>(
	self: Self<T, S>
): boolean
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: S & Types.Scope<unknown>
	local innerScope = deriveScope(outerScope)
	local function use<T>(target: Types.UsedAs<T>): T
		local targetState = castToState(target)
		if targetState ~= nil then
			if targetState.scope == nil then
				External.logError("useAfterDestroy", nil, `The {nameOf(targetState, "used")} object`, "the Computed that is use()-ing it")
			elseif whichLivesLonger(outerScope, self, targetState.scope, targetState) == "definitely-a" then
				External.logWarn("possiblyOutlives", `The {nameOf(targetState, "used")} object`, "the Computed that is use()-ing it")
			end		
			depend(self, targetState)
		end
		return peek(target)
	end
	local ok, newValue = xpcall(self._processor, parseError, use, innerScope)
	local innerScope = scopePool.giveIfEmpty(innerScope)
	if ok then
		local similar = isSimilar(self._EXTREMELY_DANGEROUS_usedAsValue, newValue)
		if self._innerScope ~= nil then
			doCleanup(self._innerScope)
			scopePool.clearAndGive(self._innerScope)
		end
		self._EXTREMELY_DANGEROUS_usedAsValue = newValue
		self._innerScope = innerScope
		return not similar
	else
		local errorObj = (newValue :: any) :: Types.Error
		if innerScope ~= nil then
			doCleanup(innerScope)
			scopePool.clearAndGive(innerScope)
		end
		-- this needs to be non-fatal, because otherwise it'd disrupt the
		-- update process
		External.logErrorNonFatal("callbackError", errorObj)
		return false
	end
end

return Computed :: Types.ComputedConstructor