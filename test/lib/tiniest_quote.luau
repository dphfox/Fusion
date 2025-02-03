-- From dphfox/tiniest, licenced under MIT
--!strict

local function tiniest_quote(
	x: unknown,
	given_indent_amount: number?
): string
	if 
		type(x) == "nil" or 
		type(x) == "number" or 
		type(x) == "boolean" or 
		type(x) == "userdata"
	then
		return tostring(x)
	elseif type(x) == "string" then
		return string.format("%q", x)
	elseif type(x) == "function" then
		return "function() ... end"
	elseif type(x) == "table" then
		local outer_indent_amount = given_indent_amount or 0
		local inner_indent_amount = outer_indent_amount + 1
		local outer_indent = string.rep("  ", outer_indent_amount)
		local inner_indent = string.rep("  ", inner_indent_amount)

		local tbl: {} = x :: any
		local sorted_pairs = {}
		for key, value in tbl do
			table.insert(sorted_pairs, {
				key = tiniest_quote(key, inner_indent_amount),
				value = tiniest_quote(value, inner_indent_amount)
			})
		end
		table.sort(sorted_pairs, function(a, b)
			return a.key < b.key
		end)
		local frozen = table.isfrozen(tbl)
		local lines = {if frozen then "table.freeze {" else "{"}
		for _, pair in sorted_pairs do
			table.insert(lines, `{inner_indent}[{pair.key}] = {pair.value};`)
		end
		table.insert(lines, outer_indent .. "}")
		return table.concat(lines, "\n")
	else
		return `{type(x)}({tostring(x)})`
	end
end

return tiniest_quote :: (unknown) -> string 