local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Children = require(Package.Instances.Children)
local Value = require(Package.Core.Value)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should assign single children to instances", function()
		local ins = New "Folder" {
			Name = "Bob",

			[Children] = New "Folder" {
				Name = "Fred"
			}
		}

		expect(ins:FindFirstChild("Fred")).to.be.ok()
	end)

	it("should assign multiple children to instances", function()
		local ins = New "Folder" {
			Name = "Bob",

			[Children] = {
				New "Folder" {
					Name = "Fred"
				},
				New "Folder" {
					Name = "George"
				},
				New "Folder" {
					Name = "Harry"
				}
			}
		}

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		expect(ins:FindFirstChild("George")).to.be.ok()
		expect(ins:FindFirstChild("Harry")).to.be.ok()
	end)

	it("should flatten children to be assigned", function()
		local ins = New "Folder" {
			Name = "Bob",

			[Children] = {
				New "Folder" {
					Name = "Fred"
				},
				{
					New "Folder" {
						Name = "George"
					},
					{
						New "Folder" {
							Name = "Harry"
						}
					}
				}
			}
		}

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		expect(ins:FindFirstChild("George")).to.be.ok()
		expect(ins:FindFirstChild("Harry")).to.be.ok()
	end)

	it("should bind State objects passed as children", function()
		local child1 = New "Folder" {}
		local child2 = New "Folder" {}
		local child3 = New "Folder" {}
		local child4 = New "Folder" {}

		local children = Value({child1})

		local parent = New "Folder" {
			[Children] = {
				children
			}
		}

		expect(child1.Parent).to.equal(parent)

		children:set({child2, child3})
		task.wait()

		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)

		children:set({child1, child2, child3, child4})
		task.wait()

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		expect(child4.Parent).to.equal(parent)
	end)

	it("should defer updates to State children", function()
		local child1 = New "Folder" {}
		local child2 = New "Folder" {}

		local children = Value(child1)

		local parent = New "Folder" {
			[Children] = {
				children
			}
		}

		expect(child1.Parent).to.equal(parent)

		children:set(child2)

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(nil)

		task.wait()

		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
	end)

	it("should recursively bind State children", function()
		local child1 = New "Folder" {}
		local child2 = New "Folder" {}
		local child3 = New "Folder" {}
		local child4 = New "Folder" {}

		local children = Value({
			child1,
			Value(child2),
			Value({
				child3,
				Value(Value(child4))
			})
		})

		local parent = New "Folder" {
			[Children] = {
				children
			}
		}

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		expect(child4.Parent).to.equal(parent)
	end)

	it("should allow for State children to be nil", function()
		local child = New "Folder" {}

		local children = Value(nil)

		local parent = New "Folder" {
			[Children] = {
				children
			}
		}

		expect(child.Parent).to.equal(nil)

		children:set(child)
		task.wait()

		expect(child.Parent).to.equal(parent)

		children:set(nil)
		task.wait()

		expect(child.Parent).to.equal(nil)
	end)

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			ref[1] = New "Folder" {
				[Children] = {
					Instance.new("Folder"),
					Value(Instance.new("Folder"))
				}
			}
		end

		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end