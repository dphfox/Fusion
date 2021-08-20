--[[
	Allows creation of expectation statements designed for behavior-driven
	testing (BDD). See Chai (JS) or RSpec (Ruby) for examples of other BDD
	frameworks.

	The Expectation class is exposed to tests as a function called `expect`:

		expect(5).to.equal(5)
		expect(foo()).to.be.ok()

	Expectations can be negated using .never:

		expect(true).never.to.equal(false)

	Expectations throw errors when their conditions are not met.
]]

local Expectation = {}

--[[
	These keys don't do anything except make expectations read more cleanly
]]
local SELF_KEYS = {
	to = true,
	be = true,
	been = true,
	have = true,
	was = true,
	at = true,
}

--[[
	These keys invert the condition expressed by the Expectation.
]]
local NEGATION_KEYS = {
	never = true,
}

--[[
	Extension of Lua's 'assert' that lets you specify an error level.
]]
local function assertLevel(condition, message, level)
	message = message or "Assertion failed!"
	level = level or 1

	if not condition then
		error(message, level + 1)
	end
end

--[[
	Returns a version of the given method that can be called with either . or :
]]
local function bindSelf(self, method)
	return function(firstArg, ...)
		if firstArg == self then
			return method(self, ...)
		else
			return method(self, firstArg, ...)
		end
	end
end

local function formatMessage(result, trueMessage, falseMessage)
	if result then
		return trueMessage
	else
		return falseMessage
	end
end

--[[
	Create a new expectation
]]
function Expectation.new(value)
	local self = {
		value = value,
		successCondition = true,
		condition = false,
		matchers = {},
		_boundMatchers = {},
	}

	setmetatable(self, Expectation)

	self.a = bindSelf(self, self.a)
	self.an = self.a
	self.ok = bindSelf(self, self.ok)
	self.equal = bindSelf(self, self.equal)
	self.throw = bindSelf(self, self.throw)
	self.near = bindSelf(self, self.near)

	return self
end

function Expectation.checkMatcherNameCollisions(name)
	if SELF_KEYS[name] or NEGATION_KEYS[name] or Expectation[name] then
		return false
	end

	return true
end

function Expectation:extend(matchers)
	self.matchers = matchers or {}

	for name, implementation in pairs(self.matchers) do
		self._boundMatchers[name] = bindSelf(self, function(_self, ...)
			local result = implementation(self.value, ...)
			local pass = result.pass == self.successCondition

			assertLevel(pass, result.message, 3)
			self:_resetModifiers()
			return self
		end)
	end

	return self
end

function Expectation.__index(self, key)
	-- Keys that don't do anything except improve readability
	if SELF_KEYS[key] then
		return self
	end

	-- Invert your assertion
	if NEGATION_KEYS[key] then
		local newExpectation = Expectation.new(self.value):extend(self.matchers)
		newExpectation.successCondition = not self.successCondition

		return newExpectation
	end

	if self._boundMatchers[key] then
		return self._boundMatchers[key]
	end

	-- Fall back to methods provided by Expectation
	return Expectation[key]
end

--[[
	Called by expectation terminators to reset modifiers in a statement.

	This makes chains like:

		expect(5)
			.never.to.equal(6)
			.to.equal(5)

	Work as expected.
]]
function Expectation:_resetModifiers()
	self.successCondition = true
end

--[[
	Assert that the expectation value is the given type.

	expect(5).to.be.a("number")
]]
function Expectation:a(typeName)
	local result = (type(self.value) == typeName) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		),
		("Expected value not of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

-- Make alias public on class
Expectation.an = Expectation.a

--[[
	Assert that our expectation value is truthy
]]
function Expectation:ok()
	local result = (self.value ~= nil) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value %q to be non-nil"):format(
			tostring(self.value)
		),
		("Expected value %q to be nil"):format(
			tostring(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our expectation value is equal to another value
]]
function Expectation:equal(otherValue)
	local result = (self.value == otherValue) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value %q (%s), got %q (%s) instead"):format(
			tostring(otherValue),
			type(otherValue),
			tostring(self.value),
			type(self.value)
		),
		("Expected anything but value %q (%s)"):format(
			tostring(otherValue),
			type(otherValue)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our expectation value is equal to another value within some
	inclusive limit.
]]
function Expectation:near(otherValue, limit)
	assert(type(self.value) == "number", "Expectation value must be a number to use 'near'")
	assert(type(otherValue) == "number", "otherValue must be a number")
	assert(type(limit) == "number" or limit == nil, "limit must be a number or nil")

	limit = limit or 1e-7

	local result = (math.abs(self.value - otherValue) <= limit) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value to be near %f (within %f) but got %f instead"):format(
			otherValue,
			limit,
			self.value
		),
		("Expected value to not be near %f (within %f) but got %f instead"):format(
			otherValue,
			limit,
			self.value
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our functoid expectation value throws an error when called.
	An optional error message can be passed to assert that the error message
	contains the given value.
]]
function Expectation:throw(messageSubstring)
	local ok, err = pcall(self.value)
	local result = ok ~= self.successCondition

	if messageSubstring and not ok then
		if self.successCondition then
			result = err:find(messageSubstring, 1, true) ~= nil
		else
			result = err:find(messageSubstring, 1, true) == nil
		end
	end

	local message

	if messageSubstring then
		message = formatMessage(self.successCondition,
			("Expected function to throw an error containing %q, but it %s"):format(
				messageSubstring,
				err and ("threw: %s"):format(err) or "did not throw."
			),
			("Expected function to never throw an error containing %q, but it threw: %s"):format(
				messageSubstring,
				tostring(err)
			)
		)
	else
		message = formatMessage(self.successCondition,
			"Expected function to throw an error, but it did not throw.",
			("Expected function to succeed, but it threw an error: %s"):format(
				tostring(err)
			)
		)
	end

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

return Expectation
