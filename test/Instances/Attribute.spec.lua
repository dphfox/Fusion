local Package = game:GetService("ReplicatedStorage").Fusion

local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local Value = require(Package.State.Value)

return function()
    it("should create attributes (constant)", function()
        local child = New "Folder" {
            [Attribute "Foo"] = "Bar"
        }
        expect(child:GetAttribute("Foo")).to.equal("Bar")
    end)

    it("should create attributes (state)", function()
        local attributeValue = Value("Bar")
	    local child = New "Folder" {
            [Attribute "Foo"] = attributeValue
        }
        expect(child:GetAttribute("Foo")).to.equal("Bar")
    end)

    it("should update attributes when state objects are updated", function()
        local attributeValue = Value("Bar")
	    local child = New "Folder" {
            [Attribute "Foo"] = attributeValue
        }

        expect(child:GetAttribute("Foo")).to.equal("Bar")
        attributeValue:set("Baz")
        task.wait()
        expect(child:GetAttribute("Foo")).to.equal("Baz")
    end)

    it("should error when given nil names (constant)", function()
        expect(function()
            local child = New "Folder" {
                [Attribute(nil)] = "foo"
            }
        end).to.throw("attributeNameNil")
    end)

    it("should error when given nil names (state)", function()
        expect(function()
            local attributeValue = Value("foo")
            local child = New "Folder" {
                [Attribute(nil)] = attributeValue
            }
        end).to.throw("attributeNameNil")
    end)

    it("should defer attribute changes", function()
	    local value = Value("Bar")
	    local child = New "Folder" {
            [Attribute "Foo"] = value
        }
		value:set("Baz")

	    expect(child:GetAttribute("Foo")).to.equal("Bar")
	    task.wait()
	    expect(child:GetAttribute("Foo")).to.equal("Baz")
	end)
end
