local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local cleanupOnDestroy = require(Package.Utility.cleanupOnDestroy_smart)

local function waitForDefer()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
end

return function()
	it("should run tasks on explicit :Destroy() from data model", function()
		local ins = Instance.new("Folder")
		ins.Parent = workspace

		local done = false
		local function callback()
			done = true
		end

		cleanupOnDestroy(ins, callback)
		ins:Destroy()

		local start = os.clock()
		local timeout = 3

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				error("Instance was held in memory for too long")
			end
		until done
	end)

	it("should run tasks on explicit :Destroy() from nil", function()
		local ins = Instance.new("Folder")

		local done = false
		local function callback()
			done = true
		end

		cleanupOnDestroy(ins, callback)
		ins:Destroy()

		local start = os.clock()
		local timeout = 3

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				error("Instance was held in memory for too long")
			end
		until done
	end)

	it("should run tasks on falling out of scope", function()
		local done = false
		local function callback()
			done = true
		end

		do
			local ins = Instance.new("Folder")
			cleanupOnDestroy(ins, callback)
		end

		local start = os.clock()
		local timeout = 3

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				error("Instance was held in memory for too long")
			end
		until done
	end)

	it("should run tasks if out of scope and parent is in nil", function()
		local done = false
		local function callback()
			done = true
		end
		do
			local ins = Instance.new("Folder")
			ins.Parent = Instance.new("Folder")
			cleanupOnDestroy(ins, callback)
		end

		local start = os.clock()
		local timeout = 3

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				error("Instance was held in memory for too long")
			end
		until done
	end)

	it("should not run tasks while reference held but in nil", function()
		local ins = Instance.new("Folder")
		ins.Parent = workspace

		local done = false
		local function callback()
			done = true
		end

		cleanupOnDestroy(ins, callback)
		ins.Parent = nil

		local start = os.clock()
		local timeout = 6

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				return
			end
		until done

		error("Instance was incorrectly collected")
	end)

	it("should not run tasks while reference not held but parent reference is held in nil", function()
		local parent = Instance.new("Folder")
		parent.Parent = workspace

		local done = false
		local function callback()
			done = true
		end

		do
			local ins = Instance.new("Folder")
			ins.Parent = parent
			cleanupOnDestroy(ins, callback)
		end

		parent.Parent = nil

		local start = os.clock()
		local timeout = 6

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				return
			end
		until done

		error("Instance was incorrectly collected")
	end)

	it("should not run tasks when parent is in nil, gets removed from parent and parent gets destroyed", function()
		local parent = Instance.new("Folder")
		local ins = Instance.new("Folder")
		ins.Parent = parent

		local done = false
		local function callback()
			done = true
		end

		cleanupOnDestroy(ins, callback)
		
		RunService.RenderStepped:Wait()
		parent.Parent = nil
		RunService.RenderStepped:Wait()
		ins.Parent = nil
		RunService.RenderStepped:Wait()
		parent:Destroy()

		local start = os.clock()
		local timeout = 6

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				return
			end
		until done

		error("Instance was incorrectly collected")
	end)

	it("should run tasks if parent is moved to nil then goes out of scope", function()
		local done = false
		local function callback()
			done = true
		end
		do
			local parent = Instance.new("Folder")
			parent.Parent = workspace

			local ins = Instance.new("Folder")
			ins.Parent = Instance.new("Folder")

			cleanupOnDestroy(ins, callback)
			RunService.RenderStepped:Wait()

			parent.Parent = nil
		end

		local start = os.clock()
		local timeout = 3

		repeat
			RunService.RenderStepped:Wait()
			if os.clock() - start > timeout then
				error("Instance was held in memory for too long")
			end
		until done
	end)
end