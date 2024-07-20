---@class async
async = async or {}

---@private
async._id = async._id or 0

--- 是否异步
function async.is()
    return async._id > 0
end

--- 限制必须异步
function async.must()
    must(async.is(), "asyncCheck")
end

--- 异步调用，使用此方法后回调强制异步
---@param asyncPlayer Player
---@param callFunc function
function async.call(asyncPlayer, callFunc)
    if (asyncPlayer:handle() == J.Common["GetLocalPlayer"]()) then
        local aid = async._id
        async._id = asyncPlayer:index() -- 异步的
        J.Promise(callFunc)
        async._id = aid -- 异步的
    end
end

-- 设置一次性异步时帧器
---@param frame number
---@param callFunc fun(curTimer:TimerAsync):void
---@return TimerAsync
function async.setTimeout(frame, callFunc)
    return TimerAsync(false, frame, callFunc)
end

--- 设置周期性异步时帧器
---@param frame number
---@param callFunc fun(curTimer:TimerAsync):void
---@return TimerAsync
function async.setInterval(frame, callFunc)
    return TimerAsync(true, frame, callFunc)
end