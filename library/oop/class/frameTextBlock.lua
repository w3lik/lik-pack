---@class FrameTextBlockClass:FrameTextClass
local class = Class(FrameTextBlockClass):extend(FrameTextClass)

---@private
function class:construct()
    self:propChange("block", "std", true, false)
end

---@private
function class:destruct()
    Group():remove(self)
end

--- 阻碍开关
---@param modify boolean|nil
---@return self|boolean
function class:block(modify)
    return self:prop("block", modify)
end