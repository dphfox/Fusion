--[[
	Given a reactive object, updates all dependent reactive objects.
	Objects are only ever updated after all of their dependencies are updated,
	are only ever updated once, and won't be updated if their dependencies are
	unchanged.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function updateAll(ancestor: Types.Dependency<any>)
	--[[
		First things first, we need to mark all indirect dependents as needing
		an update. This means we can ignore any dependencies that aren't related
		to the current update operation.
	]]

	-- set of all dependents that still need to be updated
	local needsUpdateSet: Types.Set<Types.Dependent<any>> = {}
	-- the dependents to be processed now
	local processNow: {Types.Dependent<any>} = {}
	local processNowSize = 0
	-- the dependents of the open set to be processed next
	local processNext: {Types.Dependent<any>} = {}
	local processNextSize = 0

	-- initialise `processNow` with dependents of ancestor
	for dependent in pairs(ancestor.dependentSet) do
		processNowSize += 1
		processNow[processNowSize] = dependent
	end

	repeat
		-- if we add to `processNext` this will be false, indicating we need to
		-- process more dependents
		local processingDone = true

		for _, member in ipairs(processNow) do
			-- mark this member as needing an update
			needsUpdateSet[member] = true

			-- add the dependents of the member for processing
			if member.dependentSet ~= nil then
				for dependent in pairs(member.dependentSet) do
					processNextSize += 1
					processNext[processNextSize] = dependent
					processingDone = false
				end
			end
		end

		-- swap in the next dependents to be processed
		processNow, processNext = processNext, processNow
		processNowSize, processNextSize = processNextSize, 0
		table.clear(processNext)
	until processingDone

	--[[
		`needsUpdateSet` is now set up. Now that we have this information, we
		can iterate over the dependents once more and update them only when the
		relevant dependencies have been updated.
	]]

	-- re-initialise `processNow` similar to before
	processNowSize = 0
	table.clear(processNow)
	for dependent in pairs(ancestor.dependentSet) do
		processNowSize += 1
		processNow[processNowSize] = dependent
	end

	repeat
		-- if we add to `processNext` this will be false, indicating we need to
		-- process more dependents
		local processingDone = true

		for _, member in ipairs(processNow) do
			-- mark this member as no longer needing an update
			needsUpdateSet[member] = nil

			--FUTURE: should this guard against errors?
			local didChange = member:update()

			-- add the dependents of the member for processing
			-- optimisation: if nothing changed, then we don't need to add these
			-- dependents, because they don't need processing.
			if didChange and member.dependentSet ~= nil then
				for dependent in pairs(member.dependentSet) do
					-- don't add dependents that have un-updated dependencies
					local allDependenciesUpdated = true
					for dependentDependency in pairs(dependent.dependencySet) do
						if needsUpdateSet[dependentDependency] then
							allDependenciesUpdated = false
							break
						end
					end

					if allDependenciesUpdated then
						processNextSize += 1
						processNext[processNextSize] = dependent
						processingDone = false
					end
				end
			end
		end

		if not processingDone then
			-- swap in the next dependents to be processed
			processNow, processNext = processNext, processNow
			processNowSize, processNextSize = processNextSize, 0
			table.clear(processNext)
		end
	until processingDone

	--[[
		The update is now complete!
	]]
end

return updateAll