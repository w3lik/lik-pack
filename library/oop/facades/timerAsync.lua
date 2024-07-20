---@class TimerAsync:TimerAsyncClass
---@param frame number
---@param callFunc fun(curTimer:TimerAsync):void
---@return TimerAsync
function TimerAsync(interval, frame, callFunc)
    async.must()
    must(type(interval) == "boolean" and type(frame) == "number" and type(callFunc) == "function")
    return Object(TimerAsyncClass, {
        options = {
            interval = interval,
            period = frame,
            callFunc = callFunc,
        }
    })
end
