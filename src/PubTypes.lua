--!strict

--[[
	General use types
]]

-- A unique symbolic value.
export type Symbol = {
	type: string, -- replace with "Symbol" when Luau supports singleton types
	name: string
}

-- Script-readable version information.
export type Version = {
	major: number,
	minor: number,
	isRelease: boolean
}

return nil