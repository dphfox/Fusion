--[[
    This is a semantically identical implementation to Rodux::NoYield

    noYield takes a callback and accepts multiple arguments
    
    This function will return the result of the callback to the consumer but will
    throw an error if the callback attempts to yield.

    It does this in 3 main steps:

    1. Creates a coroutine thread via coroutine.create 
    2. Resumes the thread and feed its return values to the result handler.
    3. Inspect whether the callback failed or if the thread is in a dead state. 
]]

local function resultHandler(thread, ok: boolean, ...) 
    if not ok then 
        -- We have to wrap it around with parantheses to prevent the return values to pollute the level argument
        error(debug.traceback(thread, (...)), 2)
    end

    if coroutine.status(thread) ~= "dead" then 
        error(debug.traceback(thread, "Attempted to yield inside of a Computed"), 2)
    end

    return ...
end

local function noYield(callback: (any) -> any, ...) 
    local thread = coroutine.create(callback)

    -- Potentially could use the task library here but concept of continuations isn't important here.
    return resultHandler(thread, coroutine.resume(thread, ...))
end

return noYield