---@class BuffClass:Class
local class = Class(BuffClass)

---@private
function class:construct(options)
    if (options.obj:prop("buffs") == nil) then
        options.obj:prop("buffs", Array())
    end
    self:prop("obj", options.obj)
    self:prop("key", options.key)
    self:prop("duration", -1)
    self:prop("visible", true)
    self:prop("purpose", nil)
    self:prop("rollback", nil)
    self:prop("running", false)
    self:prop("description", nil)
end

---@private
function class:destruct()
    if (self:isRunning()) then
        self:rollback()
    end
end

--- 对应对象
---@return Object
function class:obj()
    return self:prop("obj")
end

--- 唯一key
---@return string
function class:key()
    return self:prop("key")
end

--- 剩余时间
---@param variety number|string|nil
---@return self|number
function class:remain(variety)
    ---@type Timer
    local durationTimer = self:prop("durationTimer")
    if (false == isClass(durationTimer, TimerClass)) then
        return 0
    end
    return durationTimer:remain(variety)
end

--- 持续时间（默认-1）
---@param modify number
---@return self|number
function class:duration(modify)
    return self:prop("duration", modify)
end

--- 可视判断
--- 可根据此值决定UI显隐等，默认true
---@param modify nil|boolean
---@return self|boolean
function class:visible(modify)
    return self:prop("visible", modify)
end

--- 凸显信息（一般为图标中间文本）
---@param modify string|nil
---@return self|string|nil
function class:text(modify)
    if (type(modify) == "string") then
        return self:prop("text", modify)
    end
    return self:prop("text")
end

--- 标识
--- 例如增益buff可以给个标识up，负面buff可以给个down，用以区分buff种类
---@param modify string|nil
---@return self|string|nil
function class:signal(modify)
    return self:prop("signal", modify)
end

--- 是否在执行中
---@param modify boolean|nil
---@return self|boolean|nil
function class:isRunning(modify)
    return self:prop("running", modify)
end

--- 预期执行函数
---@alias buffCallFunc fun(buffObj:Object):void
---@param modify buffCallFunc|nil
---@return self|buffCallFunc
function class:purpose(modify)
    if modify ~= nil then
        if type(modify) == "function" then
            self:prop("purpose", modify)
        else
            self:clear("purpose")
        end
        return self
    end
    return self:prop("purpose")
end

--- 最终回滚函数
---@param modify buffCallFunc|nil
---@return self|buffCallFunc
function class:rollback(modify)
    if modify ~= nil then
        if type(modify) == "function" then
            self:prop("rollback", modify)
        else
            self:clear("rollback")
        end
        return self
    end
    return self:prop("rollback")
end

--- 执行回滚
---@return void
function class:back()
    if (self:isRunning()) then
        local rollback = self:rollback()
        local o = self:obj()
        if (isDestroy(o) == false) then
            if (type(rollback) == "function") then
                rollback(o)
                o:buffs():set(self:id(), nil)
            end
        end
        local durationTimer = self:prop("durationTimer")
        if (isClass(durationTimer, TimerClass)) then
            self:clear("durationTimer", true)
            durationTimer = nil
        end
        self:isRunning(false)
    end
    destroy(self)
end

--- 执行预期
---@return void
function class:run()
    if (false == self:isRunning()) then
        local o = self:obj()
        if (isDestroy(o) == false) then
            self:isRunning(true)
            local purpose = self:purpose()
            if (type(purpose) == "function") then
                purpose(o)
            end
            o:buffs():set(self:id(), self)
            local dur = self:duration()
            if (dur > 0) then
                self:prop("durationTimer", time.setTimeout(dur, function()
                    self:back()
                end))
            end
        end
    end
end

--- 状态名称
---@param modify string|nil
---@return self|string
function class:name(modify)
    if (type(modify) == "string") then
        return self:prop("name", modify)
    end
    local k = self:key()
    local c, _ = buff.conf(k)
    return self:prop("name") or c or k
end

--- 状态图标
---@param modify nil|string
---@return self|string
function class:icon(modify)
    if (type(modify) == "string") then
        return self:prop("icon", assets.icon(modify))
    end
    local _, ic = buff.conf(self:key())
    return self:prop("icon") or ic or "Framework\\ui\\default.tga"
end

--- 状态描述体
---@alias noteBuffDescription fun(obj:Buff):string[]
---@param modify nil|string[]|string|noteBuffDescription
---@return self|string[]
function class:description(modify)
    local mType = type(modify)
    if (mType == "string" or mType == "table" or mType == "function") then
        return self:prop("description", modify)
    end
    local desc = { self:name() }
    local d = self:prop("description")
    if (type(d) == "string") then
        desc[#desc + 1] = d
    elseif (type(d) == "table") then
        for _, v in ipairs(d) do
            desc[#desc + 1] = tostring(v)
        end
    elseif (type(d) == "function") then
        desc = table.merge(desc, d(self))
    end
    return desc
end