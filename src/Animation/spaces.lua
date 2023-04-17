--[[
	Various displacement spaces for use by the animation subsystem.
]]

-- TODO: type annotate this file

local spaces = {}

spaces.makeCompositeSpace = function(ranges)
	local dimension = 0
	for _, data in ranges do
		dimension = math.max(dimension, data.to)
	end
	return {
		toDisplacement = function(position, relativeTo)
			local displacement = {}
			for _, rangeInfo in ranges do
				local subPosition = table.move(position, rangeInfo.from, rangeInfo.to, 1, {})
				local subRelativeTo = table.move(relativeTo, rangeInfo.from, rangeInfo.to, 1, {})
				local subDisplacement = rangeInfo.space.toDisplacement(subPosition, subRelativeTo)
				table.move(subDisplacement, 1, rangeInfo.to - rangeInfo.from + 1, rangeInfo.from, displacement)
			end
			return displacement
		end,
		toPosition = function(displacement, relativeTo)
			local position = {}
			for _, rangeInfo in ranges do
				local subDisplacement = table.move(displacement, rangeInfo.from, rangeInfo.to, 1, {})
				local subRelativeTo = table.move(relativeTo, rangeInfo.from, rangeInfo.to, 1, {})
				local subPosition = rangeInfo.space.toPosition(subDisplacement, subRelativeTo)
				table.move(subPosition, 1, rangeInfo.to - rangeInfo.from + 1, rangeInfo.from, position)
			end
			return position
		end
	}
end

spaces.linear = {
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

spaces.linearWrapped = function(minimum, maximum)
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

spaces.degrees = spaces.linearWrapped(0, 360)
spaces.signedDegrees = spaces.linearWrapped(-180, 180)
spaces.radians = spaces.linearWrapped(0, 2 * math.pi)
spaces.signedRadians = spaces.linearWrapped(-math.pi, math.pi)

spaces.quaternion = {
	toDisplacement = function(position, relativeTo)
		local displacement = table.create(#position)
		for index, component in position do
			displacement[index] = component -- TODO: how do you do this?
		end
		return displacement
	end,
	toPosition = function(displacement, relativeTo)
		local position = table.create(#displacement)
		for index, component in displacement do
			position[index] = component -- TODO: how do you do this?
		end
		return position
	end
}

return spaces