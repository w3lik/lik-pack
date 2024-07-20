---@class FrameTextClass:FrameCustomClass
local class = Class(FrameTextClass):extend(FrameCustomClass)

---@private
function class:construct()
    self:textAlign(TEXT_ALIGN_CENTER)
    self:fontSize(10)
    self:prop("textSizeLimit", 0)
end

--- 文本排列
---@param modify number|nil TEXT_ALIGN?
---@return self|string
function class:textAlign(modify)
    return self:prop("textAlign", modify)
end

--- 文本颜色
---@param modify number|nil
---@return self|number
function class:textColor(modify)
    return self:prop("textColor", modify)
end

--- 文本字数限制
---@param modify number|nil
---@return self|number
function class:textSizeLimit(modify)
    return self:prop("textSizeLimit", modify)
end

--- 文本字号[6-16]
---@param modify number|nil
---@return self|number
function class:fontSize(modify)
    return self:prop("fontSize", modify)
end

--- 文本内容
---@param modify string|nil
---@return self|string
function class:text(modify)
    if (modify) then
        modify = i18n.tr(modify)
    end
    return self:prop("text", modify)
end