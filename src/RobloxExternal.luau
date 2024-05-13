--!strict
--!nolint LocalUnused
--!nolint LocalShadow

--[[
	Roblox implementation for Fusion's abstract provider layer.
]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Package = script.Parent
local External = require(Package.External)

local RobloxExternal = {}

RobloxExternal.policies = {
	allowWebLinks = RunService:IsStudio()
}

--[[
   Sends an immediate task to the external provider. Throws if none is set.
]]
function RobloxExternal.doTaskImmediate(
	resume: () -> ()
)
   task.spawn(resume)
end

--[[
	Sends a deferred task to the external provider. Throws if none is set.
]]
function RobloxExternal.doTaskDeferred(
	resume: () -> ()
)
	task.defer(resume)
end

--[[
	Errors in a different thread to preserve the flow of execution.
]]
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