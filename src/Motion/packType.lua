--!strict

--[[
	Packs an array of numbers into a given animatable data type.
	If the type is not animatable, nil will be returned.

	FUTURE: When Luau supports singleton types, those could be used in
	conjunction with intersection types to make this function fully statically
	type checkable.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Motion.PubTypes)
local Oklab = require(Package.Motion.Colour.Oklab)

local function packType(numbers: {number}, typeString: string): PubTypes.Animatable?
	if typeString == "number" then
		return numbers[1]

	elseif typeString == "CFrame" then
		return
			CFrame.new(numbers[1], numbers[2], numbers[3]) *
			CFrame.fromAxisAngle(
				Vector3.new(numbers[4], numbers[5], numbers[6]).Unit,
				numbers[7]
			)

	elseif typeString == "Color3" then
		return Oklab.from(
			Vector3.new(numbers[1], numbers[2], numbers[3]),
			false
		)

	elseif typeString == "ColorSequenceKeypoint" then
		return ColorSequenceKeypoint.new(
			numbers[4],
			Oklab.from(
				Vector3.new(numbers[1], numbers[2], numbers[3]),
				false
			)
		)

	elseif typeString == "DateTime" then
		return DateTime.fromUnixTimestampMillis(numbers[1])

	elseif typeString == "NumberRange" then
		return NumberRange.new(numbers[1], numbers[2])

	elseif typeString == "NumberSequenceKeypoint" then
		return NumberSequenceKeypoint.new(numbers[2], numbers[1], numbers[3])

	elseif typeString == "PhysicalProperties" then
		return PhysicalProperties.new(numbers[1], numbers[2], numbers[3], numbers[4], numbers[5])

	elseif typeString == "Ray" then
		return Ray.new(
			Vector3.new(numbers[1], numbers[2], numbers[3]),
			Vector3.new(numbers[4], numbers[5], numbers[6])
		)

	elseif typeString == "Rect" then
		return Rect.new(numbers[1], numbers[2], numbers[3], numbers[4])

	elseif typeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		local position = Vector3.new(numbers[1], numbers[2], numbers[3])
		local halfSize = Vector3.new(numbers[4] / 2, numbers[5] / 2, numbers[6] / 2)
		return Region3.new(position - halfSize, position + halfSize)

	elseif typeString == "Region3int16" then
		return Region3int16.new(
			Vector3int16.new(numbers[1], numbers[2], numbers[3]),
			Vector3int16.new(numbers[4], numbers[5], numbers[6])
		)

	elseif typeString == "UDim" then
		return UDim.new(numbers[1], numbers[2])

	elseif typeString == "UDim2" then
		return UDim2.new(numbers[1], numbers[2], numbers[3], numbers[4])

	elseif typeString == "Vector2" then
		return Vector2.new(numbers[1], numbers[2])

	elseif typeString == "Vector2int16" then
		return Vector2int16.new(numbers[1], numbers[2])

	elseif typeString == "Vector3" then
		return Vector3.new(numbers[1], numbers[2], numbers[3])

	elseif typeString == "Vector3int16" then
		return Vector3int16.new(numbers[1], numbers[2], numbers[3])
	else
		return nil
	end
end

return packType