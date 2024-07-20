---@class CoordinateClass:Class
local class = Class(CoordinateClass)

---@private
function class:construct(options)
    self:propChange("x", "std", options.x, false)
    self:propChange("y", "std", options.y, false)
    self:propChange("z", "std", options.z, false)
end

--- 获取 X 坐标
---@return number
function class:x()
    return self:prop("x")
end

--- 获取 Y 坐标
---@return number
function class:y()
    return self:prop("y")
end

--- 获取 Z 坐标
---@return number
function class:z()
    return self:prop("z")
end