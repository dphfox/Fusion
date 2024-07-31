--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Children = require(Fusion.Instances.Children)
local Value = require(Fusion.State.Value)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should assign single children to instances", function()
		local expect = getfenv().expect
		
		local scope = {}
		local ins = New(scope, "Folder") {
			Name = "Bob",

			[Children] = New(scope, "Folder") {
				Name = "Fred"
			}
		}

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		doCleanup(scope)
	end)

	it("should assign multiple children to instances", function()
		local expect = getfenv().expect
		
		local scope = {}
		local ins = New(scope, "Folder") {
			Name = "Bob",

			[Children] = {
				New(scope, "Folder") {
					Name = "Fred"
				},
				New(scope, "Folder") {
					Name = "George"
				},
				New(scope, "Folder") {
					Name = "Harry"
				}
			}
		}

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		expect(ins:FindFirstChild("George")).to.be.ok()
		expect(ins:FindFirstChild("Harry")).to.be.ok()
		doCleanup(scope)
	end)

	it("should flatten children to be assigned", function()
		local expect = getfenv().expect
		
		local scope = {}
		local ins = New(scope, "Folder") {
			Name = "Bob",

			[Children] = {
				New(scope, "Folder") {
					Name = "Fred"
				} :: any,
				{
					New(scope, "Folder") {
						Name = "George"
					} :: any,
					{
						New(scope, "Folder") {
							Name = "Harry"
						}
					}
				}
			}
		}

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		expect(ins:FindFirstChild("George")).to.be.ok()
		expect(ins:FindFirstChild("Harry")).to.be.ok()
		doCleanup(scope)
	end)

	it("should bind state objects passed as children", function()
		local expect = getfenv().expect
		
		local scope = {}

		local child1 = New(scope, "Folder") { Name = "Child1" }
		local child2 = New(scope, "Folder") { Name = "Child2" }
		local child3 = New(scope, "Folder") { Name = "Child3" }
		local child4 = New(scope, "Folder") { Name = "Child4" }
		local children = Value(scope, {child1})

		local parent = New(scope, "Folder") {
			[Children] = {
				children
			}
		}

		expect(child1.Parent).to.equal(parent)
		children:set({child2, child3})
		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		children:set({child1, child2, child3, child4})
		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		expect(child4.Parent).to.equal(parent)
		doCleanup(scope)
	end)

	it("should defer updates to state children", function()
		local expect = getfenv().expect
		
		local scope = {}
		local child1 = New(scope, "Folder") {}
		local child2 = New(scope, "Folder") {}

		local children = Value(scope, child1)

		local parent = New(scope, "Folder") {
			[Children] = {
				children
			}
		}

		expect(child1.Parent).to.equal(parent)

		children:set(child2)

		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
		doCleanup(scope)
	end)

	it("should recursively bind state children", function()
		local expect = getfenv().expect
		
		local scope = {}
		local child1 = New(scope, "Folder") {}
		local child2 = New(scope, "Folder") {}
		local child3 = New(scope, "Folder") {}
		local child4 = New(scope, "Folder") {}

		local children = Value(scope, {
			child1 :: any,
			Value(scope, child2),
			Value(scope, {
				child3 :: any,
				Value(scope, Value(scope, child4))
			})
		})

		local parent = New(scope, "Folder") {
			[Children] = {
				children
			}
		}

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		expect(child4.Parent).to.equal(parent)
		doCleanup(scope)
	end)

	it("should allow for state children to be nil", function()
		local expect = getfenv().expect
		
		local scope = {}
		local child = New(scope, "Folder") {}

		local children = Value(scope, nil :: Instance?)

		local parent = New(scope, "Folder") {
			[Children] = {
				children
			}
		}

		expect(child.Parent).to.equal(nil)

		children:set(child)

		expect(child.Parent).to.equal(parent)

		children:set(nil)

		expect(child.Parent).to.equal(nil)
		doCleanup(scope)
	end)
end
