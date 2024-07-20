---@class FrameCustomClass:FrameClass
local class = Class(FrameCustomClass):extend(FrameClass)

---@private
function class:construct()
    self:propChange("alpha", "std", 255, false)
end

--- fdf名称
---@param
---@return string
function class:fdfName()
    return self:prop("fdfName")
end

--- fdf类型
---@param
---@return string
function class:fdfType()
    return self:prop("fdfType")
end

--- 透明度
---@param modify number|nil
---@return self|number
function class:alpha(modify)
    return self:prop("alpha", modify)
end