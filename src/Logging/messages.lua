--!strict

--[[
	Stores templates for different kinds of logging messages.
]]

return {
	cannotAssignProperty = "The class type '%s' has no assignable property '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have an event called '%s'.",
	cannotCreateClass = "Can't create a new instance of class '%s'.",
	computedCallbackError = "Computed callback error: ERROR_MESSAGE",
	destructorNeededValue = "To save instances into Values, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	destructorNeededComputed = "To return instances from Computeds, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	multiReturnComputed = "Returning multiple values from Computeds is discouraged, as behaviour will change soon - see discussion #189 on GitHub.",
	destructorNeededForKeys = "To return instances from ForKeys, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	destructorNeededForValues = "To return instances from ForValues, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	destructorNeededForPairs = "To return instances from ForPairs, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	duplicatePropertyKey = "",
	forKeysProcessorError = "ForKeys callback error: ERROR_MESSAGE",
	forKeysKeyCollision = "ForKeys should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previously input key: '%s'; New input key: '%s'",
	forKeysDestructorError = "ForKeys destructor error: ERROR_MESSAGE",
	forPairsDestructorError = "ForPairs destructor error: ERROR_MESSAGE",
	forPairsKeyCollision = "ForPairs should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previous input pair: '[%s] = %s'; New input pair: '[%s] = %s'",
	forPairsProcessorError = "ForPairs callback error: ERROR_MESSAGE",
	forValuesProcessorError = "ForValues callback error: ERROR_MESSAGE",
	forValuesDestructorError = "ForValues destructor error: ERROR_MESSAGE",
	invalidChangeHandler = "The change handler for the '%s' property must be a function.",
	invalidEventHandler = "The handler for the '%s' event must be a function.",
	invalidPropertyType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	invalidRefType = "Instance refs must be Value objects.",
	invalidOutType = "[Out] properties must be given Value objects.",
	invalidOutProperty = "The %s class doesn't have a property called '%s'.",
	invalidSpringDamping = "The damping ratio for a spring must be >= 0. (damping was %.2f)",
	invalidSpringSpeed = "The speed of a spring must be >= 0. (speed was %.2f)",
	mistypedSpringDamping = "The damping ratio for a spring must be a number. (got a %s)",
	mistypedSpringSpeed = "The speed of a spring must be a number. (got a %s)",
	mistypedTweenInfo = "The tween info of a tween must be a TweenInfo. (got a %s)",
	springTypeMismatch = "The type '%s' doesn't match the spring's type '%s'.",
	strictReadError = "'%s' is not a valid member of '%s'.",
	unknownMessage = "Unknown error: ERROR_MESSAGE",
	unrecognisedChildType = "'%s' type children aren't accepted by `[Children]`.",
	unrecognisedPropertyKey = "'%s' keys aren't accepted in property tables.",
	unrecognisedPropertyStage = "'%s' isn't a valid stage for a special key to be applied at."
}