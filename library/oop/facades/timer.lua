---@class Timer:TimerClass
---@param interval boolean
---@param period number float
---@param callFunc fun(curTimer:Timer):Timer
---@return Timer
function Timer(interval, period, callFunc)
    sync.must()
    must(type(interval) == "boolean" and type(period) == "number" and type(callFunc) == "function")
    return Object(TimerClass, {
        options = {
            interval = interval,
            period = period,
            callFunc = callFunc,
        }
    })
end
