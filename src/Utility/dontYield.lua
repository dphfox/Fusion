--!nonstrict

--[[
    Utility function to throw an error when a function yields

    You can either provide a specific error message using the second
    parameter (errorMessage: string?), or you can let it default to the
    default error message (DEFAULT_ERROR_MESSAGE). Error message here
    means additional information that the user might find helpful to
    determine where the yielding is occurring. (i.e. "Cannot yield inside
    of the ComputedPairs processor function.",)
]]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)

local DEFAULT_ERROR_MESSAGE: string = "N/A"

--[[
    Handles the return values resulting from calling `coroutine.resume(func, ...)`
    We do this so that we can return the 
]]
local function handleResult(taskCoroutine, errorMessage, success, ...)
    if success then
        if coroutine.status(taskCoroutine) == "dead" then
            -- we didn't yield
            return ...
            
        else
            -- we yielded
            logError("cannotYield", ({...})[1], errorMessage or DEFAULT_ERROR_MESSAGE)
        end
    else
        -- this is a user error that has nothing to do with the thread yielding,
        -- so error like the user would normally expect it to
        error(debug.traceback(taskCoroutine, ...), 2)
    end
end

--[[
    Runs a task in a coroutine with the supplied parameters (...). If the task
    yields, then it will log the error `cannotYield`, and also display the supplied 
    error message (errorMessage), or `N/A`.
]]
local function dontYield(task, errorMessage: string?, ...)
    local taskCoroutine = coroutine.create(task)

    return handleResult(taskCoroutine, errorMessage, coroutine.resume(taskCoroutine, ...))
end

return dontYield