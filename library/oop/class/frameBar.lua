---@class FrameBarClass:FrameCustomClass
local class = Class(FrameBarClass):extend(FrameCustomClass)

---@private
function class:construct(options)
    self:prop("borderOffset", options.borderOffset or 0)
    local fdfName = self:fdfName()
    if (fdfName == "FRAMEWORK_BACKDROP") then
        japi.DZ_FrameSetTexture(self:handle(), "Framework\\ui\\nil.tga", false)
    end
    
    --- 上下条层
    self:prop("childTexture_value", FrameBackdrop(self:frameIndex() .. "->texture->value", self)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        :texture(TEAM_COLOR_BLP_BLUE))
    self:prop("childTexture_mark", FrameBackdropTile(self:frameIndex() .. "->texture->mark", self)
        :relation(FRAME_ALIGN_RIGHT, self:prop("childTexture_value"), FRAME_ALIGN_RIGHT, 0, 0)
        :texture(TEAM_COLOR_BLP_BLACK))

end

--- 子贴图对象
---@protected
---@param side string | "value" | "mark" 条性对应位置
---@return FrameBackdrop|FrameBackdropTile
function class:childTexture(side)
    return self:prop("childTexture_" .. side)
end

--- 对应方位子文本对象
---@protected
---@param layout number LAYOUT_ALIGN_LEFT|LAYOUT_ALIGN_CENTER|LAYOUT_ALIGN_RIGHT
---@return FrameText
function class:childText(layout)
    return self:prop("childTxt_" .. layout)
end

--- 设置子文本对应方位
--- 一般在构建时使用，需要在引用到childText对应方法之前使用
---@param layouts number[] LAYOUT_ALIGN_* 如 {LAYOUT_ALIGN_LEFT_TOP,LAYOUT_ALIGN_LEFT}
---@return self
function class:textLayout(layouts)
    for _, v in ipairs(layouts) do
        local txt = FrameText(self:frameIndex() .. "->childText->" .. v, self)
        txt:fontSize(10)
        if (v == LAYOUT_ALIGN_LEFT_TOP) then
            txt:textAlign(TEXT_ALIGN_LEFT):relation(FRAME_ALIGN_LEFT_BOTTOM, self, FRAME_ALIGN_LEFT_TOP, 0, 0.002)
        elseif (v == LAYOUT_ALIGN_TOP) then
            txt:textAlign(TEXT_ALIGN_CENTER):relation(FRAME_ALIGN_BOTTOM, self, FRAME_ALIGN_TOP, 0, 0.002)
        elseif (v == LAYOUT_ALIGN_RIGHT_TOP) then
            txt:textAlign(TEXT_ALIGN_RIGHT):relation(FRAME_ALIGN_RIGHT_BOTTOM, self, FRAME_ALIGN_RIGHT_TOP, 0, 0.002)
        elseif (v == LAYOUT_ALIGN_LEFT) then
            txt:textAlign(TEXT_ALIGN_LEFT):relation(FRAME_ALIGN_LEFT, self, FRAME_ALIGN_LEFT, 0, 0)
        elseif (v == LAYOUT_ALIGN_CENTER) then
            txt:textAlign(TEXT_ALIGN_CENTER):relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        elseif (v == LAYOUT_ALIGN_RIGHT) then
            txt:textAlign(TEXT_ALIGN_RIGHT):relation(FRAME_ALIGN_RIGHT, self, FRAME_ALIGN_RIGHT, 0, 0)
        elseif (v == LAYOUT_ALIGN_LEFT_BOTTOM) then
            txt:textAlign(TEXT_ALIGN_LEFT):relation(FRAME_ALIGN_LEFT_TOP, self, FRAME_ALIGN_LEFT_BOTTOM, 0, -0.002)
        elseif (v == LAYOUT_ALIGN_BOTTOM) then
            txt:textAlign(TEXT_ALIGN_CENTER):relation(FRAME_ALIGN_TOP, self, FRAME_ALIGN_BOTTOM, 0, -0.002)
        elseif (v == LAYOUT_ALIGN_RIGHT_BOTTOM) then
            txt:textAlign(TEXT_ALIGN_RIGHT):relation(FRAME_ALIGN_RIGHT_TOP, self, FRAME_ALIGN_RIGHT_BOTTOM, 0, -0.002)
        end
        self:prop("childTxt_" .. v, txt)
    end
    return self
end

--- 条数据值设置
---@param ratio number 0.00-1.00
---@param width number
---@param height number
---@return self|number
function class:value(ratio, width, height)
    local w
    local h
    if (width or height or ratio or w or h) then
        if (width and height) then
            self:size(width, height)
            w = width - self:prop("borderOffset")
            h = height - self:prop("borderOffset")
            self:childTexture("value"):size(w, h)
        end
        if (ratio and w and h) then
            ratio = math.min(1, ratio)
            ratio = math.max(0, ratio)
            self:prop("valueRatio", ratio)
            if (ratio <= 0) then
                self:childTexture("value"):show(false)
                self:childTexture("mark"):size(w, h):show(true)
            else
                local wv = w * (1 - ratio)
                self:childTexture("value"):show(true)
                self:childTexture("mark"):size(wv, h):show(wv > 0)
            end
        end
        return self
    end
    return self:prop("valueRatio") or 0
end

--- 条状底图
---@param side string | "value" | "mark" 条性对应位置
---@param modify string|nil
---@return self|string
function class:texture(side, modify)
    if (side == nil) then
        return self
    end
    if (side and modify) then
        self:childTexture(side):texture(modify)
        return self
    end
    return self:childTexture(side):texture()
end

--- 文本排列
---@param layout number LAYOUT_ALIGN_?
---@param modify string|nil
---@return self|number
function class:textAlign(layout, modify)
    if (layout == nil) then
        return self
    end
    if (layout and modify) then
        self:childText(layout):textAlign(modify)
        return self
    end
    return self:childText(layout):textAlign()
end

--- 字号大小
---@param layout number LAYOUT_ALIGN_?
---@param modify number|nil
function class:fontSize(layout, modify)
    if (layout == nil) then
        return self
    end
    if (layout and modify) then
        self:childText(layout):fontSize(modify)
        return self
    end
    return self:childText(layout):fontSize()
end

--- 文本内容
---@param layout number LAYOUT_ALIGN_?
---@param modify number|nil
---@return self|string
function class:text(layout, modify)
    if (layout == nil) then
        return self
    end
    if (layout and modify) then
        self:childText(layout):text(modify)
        return self
    end
    return self:childText(layout):text()
end