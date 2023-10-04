--!strict

--[[
	Provides functions for converting Color3s into Oklab space, for more
	perceptually uniform colour blending.

	See: https://bottosson.github.io/posts/oklab/
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local sRGB = require(script.Parent.sRGB)

local Oklab = {}

local class = {}
local CLASS_METATABLE = {__index = class}

function class:Lerp(goal: Types.Oklab, alpha: number)
	local newVector = self._vector:Lerp(goal, alpha)
	return Oklab.new(newVector.X, newVector.Y, newVector.Z)
end

function class:toLinear(unclamped: boolean?): Color3
	return Oklab.toLinear(self, unclamped)
end

function class:toSRGB(unclamped: boolean?): Color3
	return Oklab.toSRGB(self, unclamped)
end

function Oklab.new(l: number, a: number, b: number): Types.Oklab
	local self = {
		type = "Oklab",
		l = l,
		a = a,
		b = b,
		_vector = Vector3.new(l, a, b)
	}

	return table.freeze(setmetatable(self, CLASS_METATABLE))
end

-- Converts a Color3 in linear RGB space to a Vector3 in Oklab space.
function Oklab.fromLinear(rgb: Color3): Types.Oklab

	local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
	local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
	local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005

	local lRoot = l ^ (1/3)
	local mRoot = m ^ (1/3)
	local sRoot = s ^ (1/3)

	return Oklab.new(
		lRoot * 0.2104542553 + mRoot * 0.7936177850 - sRoot * 0.0040720468,
		lRoot * 1.9779984951 - mRoot * 2.4285922050 + sRoot * 0.4505937099,
		lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.8086757660
	)
end

-- Converts a Color3 in sRGB space to a Vector3 in Oklab space.
function Oklab.fromSRGB(srgb: Color3): Types.Oklab
	return Oklab.fromLinear(sRGB.toLinear(srgb))
end

-- Converts Oklab space to a Color3 in linear RGB space.
-- The Color3 will be clamped by default unless specified otherwise.
function Oklab.toLinear(lab: Types.Oklab, unclamped: boolean?): Color3
	local lRoot = lab.l + lab.a * 0.3963377774 + lab.b * 0.2158037573
	local mRoot = lab.l - lab.a * 0.1055613458 - lab.b * 0.0638541728
	local sRoot = lab.l - lab.a * 0.0894841775 - lab.b * 1.2914855480

	local l = lRoot ^ 3
	local m = mRoot ^ 3
	local s = sRoot ^ 3

	local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
	local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
	local blue = l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010

	if not unclamped then
		red = math.clamp(red, 0, 1)
		green = math.clamp(green, 0, 1)
		blue = math.clamp(blue, 0, 1)
	end

	return Color3.new(red, green, blue)
end

-- Converts Oklab space to a Color3 in sRGB space.
-- The Color3 will be clamped by default unless specified otherwise.
function Oklab.toSRGB(lab: Types.Oklab, unclamped: boolean?): Color3
	return sRGB.fromLinear(lab:toLinear(unclamped))
end

return Oklab
