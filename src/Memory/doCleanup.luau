--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local chore = nil -- Disable usage of Roblox's chore scheduler

--[[
	Cleans up the chores passed in as the arguments.
	A chore can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a thread - will be canceled
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]

local function doCleanupOne(
	chore: unknown
)
	local choreType = typeof(chore)

	-- case 1: Instance
	if choreType == "Instance" then
		local chore = chore :: Instance
		chore:Destroy()

	-- case 2: RBXScriptConnection
	elseif choreType == "RBXScriptConnection" then
		local chore = chore :: RBXScriptConnection
		chore:Disconnect()

	-- case 3: thread
	elseif choreType == "thread" then
		local chore = chore :: thread
		local cancelled; if coroutine.running() ~= chore then
			cancelled = pcall(function() task.cancel(chore) end)
		end; if not cancelled then local toCancel = chore
			task.defer(function()
				task.cancel(toCancel)
			end)
		end

	-- case 4: callback
	elseif choreType == "function" then
		local chore = chore :: (...unknown) -> (...unknown)
		chore()

	elseif choreType == "table" then
		local chore = chore :: {destroy: unknown?, Destroy: unknown?}

		-- case 5: destroy() function
		if typeof(chore.destroy) == "function" then
			local chore = (chore :: any) :: {destroy: (...unknown) -> (...unknown)}
			chore:destroy()

		-- case 6: Destroy() function
		elseif typeof(chore.Destroy) == "function" then
			local chore = (chore :: any) :: {Destroy: (...unknown) -> (...unknown)}
			chore:Destroy()

		-- case 7: array of chores
		elseif chore[1] ~= nil then
			local chore = chore :: {unknown}
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #chore, 1, -1 do
				doCleanupOne(chore[index])
				chore[index] = nil
			end
		end
	end
end

local function doCleanup(
	...: unknown
)
	for index = 1, select("#", ...) do
		doCleanupOne(select(index, ...))
	end
end

return doCleanup