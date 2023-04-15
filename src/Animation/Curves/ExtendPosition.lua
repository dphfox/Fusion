-- TODO: type annotate this file

local function ExtendPosition(displacement)
	displacement = displacement or 0
	return function(time)
		return displacement
	end
end

return ExtendPosition