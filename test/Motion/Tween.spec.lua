local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.Core.Value)
local Tween = require(Package.Motion.Tween)
local New = require(Package.Instances.New)

return function()
	it("should construct a Tween object with default TweenInfo", function()
		local followerState = Value(1)
		local tween = Tween(followerState)

		expect(tween).to.be.a("table")
		expect(tween.type).to.equal("State")
		expect(tween.kind).to.equal("Tween")
	end)

	it("should not construct a Tween object with invalid TweenInfo", function()
		local followerState = Value(1)

		local incorrectTweenInfo = 5
		expect(function() Tween(followerState, incorrectTweenInfo) end).to.throw()

		local incorrectTweenInfoState = Value(5)
		expect(function() Tween(followerState, incorrectTweenInfoState) end).to.throw()
	end)

	it("should construct a Tween object with valid TweenInfo", function()
		local followerState = Value(1)

		local tweenInfo = TweenInfo.new()
		local normalInfotween = Tween(followerState, tweenInfo)
		expect(normalInfotween).to.be.a("table")
		expect(normalInfotween.type).to.equal("State")
		expect(normalInfotween.kind).to.equal("Tween")

		local stateTweenInfo = Value(TweenInfo.new())
		local stateTween = Tween(followerState, stateTweenInfo)
		expect(stateTween).to.be.a("table")
		expect(stateTween.type).to.equal("State")
		expect(stateTween.kind).to.equal("Tween")
	end)

	it("should update when it's watched state updates", function()
		local followerState = Value(UDim2.fromScale(1, 1))

		local tween = Tween(followerState, TweenInfo.new(0.1))
		local testInstance = New "Frame" { Size = tween }

		followerState:set(UDim2.fromScale(0.5, 0.5))

		-- wait for the tween to finish
		task.wait(0.5)

		expect(testInstance.Size.X.Scale).to.equal(0.5)
		expect(testInstance.Size.Y.Scale).to.equal(0.5)
	end)
end