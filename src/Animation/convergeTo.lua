--[[
	Adapts a converging animation curve family to converge to a goal value.
]]

-- TODO: type annotate this file

local function convergeTo(
	goalValue,
	motionFamily
)
	return function(...)
		local motionCurve = motionFamily(...)
		return function(...)
			local result = motionCurve(...)
			result[1] += goalValue
			return result
		end
	end
end

return convergeTo