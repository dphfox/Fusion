--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Stores types that are commonly used between For objects.
]]

local Package = script.Parent.Parent.Parent
local Types = require(Package.Types)

export type SubObject<S, KI, KO, VI, VO> = {
	-- Not all sub objects need to store a scope, for example if the scope
	-- remains empty, it'll be given back to the scope pool.
	maybeScope: Types.Scope<S>?,
	inputKey: KI,
	inputValue: VI,
	roamKeys: boolean,
	roamValues: boolean,
	invalidateInputKey: (SubObject<S, KI, KO, VI, VO>) -> (),
	invalidateInputValue: (SubObject<S, KI, KO, VI, VO>) -> (),
	useOutputPair: (SubObject<S, KI, KO, VI, VO>, Types.Use) -> (KO?, VO?)
}

export type Disassembly<S, KI, KO, VI, VO> = Types.GraphObject & {
	populate: (Disassembly<S, KI, KO, VI, VO>, Types.Use, output: {[KO]: VO}) -> ()
}

return nil
