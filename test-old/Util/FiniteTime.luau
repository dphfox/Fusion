--!strict

local FiniteTime = {}

local DEFAULT_TIME_LIMIT = 1 / 10

function FiniteTime.start(
	timeLimit: number?
): () -> ()
	local endTime = os.clock() + (timeLimit or DEFAULT_TIME_LIMIT)
	local errored = false
	local function check()
		if os.clock() > endTime and not errored then
			errored = true
			error("Finite time limit reached. (FUSION_TEST_FINITE_TIME)", 0)
		end
	end

	return check
end

return FiniteTime