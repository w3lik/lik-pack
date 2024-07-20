---@class AuraClass:Class
local class = Class(AuraClass)

---@private
function class:construct()
    self:prop("name", "Aura")
    self:prop("duration", -1)
    self:propChange("radius", "std", 0, false)
    self:propChange("frequency", "std", 1.0, false)
end

---@private
function class:unEvent()
    self:clear("eventTimer", true)
    self:clear("durationTimer", true)
    local prevUnit = self:prop("prevUnits")
    if (type(prevUnit) == "table") then
        for _, u in ipairs(prevUnit) do
            event.syncTrigger(self, EVENT.Aura.Leave, { triggerUnit = u })
        end
    end
    self:clear("prevUnits")
end

---@private
function class:destruct()
    self:clear("centerUnit")
    self:clear("centerEffectObj", true)
    self:unEvent()
end

--- 本对象事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onEvent(evt, ...)
    self:prop("useEvent", true)
    event.syncRegister(self, evt, ...)
    return self
end

--- key
---@return self|string|nil
function class:key()
    return self:prop("key")
end

--- 领域名
---@param modify string|nil
---@return self|string
function class:name(modify)
    return self:prop("name", modify)
end

--- 作用半径
---@param modify number|nil
---@return self|number
function class:radius(modify)
    return self:prop("radius", modify)
end

--- 监听频率[秒]
---@param modify number|nil
---@return self|number
function class:frequency(modify)
    return self:prop("frequency", modify)
end

--- 绑定的中心单位
---@param modify Unit|nil
---@return self|Unit
function class:centerUnit(modify)
    return self:prop("centerUnit", modify)
end

--- 绑定的中心坐标
---@param modify number[]|nil
---@return self|number[]
function class:centerPosition(modify)
    if (type(modify) == "table") then
        modify[3] = modify[3] or japi.Z(modify[1], modify[2])
        return self:prop("centerPosition", modify)
    end
    return self:prop("centerPosition")
end

--- 绑定的中心特效
---@param effect string|nil 特效路径
---@param attach string|nil
---@param size number|nil 中心特效缩放，默认1.0
---@return self|{string,number,string}
function class:centerEffect(effect, attach, size)
    if (effect or size or attach) then
        return self:prop("centerEffect", { effect, attach, size })
    end
    return self:prop("centerEffect")
end

--- 持续时间
---@param modify number|nil
---@return self|number
function class:duration(modify)
    return self:prop("duration", modify)
end

--- 作用单位匹配器
---@alias noteAuraFilter fun(enumUnit:Unit):boolean
---@param modify noteAuraFilter|nil
---@return self|noteAuraFilter
function class:filter(modify)
    return self:prop("filter", modify)
end

--- 作用上限
---@param modify number|nil
---@return self|number
function class:limit(modify)
    return self:prop("limit", modify)
end

--- 中心X
---@return number
function class:x()
    local o = self:prop("centerUnit") or self:prop("centerPosition")
    if (isClass(o, UnitClass)) then
        return o:x()
    elseif (type(o) == "table") then
        return o[1]
    end
    return 0
end

--- 中心Y
---@return number
function class:y()
    local o = self:prop("centerUnit") or self:prop("centerPosition")
    if (isClass(o, UnitClass)) then
        return o:y()
    elseif (type(o) == "table") then
        return o[2]
    end
    return 0
end

--- 中心Z
---@return number
function class:z()
    local o = self:prop("centerUnit") or self:prop("centerPosition")
    if (isClass(o, UnitClass)) then
        return o:z()
    elseif (type(o) == "table") then
        return o[3]
    end
    return 0
end

--- 内部随机坐标
---@return number,number
function class:rand()
    return vector2.polar(self:x(), self:y(), self:radius(), math.rand(0, 359))
end