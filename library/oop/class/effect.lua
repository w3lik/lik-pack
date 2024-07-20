---@class EffectClass:Class
local class = Class(EffectClass)

---@private
function class:construct(options)
    href(self, J.AddSpecialEffect(options.model, options.x, options.y))
    options.x = options.x or 0
    options.y = options.y or 0
    options.z = options.z or japi.Z(options.x, options.y)
    japi.YD_SetEffectZ(self:handle(), options.z)
    self:propChange("restruct", "std", Array(), false)
    self:propChange("model", "std", options.model, false)
    self:propChange("positionOrigin", "std", { options.x, options.y, options.z }, false)
    self:propChange("position", "std", { options.x, options.y, options.z }, false)
    self:propChange("size", "std", 1, false)
    self:propChange("speed", "std", 1, false)
    self:propChange("rotateX", "std", 0, false)
    self:propChange("rotateY", "std", 0, false)
    self:propChange("rotateZ", "std", 0, false)
    self:prop("duration", options.duration)
end

function class:destruct()
    self:clear("restruct", true)
    self:clear("durationTimer", true)
end

---@private onlySync
function class:restruct()
    local re = self:prop("restruct")
    if (isClass(re, ArrayClass)) then
        local eks = re:keys()
        for _, k in ipairs(eks) do
            self:modifier(k, self:propValue(k))
        end
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

--- 获取 X 坐标
---@return number
function class:x()
    return self:prop("position")[1]
end

--- 获取 Y 坐标
---@return number
function class:y()
    return self:prop("position")[2]
end

--- 获取 Z 坐标
---@return number
function class:z()
    return self:prop("position")[3]
end

--- 移动到X,Y,Z坐标
---@param x number|nil
---@param y number|nil
---@param z number|nil
---@return void
function class:position(x, y, z)
    if (type(x) == "number" and type(y) == "number") then
        self:prop("position", { x, y, z })
    end
end

--- 重置特效
---@return void
function class:reset()
    japi:EXEffectMatReset(self:handle())
end

--- 特效大小
---@param modify number|nil
---@return self|number
function class:size(modify)
    return self:prop("size", modify)
end

--- 特效速度
---@param modify number|nil
---@return self|number
function class:speed(modify)
    return self:prop("speed", modify)
end

--- 特效X轴翻转角度
---@param modify number|nil
---@return self|number
function class:rotateX(modify)
    return self:prop("rotateX", modify)
end

--- 特效Y轴翻转角度
---@param modify number|nil
---@return self|number
function class:rotateY(modify)
    return self:prop("rotateY", modify)
end

--- 特效Z轴翻转角度
---@param modify number|nil
---@return self|number
function class:rotateZ(modify)
    return self:prop("rotateZ", modify)
end

--- 持续时间
---@param modify number|nil
---@return self|number
function class:duration(modify)
    return self:prop("duration", modify)
end