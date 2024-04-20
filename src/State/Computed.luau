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
-- Logging
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logWarn = require(Package.Logging.logWarn)
local parseError = require(Package.Logging.parseError)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)
local never = require(Package.Utility.never)
-- State
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
local deriveScope = require(Package.Memory.deriveScope)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local scopePool = require(Package.Memory.scopePool)

export type Self<T, S> = Types.Computed<T> & {
	_oldDependencySet: {[Types.GraphObject]: unknown},
	_processor: (Types.Use, Types.Scope<S>) -> T,
	_value: T,
	_innerScope: Types.Scope<S>?
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
		logError("scopeMissing", nil, "Computeds", "myScope:Computed(function(use, scope) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "Computed")
	end
	local self = setmetatable(
		{
			scope = scope,
			dependencySet = {},
			dependentSet = {},
			_oldDependencySet = {},
			_processor = processor,
			_value = nil,
			_innerScope = nil
		}, 
		METATABLE
	)
	table.insert(scope, self)
	return self :: any
end

function class.destroy<T, S>(
	self: Self<T, S>
): ()
	if self.scope == nil then
		logError("destroyedTwice", nil, "Computed")
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
	logError("stateGetWasRemoved")
	return never()
end

function class._evaluate<T, S>(
	self: Self<T, S>
): boolean
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: S & Types.Scope<unknown>

	-- we need to create a new, empty dependency set to capture dependencies
	-- into, but in case there's an error, we want to restore our old set of
	-- dependencies. by using this table-swapping solution, we can avoid the
	-- overhead of allocating new tables each update.
	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	local innerScope = deriveScope(outerScope)
	local function use<T>(target: Types.UsedAs<T>): T
		if isState(target) then
			local target = target :: Types.StateObject<T>
			if target.scope == nil then
				logError("useAfterDestroy", nil, `The {target.kind} object`, "the Computed that is use()-ing it")
			elseif whichLivesLonger(outerScope, self, target.scope, target) == "definitely-a" then
				logWarn("possiblyOutlives", `The {target.kind} object`, "the Computed that is use()-ing it")
			end		
			self.dependencySet[target] = true
			return (target :: InternalTypes.StateObject<T>):_peek()
		else
			return target :: T
		end
	end
	local ok, newValue = xpcall(self._processor, parseError, use, innerScope)
	local innerScope = scopePool.giveIfEmpty(innerScope)

	if ok then
		local oldValue = self._value
		local similar = isSimilar(oldValue, newValue)
		if self._innerScope ~= nil then
			doCleanup(self._innerScope)
			scopePool.clearAndGive(self._innerScope)
		end
		self._value = newValue
		self._innerScope = innerScope

		-- add this object to the dependencies' dependent sets
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return not similar
	else
		local errorObj = (newValue :: any) :: InternalTypes.Error
		-- this needs to be non-fatal, because otherwise it'd disrupt the
		-- update process
		logErrorNonFatal("callbackError", errorObj)

		if innerScope ~= nil then
			doCleanup(innerScope)
			scopePool.clearAndGive(self._innerScope :: any)
			self._innerScope = nil
		end

		-- restore old dependencies, because the new dependencies may be corrupt
		self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

		-- restore this object in the dependencies' dependent sets
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return false
	end
end

function class:_peek(): unknown
	local self = self :: InternalTypes.Computed<unknown, unknown>
	return self._value
end

return Computed