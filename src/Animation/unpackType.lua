--[[
	Unpacks an animatable type into an array of numbers.
	If the type is not animatable, an empty array will be returned.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local Oklab = require(Package.Colour.Oklab)

local function unpackType(value: Types.Animatable, typeString: string): {number}
	if typeString == "number" then
		return {value}

	elseif typeString == "CFrame" then
		-- FUTURE: is there a better way of doing this? doing distance
		-- calculations on `angle` may be incorrect
		local axis, angle = value:ToAxisAngle()
		return {value.X, value.Y, value.Z, axis.X, axis.Y, axis.Z, angle}

	elseif typeString == "Color3" then
		local lab = Oklab.to(value)
		return {lab.X, lab.Y, lab.Z}

	elseif typeString == "ColorSequenceKeypoint" then
		local lab = Oklab.to(value.Value)
		return {lab.X, lab.Y, lab.Z, value.Time}

	elseif typeString == "DateTime" then
		return {value.UnixTimestampMillis}

	elseif typeString == "NumberRange" then
		return {value.Min, value.Max}

	elseif typeString == "NumberSequenceKeypoint" then
		return {value.Value, value.Time, value.Envelope}

	elseif typeString == "PhysicalProperties" then
		return {value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight}

	elseif typeString == "Ray" then
		return {value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z}

	elseif typeString == "Rect" then
		return {value.Min.X, value.Min.Y, value.Max.X, value.Max.Y}

	elseif typeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		return {
			value.CFrame.X, value.CFrame.Y, value.CFrame.Z,
			value.Size.X, value.Size.Y, value.Size.Z
		}

	elseif typeString == "Region3int16" then
		return {value.Min.X, value.Min.Y, value.Min.Z, value.Max.X, value.Max.Y, value.Max.Z}

	elseif typeString == "UDim" then
		return {value.Scale, value.Offset}

	elseif typeString == "UDim2" then
		return {value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset}

	elseif typeString == "Vector2" then
		return {value.X, value.Y}

	elseif typeString == "Vector2int16" then
		return {value.X, value.Y}

	elseif typeString == "Vector3" then
		return {value.X, value.Y, value.Z}

	elseif typeString == "Vector3int16" then
		return {value.X, value.Y, value.Z}
	else
		return {}
	end
end

return unpackType