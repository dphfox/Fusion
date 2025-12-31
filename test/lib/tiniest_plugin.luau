-- From dphfox/tiniest, licenced under MIT
--!strict

export type Plugin = {
	is_tiniest_plugin: true
}

local tiniest_plugin = {}

function tiniest_plugin.configure(
	plugins: {any}?
)
	if plugins ~= nil then
		for index, plugin in plugins do
			if not plugin.is_tiniest_plugin then
				error(`sanity check: plugin #{index} is not a valid plugin`)
			end
		end
	end

	local self = {}

	function self.notify(
		method_name: string,
		...
	): ()
		if plugins == nil then
			return
		end
		for _, plugin in plugins do
			local method = plugin[method_name]
			if typeof(method) == "function" then
				method(...)
			end
		end
	end

	return self
end

return tiniest_plugin