local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local WithChild = require(Package.Instances.WithChild)
local Children = require(Package.Instances.Children)

return function()
	
	it("should apply properties to the child", function()
		local template = Instance.new("Folder")
		local child = Instance.new("IntValue")
		
		child.Name = "Int"
		child.Parent = template
		
		local copy = New (template) {
			
			[Children] = {
				
				WithChild "Int" {
					Value = 10
				}
				
			}
			
		}
		
		expect(copy.Int.Value).to.equal(10)
		
	end)
	
end
