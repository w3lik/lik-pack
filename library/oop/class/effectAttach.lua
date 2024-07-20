---@class EffectAttachClass:Class
local class = Class(EffectAttachClass)

---@private
function class:construct(options)
    href(self, J.AddSpecialEffectTarget(options.model, options.attachUnit:handle(), options.attachPosition))
    self:propChange("model", "std", options.model, false)
    self:propChange("attachUnit", "std", options.attachUnit, false)
    self:propChange("attachPosition", "std", options.attachPosition, false)
    self:propChange("pile", "std", 0, false)
    self:prop("duration", options.duration)
end

---@private
function class:destruct()
    self:clear("durationTimer", true)
    local au = self:prop("attachUnit")
    if (isClass(au, UnitClass)) then
        ---@type Array
        local es = au:prop(EffectAttachClass)
        if (isClass(es, ArrayClass)) then
            es:set(self:model() .. self:attachPosition(), nil)
        end
    end
    self:clear("attachUnit")
end

---@private
function class:dePile()
    local pile = self:prop("pile")
    pile = pile - 1
    if (pile <= 0) then
        destroy(self)
    else
        self:prop("pile", pile)
    end
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 获取模型路径
---@return string
function class:model()
    return self:prop("model")
end

--- 获取绑定单位
---@return Unit
function class:attachUnit()
    return self:prop("attachUnit")
end

--- 获取绑定定位
---@return string
function class:attachPosition()
    return self:prop("attachPosition")
end

--- 持续时间
---@param modify number|nil
---@return self|number
function class:duration(modify)
    return self:prop("duration", modify)
end