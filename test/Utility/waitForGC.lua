return function()
	local ref = setmetatable({ {} }, { __mode = "kv" })

	local lastLen = 1
	repeat
		table.insert(ref, {})
		lastLen = #ref
		print("waitForGC", lastLen)

		if #ref > 60 then
			error("Timed out waiting for garbage collection cycle")
		end

		task.wait(1)
	until #ref < lastLen
	print("waitForGC Done")
end