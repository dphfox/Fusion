--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Calculates how the lifetimes of the two values relate. Specifically, it
	calculates which value will be destroyed earlier or later, if it is possible
	to infer this from their scopes.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local function whichScopeLivesLonger(
	scopeA: Types.Scope<unknown>,
	scopeB: Types.Scope<unknown>
): "definitely-a" | "definitely-b" | "unsure"
	-- If we can prove one scope is inside of the other scope, then the outer
	-- scope must live longer than the inner scope (assuming idiomatic scopes).
	-- So, we will search the scopes recursively until we find one of them, at
	-- which point we know they must have been found inside the other scope.
	local openSet: {Types.Scope<unknown>} = {scopeA, scopeB}
	local nextOpenSet: {Types.Scope<unknown>} = {}
	local openSetSize, nextOpenSetSize = 2, 0
	local closedSet = {}
	while openSetSize > 0 do
		for _, scope in openSet do
			closedSet[scope] = true
			for _, inScope in ipairs(scope) do
				if inScope == scopeA then
					return "definitely-b"
				elseif inScope == scopeB then
					return "definitely-a"
				elseif typeof(inScope) == "table" then
					local inScope = inScope :: {unknown}
					if inScope[1] ~= nil and closedSet[scope] == nil then
						nextOpenSetSize += 1
						nextOpenSet[nextOpenSetSize] = inScope :: Types.Scope<unknown>
					end
				end 
			end
		end
		table.clear(openSet)
		openSet, nextOpenSet = nextOpenSet, openSet
		openSetSize, nextOpenSetSize = nextOpenSetSize, 0
	end
	return "unsure"
end

local function whichLivesLonger(
	scopeA: Types.Scope<unknown>,
	a: unknown,
	scopeB: Types.Scope<unknown>,
	b: unknown
): "definitely-a" | "definitely-b" | "unsure"
	if External.isTimeCritical() then
		return "unsure"
	elseif scopeA == scopeB then
		local scopeA: {unknown} = scopeA
		for index = #scopeA, 1, -1 do
			local value = scopeA[index]
			if value == a then
				return "definitely-b"
			elseif value == b then
				return "definitely-a"
			end
		end
		return "unsure"
	else
		return whichScopeLivesLonger(scopeA, scopeB)
	end
end

return whichLivesLonger