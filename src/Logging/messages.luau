--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Stores templates for different kinds of logging messages.
]]

return {
	callbackError = "Error in callback:\nERROR_MESSAGE",
	cannotAssignProperty = "The class type '%s' has no assignable property '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have an event called '%s'.",
	cannotCreateClass = "Can't create a new instance of class '%s'.",
	cannotDepend = "%s can't depend on %s.",
	cleanupWasRenamed = "`Fusion.cleanup` was renamed to `Fusion.doCleanup`. This will be an error in future versions of Fusion.",
	destroyedTwice = "`doCleanup()` was given something that it is already cleaning up. Unclear how to proceed.",
	destructorRedundant = "%s destructors no longer do anything. If you wish to run code on destroy, `table.insert` a function into the `scope` argument. See discussion #292 on GitHub for advice.",
	forKeyCollision = "The key '%s' was returned multiple times simultaneously, which is not allowed in `For` objects.",
	infiniteLoop = "Detected an infinite loop. Consider adding an explicit breakpoint to your code to prevent a cyclic dependency.",
	invalidAttributeChangeHandler = "The change handler for the '%s' attribute must be a function.",
	invalidAttributeOutType = "[AttributeOut] properties must be given Value objects.",
	invalidChangeHandler = "The change handler for the '%s' property must be a function.",
	invalidEventHandler = "The handler for the '%s' event must be a function.",
	invalidOutProperty = "The %s class doesn't have a property called '%s'.",
	invalidOutType = "[Out] properties must be given Value objects.",
	invalidPropertyType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	invalidRefType = "Instance refs must be Value objects.",
	invalidSpringDamping = "The damping ratio for a spring must be >= 0. (damping was %.2f)",
	invalidSpringSpeed = "The speed of a spring must be >= 0. (speed was %.2f)",
	mergeConflict = "Multiple definitions for '%s' found while merging.",
	mistypedSpringDamping = "The damping ratio for a spring must be a number. (got a %s)",
	mistypedSpringSpeed = "The speed of a spring must be a number. (got a %s)",
	mistypedTweenInfo = "The tween info of a tween must be a TweenInfo. (got a %s)",
	noTaskScheduler = "Fusion is not connected to an external task scheduler.",
	poisonedScope = "Attempted to use a scope after it's been destroyed; %s",
	possiblyOutlives = "%s will be destroyed before %s; %s. To fix this, review the order they're created in, and what scopes they belong to. See discussion #292 on GitHub for advice.",
	propertySetError = "Error setting property:\nERROR_MESSAGE",
	scopeMissing = "To create %s, provide a scope. (e.g. `%s`). See discussion #292 on GitHub for advice.",
	springNanGoal = "A spring was given a NaN goal, so some simulation has been skipped. Ensure no springs have NaN goals.",
	springNanMotion = "A spring encountered NaN during motion, so has snapped to the goal position. Ensure no springs have NaN positions or velocities.",
	springTypeMismatch = "The type '%s' doesn't match the spring's type '%s'.",
	stateGetWasRemoved = "`StateObject:get()` has been replaced by `use()` and `peek()` - see discussion #217 on GitHub.",
	tweenNanGoal = "A tween was given a NaN goal, so some animation has been skipped. Ensure no tweens have NaN goals.",
	tweenNanMotion = "A tween encountered NaN during motion, so has snapped to the goal. Ensure no tweens have NaN in their tween infos.",
	unknownMessage = "Unknown error:\nERROR_MESSAGE",
	unrecognisedChildType = "'%s' type children aren't accepted by `[Children]`.",
	unrecognisedPropertyKey = "'%s' keys aren't accepted in property tables.",
	unrecognisedPropertyStage = "'%s' isn't a valid stage for a special key to be applied at.",
	useAfterDestroy = "%s is no longer valid - it was destroyed before %s. See discussion #292 on GitHub for advice."
}