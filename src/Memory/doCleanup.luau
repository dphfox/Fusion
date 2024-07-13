--!strict
--!nolint LocalUnused
--!nolint LocalShadow

--[[
	Cleans up the chores passed in as the arguments.
	A chore can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local alreadyDestroying: {[Types.Task]: true} = {}

local function doCleanup(
	chore: Types.Task
): ()
	if alreadyDestroying[chore] then
		return External.logError("destroyedTwice")
	end
	alreadyDestroying[chore] = true

	-- case 1: Instance
	if typeof(chore) == "Instance" then
		chore:Destroy()

	-- case 2: RBXScriptConnection
	elseif typeof(chore) == "RBXScriptConnection" then
		chore:Disconnect()

	-- case 3: thread
	elseif typeof(chore) == "thread" then
		local cancelled
		if coroutine.running() ~= chore then
			cancelled = pcall(function()
				task.cancel(chore)
			end)
		end

		if not cancelled then
			local toCancel = chore
			task.defer(function()
				task.cancel(toCancel)
			end)
		end

	-- case 4: callback
	elseif typeof(chore) == "function" then
		chore()

	elseif typeof(chore) == "table" then
		local chore = (chore :: any) :: {Destroy: (...unknown) -> (...unknown)?, destroy: (...unknown) -> (...unknown)?}

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
			local chore = chore :: {Types.Task}
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #chore, 1, -1 do
				doCleanup(chore[index])
				chore[index] = nil
			end
		end
	end

	alreadyDestroying[chore] = nil
end

return doCleanup