---@class FrameLabelClass:FrameCustomClass
local class = Class(FrameLabelClass):extend(FrameCustomClass)

---@private
function class:construct(_)
    self:prop("texture", "Framework\\ui\\nil.tga")
    FrameBackdrop(self:frameIndex() .. '->cIcon', self)
    FrameText(self:frameIndex() .. '->cLabel', self)
    self:autoSize(false)
    self:side(LAYOUT_ALIGN_LEFT)
    self:textAlign(TEXT_ALIGN_LEFT)
    self:fontSize(10)
end

--- 自动尺寸
--- 默认false
---@param modify boolean
---@return self|boolean
function class:autoSize(modify)
    return self:prop("autoSize", modify)
end

--- 宽高尺寸(0-0.8,0-0.6)
--- 百分比占比设置
--- autoSize为true时，，根据text内容自动变换，当text未定时，默认0.05
---@param w number
---@param h number
---@return self|number[2]
function class:size(w, h)
    if (w ~= nil and h ~= nil) then
        if (self:autoSize() == true) then
            local tw = vistring.width(self:childLabel():text(), self:childLabel():fontSize())
            if (tw <= 0) then
                w = 0.05
            else
                w = tw + h + 0.002
            end
        end
        super(class).size(self, w, h)
        local iw = h
        if (self:adaptive() ~= true) then
            iw = iw * 0.75
        end
        self:childIcon():size(iw, h)
        self:childLabel():size(w - iw - 0.001, h)
        return self
    end
    return super(class).size(self)
end

--- 子图标对象
---@protected
---@return FrameButton
function class:childIcon()
    return FrameBackdrop(self:frameIndex() .. '->cIcon')
end

--- 子文本对象
---@protected
---@return FrameText
function class:childLabel()
    return FrameText(self:frameIndex() .. '->cLabel')
end

--- 侧偏，有左和右两种，默认左[LAYOUT_ALIGN_LEFT]
---@param modify number|nil LAYOUT_ALIGN_LEFT | LAYOUT_ALIGN_RIGHT
---@return self|number
function class:side(modify)
    if (modify ~= nil) then
        if (modify == LAYOUT_ALIGN_RIGHT) then
            local ct = self:childIcon()
            ct:relation(FRAME_ALIGN_RIGHT_TOP, self, FRAME_ALIGN_RIGHT_TOP, 0, 0)
            self:childLabel():relation(FRAME_ALIGN_RIGHT, ct, FRAME_ALIGN_LEFT, -0.001, 0.001)
        else
            modify = LAYOUT_ALIGN_LEFT
            local ct = self:childIcon()
            ct:relation(FRAME_ALIGN_LEFT_TOP, self, FRAME_ALIGN_LEFT_TOP, 0, 0)
            self:childLabel():relation(FRAME_ALIGN_LEFT, ct, FRAME_ALIGN_RIGHT, 0.001, 0.001)
        end
        local _, updated = self:PROP("side", modify)
        if (updated) then
            local s = self:prop("unAdaptiveSize")
            if (s ~= nil) then
                self:size(s[1], s[2])
            end
        end
        return self
    end
    return self:prop("side")
end

--- 整体背景贴图
---@param modify string|nil
---@return self|string
function class:texture(modify)
    if (modify) then
        modify = assets.uikit(self:kit(), modify, "tga")
    end
    return self:prop("texture", modify)
end

--- 图标贴图
---@param modify string|nil
---@return self|string
function class:icon(modify)
    if (modify) then
        self:childIcon():texture(modify)
        return self
    end
    return self:childIcon():texture()
end

--- 文本排列
---@param modify number|nil
---@return self|number
function class:textAlign(modify)
    if (modify ~= nil) then
        self:childLabel():textAlign(modify)
        return self
    end
    return self:childLabel():textAlign()
end

--- 文本字号[6-16]
---@param modify number|nil
---@return self|number
function class:fontSize(modify)
    if (modify ~= nil) then
        self:childLabel():fontSize(modify)
        return self
    end
    return self:childLabel():fontSize()
end

--- 文本内容
---@param modify string|nil
---@return self|string
function class:text(modify)
    if (modify ~= nil) then
        local _, updated = self:childLabel():PROP("text", modify)
        if (updated) then
            local s = self:prop("unAdaptiveSize")
            if (s ~= nil) then
                self:size(s[1], s[2])
            end
        end
        return self
    end
    return self:childLabel():text()
end