local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local CreateElement = require(Package.Instances.CreateElement)
local Children = require(Package.Instances.Children)
local OnEvent = require(Package.Instances.OnEvent)
local OnChange = require(Package.Instances.OnChange)

local State = require(Package.State.State)
local Computed = require(Package.State.Computed)

local function waitForDefer()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
end

return function()
	it("should create a new instance", function()
		local ins = CreateElement("Frame", {})

		expect(typeof(ins) == "Instance").to.be.ok()
		expect(ins:IsA("Frame")).to.be.ok()
	end)

	it("should throw for non-existent class types", function()
		expect(function()
			CreateElement("This is not a valid class type", {})
		end).to.throw("cannotCreateClass")
	end)

	it("should assign properties to instances", function()
		local ins = CreateElement("Folder", {
			Name = "Bob"
		})

		expect(ins.Name).to.equal("Bob")
	end)

	it("should throw for non-existent properties", function()
		expect(function()
			CreateElement("Folder", {
				Frobulator = "Frobulateur"
			})
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw for unrecognised keys", function()
		expect(function()
			CreateElement("Folder", {
				[2] = true
			})
		end).to.throw("unrecognisedPropertyKey")

		expect(function()
			CreateElement("Folder", {
				[{
					type = "Symbol",
					name = "Fake"
				}] = true
			})
		end).to.throw("unrecognisedPropertyKey")
	end)

	it("should assign single children to instances", function()
		local ins = CreateElement("Folder", {
			Name = "Bob"
		}, {
			CreateElement("Folder", {
				Name = "Fred"
			})
		})

		expect(ins:FindFirstChild("Fred")).to.be.ok()
	end)

	it("should assign multiple children to instances", function()
		local ins = CreateElement("Folder", {
			Name = "Bob"
		}, {
			CreateElement("Folder", {
				Name = "Fred"
			}),
			CreateElement("Folder", {
				Name = "George"
			}),
			CreateElement("Folder", {
				Name = "Harry"
			}),
		})

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		expect(ins:FindFirstChild("George")).to.be.ok()
		expect(ins:FindFirstChild("Harry")).to.be.ok()
	end)

	it("should flatten children to be assigned", function()
		local ins = CreateElement("Folder", {
			Name = "Bob"
		}, {
			CreateElement("Folder", {
				Name = "Fred"
			}),

			{
				CreateElement("Folder", {
					Name = "George"
				}),
				{
					CreateElement("Folder", {
						Name = "Harry"
					}),
				}
			}
		})

		expect(ins:FindFirstChild("Fred")).to.be.ok()
		expect(ins:FindFirstChild("George")).to.be.ok()
		expect(ins:FindFirstChild("Harry")).to.be.ok()
	end)

	it("should connect event handlers", function()
		local fires = 0
		local ins = CreateElement("Folder", {
			Name = "Foo",

			[OnEvent "AncestryChanged"] = function()
				fires += 1
			end
		})

		ins.Parent = game
		ins:Destroy()

		waitForDefer()

		expect(fires).never.to.equal(0)
	end)

	it("should throw for non-existent events", function()
		expect(function()
			CreateElement("Folder", {
				Name = "Foo",

				[OnEvent "Frobulate"] = function() end
			})
		end).to.throw("cannotConnectEvent")
	end)

	it("should throw for non-event event handlers", function()
		expect(function()
			CreateElement("Folder", {
				Name = "Foo",

				[OnEvent "Name"] = function() end
			})
		end).to.throw("cannotConnectEvent")
	end)

	it("shouldn't fire events during initialisation", function()
		local fires = 0
		local ins = CreateElement("Folder", {
			Parent = game,
			Name = "Foo",

			[OnEvent "ChildAdded"] = function()
				fires += 1
			end,

			[OnEvent "Changed"] = function()
				fires += 1
			end,

			[OnEvent "AncestryChanged"] = function()
				fires += 1
			end
		}, {
			CreateElement("Folder", {
				Name = "Bar"
			})
		})

		local totalFires = fires
		ins:Destroy()

		waitForDefer()

		expect(totalFires).to.equal(0)
	end)

	it("should connect property change handlers", function()
		local fires = 0
		local ins = CreateElement("Folder", {
			Name = "Foo",
			[OnChange "Name"] = function()
				fires += 1
			end
		})

		ins.Name = "Bar"

		waitForDefer()

		expect(fires).never.to.equal(0)
	end)

	it("should throw when connecting to non-existent property changes", function()
		expect(function()
			CreateElement("Folder", {
				Name = "Foo",
				[OnChange "Frobulate"] = function() end
			})
		end).to.throw("cannotConnectChange")
	end)

	it("shouldn't fire property changes during initialisation", function()
		local fires = 0
		local ins = CreateElement("Folder", {
			Parent = game,
			Name = "Foo",

			[OnChange "Name"] = function()
				fires += 1
			end,

			[OnChange "Parent"] = function()
				fires += 1
			end
		})

		local totalFires = fires
		ins:Destroy()

		waitForDefer()

		expect(totalFires).to.equal(0)
	end)

	it("should bind State objects passed as properties", function()
		local name = State("Foo")
		local ins = CreateElement("Folder", {
			Name = name
		})

		expect(ins.Name).to.equal("Foo")

		name:set("Bar")
		waitForDefer()
		expect(ins.Name).to.equal("Bar")
	end)

	it("should bind Computed objects passed as properties", function()
		local name = State("Foo")
		local ins = CreateElement("Folder", {
			Name = Computed(function()
				return "The" .. name:get()
			end)
		})

		expect(ins.Name).to.equal("TheFoo")

		name:set("Bar")
		waitForDefer()
		expect(ins.Name).to.equal("TheBar")
	end)

	it("should defer bound state updates", function()
		local name = State("Foo")
		local ins = CreateElement("Folder", {
			Name = name
		})

		expect(ins.Name).to.equal("Foo")

		name:set("Bar")

		expect(ins.Name).to.equal("Foo")

		name:set("Baz")

		expect(ins.Name).to.equal("Foo")
		waitForDefer()
		expect(ins.Name).to.equal("Baz")
	end)

	it("should respect Parents of assigned children", function()
		local targetParent = CreateElement("Folder", {})
		local child = CreateElement("Folder", {
			Parent = targetParent
		})

		local constructedParent = CreateElement("Folder", {}, {child})

		expect(child.Parent).to.equal(targetParent)
	end)

	it("should bind State objects passed as the parent", function()
		local parent1 = CreateElement("Folder", {})
		local parent2 = CreateElement("Folder", {})

		local parent = State(parent1)

		local child = CreateElement("Folder", {
			Parent = parent
		})

		expect(child.Parent).to.equal(parent1)

		parent:set(parent2)
		expect(child.Parent).to.equal(parent1)

		waitForDefer()

		expect(child.Parent).to.equal(parent2)
	end)

	it("should bind State objects passed as children", function()
		local child1 = CreateElement("Folder", {})
		local child2 = CreateElement("Folder", {})
		local child3 = CreateElement("Folder", {})
		local child4 = CreateElement("Folder", {})

		local children = State({child1})
		local parent = CreateElement("Folder", {}, children)

		expect(child1.Parent).to.equal(parent)

		children:set({child2, child3})

		waitForDefer()

		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)

		children:set({child1, child2, child3, child4})

		waitForDefer()

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		expect(child4.Parent).to.equal(parent)
	end)

	it("should defer updates to State children", function()
		local child1 = CreateElement("Folder", {})
		local child2 = CreateElement("Folder", {})

		local children = State(child1)

		local parent = CreateElement("Folder", {}, {children})

		expect(child1.Parent).to.equal(parent)

		children:set(child2)

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(nil)

		waitForDefer()

		expect(child1.Parent).to.equal(nil)
		expect(child2.Parent).to.equal(parent)
	end)

	it("should recursively bind State children", function()
		local child1 = CreateElement("Folder", {})
		local child2 = CreateElement("Folder", {})
		local child3 = CreateElement("Folder", {})
		local child4 = CreateElement("Folder", {})

		local children = State({
			child1,
			State(child2),
			State({
				child3,
				State(State(child4))
			})
		})

		local parent = CreateElement("Folder", {}, {children})

		expect(child1.Parent).to.equal(parent)
		expect(child2.Parent).to.equal(parent)
		expect(child3.Parent).to.equal(parent)
		expect(child4.Parent).to.equal(parent)
	end)

	it("should allow for State children to be nil", function()
		local child = CreateElement("Folder", {})

		local children = State(nil)

		local parent = CreateElement("Folder", {}, {children})

		expect(child.Parent).to.equal(nil)

		children:set(child)

		waitForDefer()

		expect(child.Parent).to.equal(parent)

		children:set(nil)

		waitForDefer()

		expect(child.Parent).to.equal(nil)
	end)

	local function FolderComponent(props: {Name: string})
		return CreateElement("Folder", {
			Name = props.Name
		})
	end

	it("should take a component function", function()
		local object = CreateElement("Folder", {}, {
			CreateElement(FolderComponent, {
				Name = "Fred"
			})
		})

		expect(object:FindFirstChild("Fred")).to.be.ok()
	end)

	-- TODO: test for garbage collection
end