---@class LightningChainClass:Class
local class = Class(LightningChainClass)

---@private
function class:construct(options)
    self:propChange("lightningType", "std", options.lightningType, false)
    self:propChange("rgba", "std", { 255, 255, 255, 255 }, false)
    self:propChange("duration", "std", -1, false)
    local unit1, unit2 = options.unit1, options.unit2
    local x1, y1, z1 = unit1:x(), unit1:y(), unit1:h()
    local x2, y2, z2 = unit2:x(), unit2:y(), unit2:h()
    self:prop("unit1", unit1)
    self:prop("unit2", unit2)
    self._handle = J.AddLightningEx(options.lightningType.value, false, x1, y1, z1, x2, y2, z2)
    effector(options.lightningType.effect, x2, y2, z2, 0.25)
end

---@private
function class:destruct()
    self:clear("chainTimer", true)
    self:clear("durationTimer", true)
    if (type(self._handle) == "number") then
        J.DestroyLightning(self._handle)
    end
end

--- key
---@return self|number
function class:handle()
    return self._handle
end

--- 闪电类型
---@param modify table LIGHTNING_TYPE
---@return self|table
function class:lightningType(modify)
    return self:prop("lightningType", modify)
end

--- 设置链条颜色
---@param red number 红0-255
---@param green number 绿0-255
---@param blue number 蓝0-255
---@param alpha number 透明度0-255
---@param duration number 持续时间 -1无限
---@return self|Array
function class:rgba(red, green, blue, alpha, duration)
    if (type(red) == "number" and type(green) == "number" and type(blue) == "number" and type(alpha) == "number") then
        return self:prop("rgba", { red, green, blue, alpha }, duration)
    end
    return self:prop("rgba")
end

--- 持续时间
---@param modify number
---@return self|number
function class:duration(modify)
    return self:prop("duration", modify)
end

--- 连锁单位1
---@param modify Unit|nil
---@return self|Unit
function class:unit1(modify)
    return self:prop("unit1", modify)
end

--- 连锁单位2
---@param modify Unit|nil
---@return self|Unit
function class:unit2(modify)
    return self:prop("unit2", modify)
end