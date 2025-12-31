-- From dphfox/tiniest, licenced under MIT
--!strict

local tiniest_quote = require("./tiniest_quote")

local tiniest_expect = {}

type Context = {
	target: unknown,
	test: string,
	params: {unknown}
}

local context: Context = {
	target = nil,
	test = "",
	params = {}
}

local function fail(
	message: string?
): never
	local quoted = {}
	for index, param in context.params do
		quoted[index] = tiniest_quote(param)
	end
	local param_list = table.concat(quoted, ",")
	error({
		type = "tiniest.ErrorReport",
		message = "Expectation not met" .. if message == nil then "" else `, because:\n{message}`,
		trace = debug.traceback(nil, 4),
		code = {
			snippet = `expect({tiniest_quote(context.target)}).{context.test}({param_list})`,
			line = debug.info(4, "l")
		}
	}, 0)
end

local function check(
	condition: boolean,
	cause: string
): ()
	if not condition then
		error(`Bad usage of expect().{context.test}()\nCause: {cause}`, 0)
	end
end

local function is_indexable(
	x: unknown
): boolean
	return type(x) == "table" or type(x) == "userdata"
end

function tiniest_expect.expect(
	a: any
)
	local tests = {}

	function tests.exists()
		return if a ~= nil then tests else fail()
	end

	function tests.never_exists()
		return if a == nil then tests else fail()
	end

	function tests.is(
		b: any
	)
		return if a == b then tests else fail()
	end

	function tests.never_is(
		b: any
	)
		return if a ~= b then tests else fail()
	end

	function tests.is_true()
		check(typeof(a) == "boolean", "expect() value must be boolean")
		return if a then tests else fail()
	end

	function tests.never_is_true()
		check(typeof(a) == "boolean", "expect() value must be boolean")
		return if a then tests else fail()
	end

	function tests.is_a(
		b: string
	)
		return if typeof(a) == b then tests else fail()
	end

	function tests.never_is_a(
		b: string
	)
		return if typeof(a) ~= b then tests else fail()
	end

	function tests.has_key(
		b: any
	)
		check(is_indexable(a), "expect() value must be indexable")
		check(b ~= nil, "key cannot be nil")
		return if a[b] then tests else fail()
	end

	function tests.never_has_key(
		b: any
	)
		check(is_indexable(a), "expect() value must be indexable")
		check(b ~= nil, "key cannot be nil")
		return if not a[b] then tests else fail(`[{tiniest_quote(b)}] = {tiniest_quote(a[b])}`)
	end

	function tests.has_value(
		b: any
	)
		check(typeof(a) == "table", "expect() value must be table")
		check(b ~= nil, "value cannot be nil")
		return if table.find(a, b) then tests else fail()
	end

	function tests.never_has_value(
		b: any
	)
		check(typeof(a) == "table", "expect() value must be table")
		check(b ~= nil, "value cannot be nil")
		local index = table.find(a, b)
		return if index ~= nil then tests else fail(`Found at index {index}`)
	end

	function tests.fails()
		check(typeof(a) == "function", "expect() value must be function")
		local ok = pcall(a)
		return if not ok then tests else fail()
	end

	function tests.never_fails()
		check(typeof(a) == "function", "expect() value must be function")
		local ok, err = pcall(a)
		return if ok then tests else fail(`Failed with {tiniest_quote(err)}`)
	end

	function tests.fails_with(
		b: string
	)
		check(typeof(a) == "function", "expect() value must be function")
		local ok, err = pcall(a)
		return if not ok and err:lower():match(b:lower()) then tests else
				if ok then fail("Did not fail")
				else fail(`Failed with {tiniest_quote(err)}`)
	end

	function tests.never_fails_with(
		b: string
	)
		check(typeof(a) == "function", "expect() value must be function")
		local ok, err = pcall(a)
		return if ok or not err:lower():match(b:lower()) then tests else fail()
	end

	for name: any, body: any in tests do
		tests[name] = function(...)
			context.target = a
			context.test = name
			context.params = {...}
			return body(...)
		end
	end

	return tests
end

return tiniest_expect