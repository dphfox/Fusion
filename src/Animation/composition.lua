--[[
	Defines how to extract and work with components of different data types.
]]

-- TODO: type annotate this file

local Package = script.Parent.Parent
local spaces = require(Package.Animation.spaces)

local composition = {}

composition.number = {
	linear = {
		decompose = function(raw)
			return {raw}
		end,
		compose = function(vec)
			return vec[1]
		end,
		space = spaces.linear
	}
}
composition.number.default = composition.number.linear

composition.CFrame = {
	-- TODO: add euler composition
	-- TODO: add axis angle composition
	quaternion = {
		decompose = function(raw)
			local qx, qy, qz, qw = 0, 0, 0, 0 -- TODO: convert CFrame to quaternion here
			return {raw.X, raw.Y, raw.Z, qx, qy, qz, qw}
		end,
		compose = function(vec)
			return CFrame.new(vec[1], vec[2], vec[3], vec[4], vec[5], vec[6], vec[7])
		end,
		space = spaces.makeCompositeSpace({
			{
				from = 1,
				to = 3,
				space = spaces.linear
			},
			{
				from = 4,
				to = 7,
				space = spaces.quaternion
			}
		})
	}
}
composition.CFrame.default = composition.CFrame.quaternion

composition.Color3 = {
	-- TODO: add gamma RGB composition
	-- TODO: add linear RGB composition
	-- TODO: add perceptual composition
}
composition.Color3.default = composition.Color3.perceptual

composition.ColorSequenceKeypoint = {
	-- TODO: add gamma RGB composition
	-- TODO: add linear RGB composition
	-- TODO: add perceptual composition
}
composition.ColorSequenceKeypoint.default = composition.ColorSequenceKeypoint.perceptual

composition.DateTime = {
	unixTimestampMillis = {
		decompose = function(raw)
			return {raw.UnixTimestampMillis}
		end,
		compose = function(vec)
			return DateTime.fromUnixTimestampMillis(vec[1])
		end,
		space = spaces.linear
	},
	unixTimestamp = {
		decompose = function(raw)
			return {raw.UnixTimestamp}
		end,
		compose = function(vec)
			return DateTime.fromUnixTimestamp(vec[1])
		end,
		space = spaces.linear
	}

}
composition.DateTime.default = composition.DateTime.unixTimestampMillis

composition.NumberRange = {
	linear = {
		decompose = function(raw)
			return {raw.Min, raw.Max}
		end,
		compose = function(vec)
			return NumberRange.new(vec[1], vec[2])
		end,
		space = spaces.linear
	}
}
composition.NumberRange.default = composition.NumberRange.linear

composition.NumberSequenceKeypoint = {
	-- TODO: add linear composition
}
composition.NumberSequenceKeypoint.default = composition.NumberSequenceKeypoint.linear

composition.PhysicalProperties = {
	-- TODO: add linear composition
}
composition.PhysicalProperties.default = composition.PhysicalProperties.linear

composition.Ray = {
	-- TODO: add linear composition
}
composition.Ray.default = composition.Ray.linear

composition.Rect = {
	-- TODO: add linear composition
}
composition.Rect.default = composition.Rect.linear

composition.Region3 = {
	-- TODO: add position/size composition
	-- TODO: add cframe/size composition
}
composition.Region3.default = composition.Region3.positionSize

composition.Region3int16 = {
	-- TODO: add position/size composition
}
composition.Region3int16.default = composition.Region3int16.positionSize

composition.UDim = {
	-- TODO: add linear composition
}
composition.UDim.default = composition.UDim.linear

composition.UDim2 = {
	-- TODO: add linear composition
}
composition.UDim2.default = composition.UDim2.linear

composition.Vector2 = {
	-- TODO: add linear composition
}
composition.Vector2.default = composition.Vector2.linear

composition.Vector2int16 = {
	-- TODO: add linear composition
}
composition.Vector2int16.default = composition.Vector2int16.linear

composition.Vector3 = {
	-- TODO: add linear composition
}
composition.Vector3.default = composition.Vector3.linear

composition.Vector3int16 = {
	-- TODO: add linear composition
}
composition.Vector3int16.default = composition.Vector3int16.linear

return composition