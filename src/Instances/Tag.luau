--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which allows users to apply custom
	CollectionService tags to instances
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Memory
local checkLifetime = require(Package.Memory.checkLifetime)
-- Graph
local Observer = require(Package.Graph.Observer)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)

local keyCache: { [string]: Types.SpecialKey } = {}

-- TODO: should this accept tagName: UsedAs<string>?
local function Tag(tagName: string): Types.SpecialKey
	local key = keyCache[tagName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "Tag",
			stage = "self",
			apply = function(self: Types.SpecialKey, scope: Types.Scope<unknown>, value: unknown, applyTo: Instance)
				if castToState(value) then
					local value = value :: Types.StateObject<unknown>
					checkLifetime.bOutlivesA(
						scope,
						applyTo,
						value.scope,
						value.oldestTask,
						checkLifetime.formatters.boundTag,
						tagName
					)
					Observer(scope, value :: any):onBind(function()
						if peek(value) then
							applyTo:AddTag(tagName)
						elseif applyTo:HasTag(tagName) then
							applyTo:RemoveTag(tagName)
						end
					end)
				else
					if value then
						applyTo:AddTag(tagName)
					end
				end
			end,
		}
		keyCache[tagName] = key
	end
	return key
end

return Tag
