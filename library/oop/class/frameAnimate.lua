---@class FrameAnimateClass:FrameCustomClass
local class = Class(FrameAnimateClass):extend(FrameCustomClass)

---@private
function class:construct()
    self:prop("duration", 1.0)
    self:prop("halt", 0)
    self:prop("step", 0)
    self:prop("texture", "Framework\\ui\\nil.tga")
end

---@private
function class:destruct()
    self:clear("stepTimer", true)
end

--- 贴图
---@protected
---@param modify string|nil
---@return self|string
function class:texture(modify)
    if (modify) then
        modify = assets.uikit(self:kit(), modify, "tga")
    end
    return self:prop("texture", modify)
end

--- 当停止播放时执行
--- halt不触发停止
---@param modify function|nil
---@return self|function
function class:onStop(modify)
    if (modify) then
        if (type(modify) == "function") then
            self:prop("onStop", modify)
        else
            self:clear("onStop")
        end
        return self
    end
    return self:prop("onStop")
end

--- 贴图动作集
---@param modify string[]|nil
---@return self|string[]
function class:motion(modify)
    return self:prop("motion", modify)
end

--- 动作持续时间
---@param modify number|nil
---@return self|number
function class:duration(modify)
    if (type(modify) == "number" and modify > 0) then
        self:prop("duration", modify)
        ---@type TimerAsync
        local stepTimer = self:prop("stepTimer")
        if (isClass(stepTimer, TimerAsyncClass)) then
            if (stepTimer:interval() == true) then
                stepTimer:period(modify / #self:motion() - stepTimer:period())
            end
        end
        return self
    end
    return self:prop("duration")
end

--- 动作中断间距
---@param modify number|nil
---@return self|number
function class:halt(modify)
    return self:prop("halt", modify)
end

--- 是否正在播放
---@return boolean
function class:isPlaying()
    return isClass(self:prop("stepTimer"), TimerAsyncClass)
end

---@param loop number 循环播放次数，默认1，-1则为无限循环
---@param isReset boolean 是否从头开始，默认nil(false)
---@return void
function class:play(loop, isReset)
    if (type(loop) ~= "number") then
        loop = 1
    end
    local stepTimer = self:prop("stepTimer")
    if (isClass(stepTimer, TimerAsyncClass)) then
        self:prop("stepTimer", true)
        stepTimer = nil
    end
    if (isReset == true) then
        self:prop("step", 0)
    end
    local m = self:motion()
    must(type(m) == "table" and #m > 0)
    local frequency = self:duration() / #m * 60
    stepTimer = async.setInterval(frequency, function(curTimer)
        local motion = self:motion()
        if (motion == nil) then
            self:stop()
            return
        end
        local step = self:prop("step")
        step = step + 1
        if (motion[step] == nil) then
            if (loop > 0) then
                loop = loop - 1
            end
            if (loop == 0 or motion[1] == nil) then
                self:stop()
                return
            end
            local halt = self:halt()
            if (halt > 0) then
                destroy(curTimer)
                self:prop("step", 0)
                self:prop("stepTimer", async.setTimeout(halt * 60, function()
                    self:clear("stepTimer")
                    self:play(loop, isReset)
                end))
                return
            end
            step = 1
        end
        self:prop("step", step)
        self:texture(motion[step])
    end)
    self:prop("stepTimer", stepTimer)
end

--- 停止播放
---@return void
function class:stop()
    local stepTimer = self:prop("stepTimer")
    if (isClass(stepTimer, TimerAsyncClass)) then
        self:clear("stepTimer", true)
        self:prop("step", 0)
        local onStop = self:onStop()
        if (type(onStop) == "function") then
            onStop(self)
        end
    end
end