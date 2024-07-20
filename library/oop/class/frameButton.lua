---@class FrameButtonClass:FrameCustomClass
local class = Class(FrameButtonClass):extend(FrameCustomClass)

---@private
function class:construct(options)
    
    self:prop("texture", "Framework\\ui\\nil.tga")
    
    FrameHighlight(options.frameIndex .. "->cHighlight", self, options.highlightFdfName)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        :show(false)
    
    FrameBackdrop(options.frameIndex .. '->cBorder', self)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
    
    FrameBackdrop(options.frameIndex .. '->cMask', self)
        :relation(FRAME_ALIGN_BOTTOM, self, FRAME_ALIGN_BOTTOM, 0, 0)
        :show(false)
    
    FrameTextBlock(options.frameIndex .. "->cBlock", self)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        :textAlign(TEXT_ALIGN_CENTER)
    
    FrameText(options.frameIndex .. "->cText", self)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        :textAlign(TEXT_ALIGN_CENTER)
        :fontSize(8)
    
    FrameText(options.frameIndex .. "->cHotkey", self)
        :relation(FRAME_ALIGN_BOTTOM, self, FRAME_ALIGN_BOTTOM, 0, -0.01)
        :textAlign(TEXT_ALIGN_CENTER)
        :fontSize(10)

end

---@private
---@return FrameTextBlock|nil
function class:childBlock()
    return FrameTextBlock(self:frameIndex() .. "->cBlock")
end

--- 子高亮对象
---@return FrameHighlight|nil
function class:childHighlight()
    return FrameHighlight(self:frameIndex() .. "->cHighlight")
end

--- 子文本对象
---@return FrameText|nil
function class:childText()
    return FrameText(self:frameIndex() .. "->cText")
end

--- 子边框对象
---@protected
---@return FrameBackdrop
function class:childBorder()
    return FrameBackdrop(self:frameIndex() .. "->cBorder")
end

--- 子遮罩对象
---@protected
---@return FrameBackdrop
function class:childMask()
    return FrameBackdrop(self:frameIndex() .. "->cMask")
end

--- 子热键文本对象
---@protected
---@return FrameText
function class:childHotkey()
    return FrameText(self:frameIndex() .. "->cHotkey")
end

--- 宽高尺寸(0-0.8,0-0.6)
--- 百分比占比设置
---@param w number
---@param h number
---@return self|number[2]
function class:size(w, h)
    if (w ~= nil and h ~= nil) then
        super(class).size(self, w, h)
        self:childHighlight():size(w, h)
        self:childBorder():size(w, h)
        self:childBlock():size(w, h)
        self:maskValue(self:maskValue())
        return self
    end
    return super(class).size(self)
end

--- 贴图
---@param modify string|nil
---@return self|string
function class:texture(modify)
    if (modify) then
        modify = assets.uikit(self:kit(), modify, "tga")
    end
    return self:prop("texture", modify)
end

--- 边框贴图
---@param modify string|nil
---@return self|string
function class:border(modify)
    if (modify ~= nil) then
        self:childBorder():texture(modify)
        return self
    end
    return self:childBorder():texture()
end

--- 遮罩贴图
---@param modify string|nil
---@return self|string
function class:mask(modify)
    if (modify ~= nil) then
        self:childMask():texture(modify)
        return self
    end
    return self:childMask():texture()
end

--- 遮罩值
---@param modify number|nil [0.00-1.00]
---@return self|number
function class:maskValue(modify)
    local s
    if (modify ~= nil) then
        s = self:prop("unAdaptiveSize")
        if (modify <= 0) then
            self:childMask():show(false)
        elseif (s ~= nil) then
            self:childMask():size(s[1], s[2] * modify):show(true)
        end
        return self:prop("maskValue", modify)
    end
    return self:prop("maskValue") or 0
end

--- 中心文本内容
---@param modify string|nil
---@return self|string
function class:text(modify)
    if (modify ~= nil) then
        self:childText():text(modify)
        return self
    end
    return self:childText():text()
end

--- 中央文本字号[6-16]
---@param modify number|nil
---@return self|number
function class:fontSize(modify)
    if (modify ~= nil) then
        self:childText():fontSize(modify)
        return self
    end
    return self:childText():fontSize()
end

--- 热键文本
---@param modify string|nil
---@return self|string
function class:hotkey(modify)
    if (modify ~= nil) then
        self:childHotkey():text(modify)
        return self
    end
    return self:childHotkey():text()
end

--- 热键字号
---@param modify number|nil
---@return self|number
function class:hotkeyFontSize(modify)
    if (modify ~= nil) then
        self:childHotkey():fontSize(modify)
        return self
    end
    return self:childHotkey():fontSize()
end