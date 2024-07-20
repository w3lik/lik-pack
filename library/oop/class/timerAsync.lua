---@class TimerAsyncClass:Class
local class = Class(TimerAsyncClass)

---@private
function class:construct(options)
    self._aid = async._id
    self._period = options.period
    self._interval = options.interval
    self._callFunc = function()
        options.callFunc(self)
        if (true == self._interval) then
            if (self._fin ~= -1) then
                self:run()
            end
        else
            destroy(self)
        end
    end
    self:run()
end

--- destruct
---@private
function class:destruct()
    japi.CancelAsyncExecDelay(self._execId)
    self._execId = nil
    self._fin = -1
end

--- 获取是否循环计帧器
---@return boolean
function class:interval()
    return self._interval
end

--- 获取剩余帧数
---@return number
function class:remain()
    local remain = self._pause or -1
    local l = self._fin or 0
    if (remain == -1) then
        if (l > 0) then
            remain = l - japi._asyncRefreshInc
        end
    end
    return remain
end

--- 设置剩余帧数
---@param frame number
---@return void
function class:setRemain(frame)
    frame = math.min(frame, self._period)
    japi.CancelAsyncExecDelay(self._execId)
    self:run(frame)
end

--- 获取|重置周期帧数
---@param frame nil|number integer 帧值
---@return number|self
function class:period(frame)
    if (frame) then
        self._period = frame
        return self
    end
    return self._period
end

--- 获取已逝帧数（周期帧数-剩余帧数）
---@return number
function class:elapsed()
    return math.max(0, self._period - self:remain())
end

--- 运行计帧器
---@param period number sec 指定当前倒计帧数，不设置时则为当前设定周期
---@return void
function class:run(period)
    period = period or self._period
    self._execId = japi.AsyncExecDelay(period, self._aid, self._callFunc)
    local ids = string.explode('#', self._execId)
    self._fin = math.round(ids[1])
end

--- 暂停计帧器
---@return void
function class:pause()
    if (self._fin > japi._asyncRefreshInc) then
        japi.CancelAsyncExecDelay(self._execId)
        self._pause = self._fin - japi._asyncRefreshInc
    end
    self._execId = nil
    self._fin = -1
end

--- 恢复计帧器
---@return void
function class:resume()
    if (type(self._pause) == "number") then
        self:run(self._pause)
        self._pause = nil
    end
end