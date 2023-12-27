--!strict

--[[
	Creates cleanup tables with access to constructors as methods.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function merge(
	into: any,
	from: any?,
	...: any
): any
	if from == nil then
		return into
	else
		for key, value in from do
			if into[key] == nil then
				into[key] = value
			else
				logError("mergeConflict", nil, tostring(key))
			end
		end
		return merge(into, ...)
	end
end

local function scoped(
	...: any
): any
	return setmetatable({}, {__index = merge({}, ...)}) :: any
end

-- Is there a sane way to write out this type?
-- ... I sure hope so.

return (scoped :: any) ::
	(() -> PubTypes.Scope<{}>) &
	(<A>(A & {}) -> PubTypes.Scope<A>) &
	(<A, B>(A & {}, B & {}) -> PubTypes.Scope<A & B>) &
	(<A, B, C>(A & {}, B & {}, C & {}) -> PubTypes.Scope<A & B & C>) &
	(<A, B, C, D>(A & {}, B & {}, C & {}, D & {}) -> PubTypes.Scope<A & B & C & D>) &
	(<A, B, C, D, E>(A & {}, B & {}, C & {}, D & {}, E & {}) -> PubTypes.Scope<A & B & C & D & E>) &
	(<A, B, C, D, E, F>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> PubTypes.Scope<A & B & C & D & E & F>) &
	(<A, B, C, D, E, F, G>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> PubTypes.Scope<A & B & C & D & E & F & G>) &
	(<A, B, C, D, E, F, G, H>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> PubTypes.Scope<A & B & C & D & E & F & G & H>) &
	(<A, B, C, D, E, F, G, H, I>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> PubTypes.Scope<A & B & C & D & E & F & G & H & I>) &
	(<A, B, C, D, E, F, G, H, I, J>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> PubTypes.Scope<A & B & C & D & E & F & G & H & I & J>) &
	(<A, B, C, D, E, F, G, H, I, J, K>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> PubTypes.Scope<A & B & C & D & E & F & G & H & I & J & K>) &
	(<A, B, C, D, E, F, G, H, I, J, K, L>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> PubTypes.Scope<A & B & C & D & E & F & G & H & I & J & K & L>)