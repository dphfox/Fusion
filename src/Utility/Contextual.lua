--!strict
--!nolint LocalShadow

--[[
    Time-based contextual values, to allow for transparently passing values down
	the call stack.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
local parseError = require(Package.Logging.parseError)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Returns the current value of this contextual.
]]
function class:now(): unknown
	local thread = coroutine.running()
	local value = self._valuesNow[thread]
	if typeof(value) ~= "table" then
		return self._defaultValue
	else
		local value: {value: unknown} = value :: any
		return value.value
	end
end

--[[
	Temporarily assigns a value to this contextual.
]]
function class:is(
	newValue: unknown
)
	local methods = {}
	-- Methods use colon `:` syntax for consistency and autocomplete but we
	-- actually want them to operate on the `self` from this outer lexical scope
	local contextual = self
	
	function methods:during<T, A...>(
		callback: (A...) -> T,
		...: A...
	): T
		local thread = coroutine.running()
		local prevValue = contextual._valuesNow[thread]
		-- Storing the value in this format allows us to distinguish storing
		-- `nil` from not calling `:during()` at all.
		contextual._valuesNow[thread] = { value = newValue }
		local ok, value = xpcall(callback, parseError, ...)
		contextual._valuesNow[thread] = prevValue
		if ok then
			return value
		else
			logError("contextualCallbackError", value)
		end
	end

	return methods
end

local function Contextual<T>(
	defaultValue: T
): Types.Contextual<T>
	local self = setmetatable({
		type = "Contextual",
		-- if we held strong references to threads here, then if a thread was
		-- killed before this contextual had a chance to finish executing its
		-- callback, it would be held strongly in this table forever
		_valuesNow = setmetatable({}, WEAK_KEYS_METATABLE),
		_defaultValue = defaultValue
	}, CLASS_METATABLE)

	return self
end

return Contextual