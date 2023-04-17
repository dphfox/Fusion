--[[
	Various displacement spaces for use by the animation subsystem.
]]

-- TODO: type annotate this file

local linear = {
	toDisplacement = function(position, relativeTo)
		local displacement = table.create(#position)
		for index, component in position do
			displacement[index] = component - relativeTo[index]
		end
		return displacement
	end,
	toPosition = function(displacement, relativeTo)
		local position = table.create(#displacement)
		for index, component in displacement do
			position[index] = component + relativeTo[index]
		end
		return position
	end
}

local function linearWrapped(minimum, maximum)
	assert(minimum <= maximum, "Wrapped space requires minimum value <= maximum value")
	local range = maximum - minimum
	local halfRange = range / 2
	return {
		toDisplacement = function(position, relativeTo)
			local displacement = table.create(#position)
			for index, component in position do
				displacement[index] = (component - relativeTo[index] + halfRange) % range - halfRange
			end
			return displacement
		end,
		toPosition = function(displacement, relativeTo)
			local position = table.create(#displacement)
			for index, component in displacement do
				position[index] = (component + relativeTo[index]) % range + minimum
			end
			return position
		end
	}
end

return {
	linear = linear,
	linearWrapped = linearWrapped,
	degrees = linearWrapped(0, 360),
	signedDegrees = linearWrapped(-180, 180),
	radians = linearWrapped(0, 2 * math.pi),
	signedRadians = linearWrapped(-math.pi, math.pi)
}