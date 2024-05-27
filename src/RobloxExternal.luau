--!strict
--!nolint LocalUnused
--!nolint LocalShadow

--[[
<<<<<<< HEAD
	Roblox implementation for Fusion's abstract scheduler layer.
=======
	Roblox implementation for Fusion's abstract provider layer.
>>>>>>> upstream/main
]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Package = script.Parent
local External = require(Package.External)

local RobloxExternal = {}

<<<<<<< HEAD
--[[
   Sends an immediate task to the external scheduler. Throws if none is set.
=======
RobloxExternal.policies = {
	allowWebLinks = RunService:IsStudio()
}

--[[
   Sends an immediate task to the external provider. Throws if none is set.
>>>>>>> upstream/main
]]
function RobloxExternal.doTaskImmediate(
	resume: () -> ()
)
   task.spawn(resume)
end

--[[
<<<<<<< HEAD
	Sends a deferred task to the external scheduler. Throws if none is set.
=======
	Sends a deferred task to the external provider. Throws if none is set.
>>>>>>> upstream/main
]]
function RobloxExternal.doTaskDeferred(
	resume: () -> ()
)
	task.defer(resume)
end

--[[
	Errors in a different thread to preserve the flow of execution.
]]
<<<<<<< HEAD
function RobloxExternal.errorNonFatal(
	err: unknown
)
	task.spawn(error, err, 0)
end

--[[
=======
function RobloxExternal.logErrorNonFatal(
	errorString: string
)
	task.spawn(error, errorString, 0)
end

--[[
	Shows a warning message in the output.
]]
RobloxExternal.logWarn = warn

--[[
>>>>>>> upstream/main
	Sends an update step to Fusion using the Roblox clock time.
]]
local function performUpdateStep()
	External.performUpdateStep(os.clock())
end

--[[
	Binds Fusion's update step to RunService step events.
]]
local stopSchedulerFunc = nil :: (() -> ())?
function RobloxExternal.startScheduler()
	if stopSchedulerFunc ~= nil then
		return
	end
	if RunService:IsClient() then
		-- In cases where multiple Fusion modules are running simultaneously,
		-- this prevents collisions.
		local id = "FusionUpdateStep_" .. HttpService:GenerateGUID()
		RunService:BindToRenderStep(
			id,
			Enum.RenderPriority.First.Value,
			performUpdateStep
		)
		stopSchedulerFunc = function()
			RunService:UnbindFromRenderStep(id)
		end
	else
		local connection = RunService.Heartbeat:Connect(performUpdateStep)
		stopSchedulerFunc = function()
			connection:Disconnect()
		end
	end
end

--[[
	Unbinds Fusion's update step from RunService step events.
]]
function RobloxExternal.stopScheduler()
	if stopSchedulerFunc ~= nil then
		stopSchedulerFunc()
		stopSchedulerFunc = nil
	end
end

return RobloxExternal