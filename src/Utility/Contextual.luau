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
local External = require(Package.External)
-- Logging
local parseError = require(Package.Logging.parseError)

export type Self<T> = Types.Contextual<T> & {
	_valuesNow: {[thread]: {value: T}},
	_defaultValue: T
}

local class = {}
class.type = "Contextual"

local METATABLE = table.freeze {__index = class}
local WEAK_KEYS_METATABLE = table.freeze {__mode = "k"}

local function Contextual<T>(
	defaultValue: T
): Types.Contextual<T>
	local self: Self<T> = setmetatable(
		{
			-- if we held strong references to threads here, then if a thread was
			-- killed before this contextual had a chance to finish executing its
			-- callback, it would be held strongly in this table forever
			_valuesNow = setmetatable({}, WEAK_KEYS_METATABLE),
			_defaultValue = defaultValue
		}, 
		METATABLE
	) :: any

	return self
end

--[[
	Returns the current value of this contextual.
]]
function class.now<T>(
	self: Self<T>
): T
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
function class.is<T>(
	self: Self<T>,
	newValue: T
)
	local methods = {}
	
	function methods.during<T, A...>(
		_: any, -- during is called with colon syntax but we don't care
		callback: (A...) -> T,
		...: A...
	): T
		local thread = coroutine.running()
		local prevValue = self._valuesNow[thread]
		-- Storing the value in this format allows us to distinguish storing
		-- `nil` from not calling `:during()` at all.
		self._valuesNow[thread] = { value = newValue }
		local ok, value = xpcall(callback, parseError, ...)
		self._valuesNow[thread] = prevValue
		if not ok then
			External.logError("callbackError", value :: any)
		end
		return value
	end

	return methods
end

table.freeze(class)
return Contextual