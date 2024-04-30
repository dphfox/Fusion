--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
    Provides transformation functions for converting linear RGB values
    into sRGB values.

    RGB color channel transformations are outlined here:
    https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
]]

local sRGB = {}

-- Equivalent to f_inv. Takes a linear sRGB channel and returns
-- the sRGB channel
local function transform(channel: number): number
    if channel >= 0.04045 then
        return ((channel + 0.055)/(1 + 0.055))^2.4
    else
        return channel / 12.92
    end
end

-- Equivalent to f. Takes an sRGB channel and returns
-- the linear sRGB channel
local function inverse(channel: number): number
    if channel >= 0.0031308 then
        return (1.055) * channel^(1.0/2.4) - 0.055
    else
        return 12.92 * channel
    end
end

-- Uses a tranformation to convert linear RGB into sRGB.
function sRGB.fromLinear(rgb: Color3): Color3
    return Color3.new(
        transform(rgb.R),
        transform(rgb.G),
        transform(rgb.B)
    )
end

-- Converts an sRGB into linear RGB using a
-- (The inverse of sRGB.fromLinear).
function sRGB.toLinear(srgb: Color3): Color3
    return Color3.new(
        inverse(srgb.R),
        inverse(srgb.G),
        inverse(srgb.B)
    )
end

return sRGB