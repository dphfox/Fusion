-- TODO: type annotate this file

local function SetPosition(displacement)
	return function()
		return function(time)
			return displacement
		end
	end
end

return SetPosition