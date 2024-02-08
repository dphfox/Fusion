local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Children = require(Package.Instances.Children)
local Value = require(Package.State.Value)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should assign single children to instances", function()
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
		local scope = {}
		local ins = New(scope, "Folder") {
			Name = "Bob",

			[Children] = {
				New(scope, "Folder") {
					Name = "Fred"
				},
				{
					New(scope, "Folder") {
						Name = "George"
					},
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

	it("should bind State objects passed as children", function()
		local scope = {}
		local child1 = New(scope, "Folder") {}
		local child2 = New(scope, "Folder") {}
		local child3 = New(scope, "Folder") {}
		local child4 = New(scope, "Folder") {}

		local children = Value(scope, {child1})

		local parent = New(scope, "Folder") {
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
		doCleanup(scope)
	end)

	it("should defer updates to State children", function()
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

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(nil)

		task.wait()

		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
		doCleanup(scope)
	end)

	it("should recursively bind State children", function()
		local scope = {}
		local child1 = New(scope, "Folder") {}
		local child2 = New(scope, "Folder") {}
		local child3 = New(scope, "Folder") {}
		local child4 = New(scope, "Folder") {}

		local children = Value(scope, {
			child1,
			Value(scope, child2),
			Value(scope, {
				child3,
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

	it("should allow for State children to be nil", function()
		local scope = {}
		local child = New(scope, "Folder") {}

		local children = Value(scope, nil)

		local parent = New(scope, "Folder") {
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
		doCleanup(scope)
	end)
end
