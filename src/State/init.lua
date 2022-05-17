--!strict

--[[
	The entry point for the State library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Parent.Core.Utility.restrictRead)

type StateObject<T> = PubTypes.StateObject<T>
type CanBeState<T> = PubTypes.CanBeState<T>
export type ForPairs<KO, VO> = PubTypes.ForPairs<KO, VO>
export type ForKeys<KI, KO> = PubTypes.ForKeys<KI, KO>
export type ForValues<VI, VO> = PubTypes.ForKeys<VI, VO>
export type Observer = PubTypes.Observer

type State = {
	version: PubTypes.Version,

	ForPairs: <KI, VI, KO, VO, M>(inputTable: CanBeState<{[KI]: VI}>, processor: (KI, VI) -> (KO, VO, M?), destructor: (KO, VO, M?) -> ()?) -> ForPairs<KO, VO>,
	ForKeys: <KI, KO, M>(inputTable: CanBeState<{[KI]: any}>, processor: (KI) -> (KO, M?), destructor: (KO, M?) -> ()?) -> ForKeys<KO, any>,
	ForValues: <VI, VO, M>(inputTable: CanBeState<{[any]: VI}>, processor: (VI) -> (VO, M?), destructor: (VO, M?) -> ()?) -> ForValues<any, VO>,
	Observer: (watchedState: StateObject<any>) -> Observer
}

return restrictRead("State", {
	version = {major = 0, minor = 2, isRelease = false},
	
	ForKeys = require(script.ForKeys),
	ForPairs = require(script.ForPairs),
	ForValues = require(script.ForValues),
	Observer = require(script.Observer)
}) :: State