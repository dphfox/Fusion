--!strict

--[[
    Provides transformation functions for converting linear RGB values
    into sRGB values.
]]

local sRGB = {}

local DEFAULT_GAMMA = 2.2

-- Uses a simple tranformation of x -> x^gamma to convert linear RGB into sRGB.
function sRGB.fromLinear(rgb: Color3, gamma: number?): Color3
    gamma = gamma or DEFAULT_GAMMA
    return Color3.new(
        rgb.R ^ gamma,
        rgb.G ^ gamma,
        rgb.B ^ gamma
    )
end

-- Converts an sRGB into linear RGB using a simple power transformation
-- (The inverse of sRGB.fromLinear).
function sRGB.toLinear(srgb: Color3, gamma: number?): Color3
    gamma = gamma or DEFAULT_GAMMA
    local invGamma = 1/gamma
    return Color3.new(
        srgb.R ^ invGamma,
        srgb.G ^ invGamma,
        srgb.B ^ invGamma
    )
end

return sRGB