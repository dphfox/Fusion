--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
    Time-based contextual values, to allow for transparently passing values down
	the call stack.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
-- Logging
local parseError = require(Package.Logging.parseError)

local class = {}
class.type = "Contextual"

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Returns the current value of this contextual.
]]
function class:now(): unknown
	local self = self :: InternalTypes.Contextual<unknown>
	local thread = coroutine.running()
	local value = self._valuesNow[thread]
	if typeof(value) ~= "table" then
		return self._defaultValue
	else
		return value.value
	end
end

--[[
	Temporarily assigns a value to this contextual.
]]
function class:is(
	newValue: unknown
)
	-- Methods use colon `:` syntax for consistency and autocomplete but we
	-- actually want them to operate on the `self` from this outer lexical scope
	local outerSelf = self :: InternalTypes.Contextual<unknown>
	local methods = {}
	
	function methods:during<T, A...>(
		callback: (A...) -> T,
		...: A...
	): T
		local thread = coroutine.running()
		local prevValue = outerSelf._valuesNow[thread]
		-- Storing the value in this format allows us to distinguish storing
		-- `nil` from not calling `:during()` at all.
		outerSelf._valuesNow[thread] = { value = newValue }
		local ok, value = xpcall(callback, parseError, ...)
		outerSelf._valuesNow[thread] = prevValue
		if not ok then
			External.logError("callbackError", value :: any)
		end
		return value
	end

	return methods
end

local function Contextual<T>(
	defaultValue: T
): Types.Contextual<T>
	local self = setmetatable({
		-- if we held strong references to threads here, then if a thread was
		-- killed before this contextual had a chance to finish executing its
		-- callback, it would be held strongly in this table forever
		_valuesNow = setmetatable({}, WEAK_KEYS_METATABLE),
		_defaultValue = defaultValue
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Contextual<T>

	return self
end

return Contextual