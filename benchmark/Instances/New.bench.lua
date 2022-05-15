local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Children = require(Package.Instances.Children)
local OnEvent = require(Package.Instances.OnEvent)
local OnChange = require(Package.Instances.OnChange)
local Value = require(Package.Core.Value)

local function callback()

end

return {

	{
		name = "New without properties",
		calls = 50000,

		run = function()
			New "Frame" {}
		end
	},

	{
		name = "New with properties - constant",
		calls = 50000,

		run = function()
			New "Frame" {
				Name = "Foo"
			}
		end
	},

	{
		name = "New with properties - state",
		calls = 50000,

		run = function()
			New "Frame" {
				Name = Value("Foo")
			}
		end
	},

	{
		name = "New with Parent - constant",
		calls = 10000,

		preRun = function()
		end,

		run = function()
			New "Folder" {
				Parent = Instance.new("Folder")
			}
		end
	},

	{
		name = "New with Parent - state",
		calls = 10000,

		preRun = function()
			return Instance.new("Folder")
		end,

		run = function(parent)
			New "Folder" {
				Parent = Value(parent)
			}
		end,

		postRun = function(parent)
			parent:Destroy()
		end
	},

	{
		name = "New with Children - single",
		calls = 50000,

		preRun = function()
			return New "Folder" {}
		end,

		run = function(child)
			New "Frame" {
				[Children] = child
			}
		end
	},

	{
		name = "New with Children - array",
		calls = 50000,

		preRun = function()
			return {
				New "Folder" {}
			}
		end,

		run = function(children)
			New "Frame" {
				[Children] = children
			}
		end
	},

	{
		name = "New with Children - state",
		calls = 50000,

		preRun = function()
			return New "Folder" {}
		end,

		run = function(child)
			New "Frame" {
				[Children] = Value(child)
			}
		end
	},

	{
		name = "New with OnEvent",
		calls = 50000,

		run = function()
			New "Frame" {
				[OnEvent "MouseEnter"] = callback
			}
		end
	},

	{
		name = "New with OnChange",
		calls = 50000,

		run = function()
			New "Frame" {
				[OnChange "Name"] = callback
			}
		end
	}

}