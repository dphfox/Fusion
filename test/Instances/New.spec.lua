local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Ref = require(Package.Instances.Ref)
local OnEvent = require(Package.Instances.OnEvent)
local OnChange = require(Package.Instances.OnChange)
local Children = require(Package.Instances.Children)

local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)

local function waitForDefer()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
end

return function()
	it("should create a new instance", function()
		local ins = New "Frame" {}

		expect(typeof(ins) == "Instance").to.be.ok()
		expect(ins:IsA("Frame")).to.be.ok()
	end)

	it("should throw for non-existent class types", function()
		expect(function()
			New "This is not a valid class type" {}
		end).to.throw("cannotCreateClass")
	end)

	it("should assign properties to instances", function()
		local ins = New "Folder" {
			Name = "Bob"
		}

		expect(ins.Name).to.equal("Bob")
	end)

	it("should throw for non-existent constant properties", function()
		expect(function()
			New "Folder" {
				Frobulator = "Frobulateur"
			}
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw for non-existent value properties", function()
		local state = Value("Frobulateur")

		expect(function()
			New "Folder" {
				Frobulator = Computed(function()
					state:get()
				end)
			}
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw on invalid property type for non-Parent", function()
		expect(function()
			New "Folder" {
				Name = UDim.new()
			}
		end).to.throw("invalidPropertyType")

		local state = Value(true)

		expect(function()
			New "Folder" {
				Name = Computed(function()
					state:get()
				end)
			}
		end).to.throw("invalidPropertyType")
	end)

	it("should throw on invalid property type for Parent", function()
		expect(function()
			New "Folder" {
				Parent = "Foo"
			}
		end).to.throw("invalidPropertyType")

		local state = Value(true)

		expect(function()
			New "Folder" {
				Parent = Computed(function()
					return state:get()
				end)
			}
		end).to.throw("invalidPropertyType")
	end)

	it("should throw on invalid property type for Instances", function()
		expect(function()
			New "ObjectValue" {
				Value = "Foo"
			}
		end).to.throw("invalidPropertyType")

		local state = Value(true)

		expect(function()
			New "ObjectValue" {
				Value = Computed(function()
					return state:get()
				end)
			}
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for unrecognised keys", function()
		expect(function()
			New "Folder" {
				[2] = true
			}
		end).to.throw("unrecognisedPropertyKey")

		expect(function()
			New "Folder" {
				[{
					type = "Symbol",
					name = "Fake"
				}] = true
			}
		end).to.throw("unrecognisedPropertyKey")
	end)

	it("should bind State objects passed as properties", function()
		local name = Value("Foo")
		local ins = New "Folder" {
			Name = name
		}

		expect(ins.Name).to.equal("Foo")

		name:set("Bar")
		waitForDefer()
		expect(ins.Name).to.equal("Bar")
	end)

	it("should bind Computed objects passed as properties", function()
		local name = Value("Foo")
		local ins = New "Folder" {
			Name = Computed(function()
				return "The" .. name:get()
			end)
		}

		expect(ins.Name).to.equal("TheFoo")

		name:set("Bar")
		waitForDefer()
		expect(ins.Name).to.equal("TheBar")
	end)

	it("should defer bound state updates", function()
		local name = Value("Foo")
		local ins = New "Folder" {
			Name = name
		}

		expect(ins.Name).to.equal("Foo")

		name:set("Bar")

		expect(ins.Name).to.equal("Foo")

		name:set("Baz")

		expect(ins.Name).to.equal("Foo")
		waitForDefer()
		expect(ins.Name).to.equal("Baz")
	end)

	it("should bind State objects passed as the parent", function()
		local parent1 = New "Folder" {}
		local parent2 = New "Folder" {}

		local parent = Value(parent1)

		local child = New "Folder" {
			Parent = parent
		}

		expect(child.Parent).to.equal(parent1)

		parent:set(parent2)
		expect(child.Parent).to.equal(parent1)

		waitForDefer()

		expect(child.Parent).to.equal(parent2)
	end)
end