---@class FrameBackdropClass:FrameCustomClass
local class = Class(FrameBackdropClass):extend(FrameCustomClass)

---@private
function class:construct(options)
    if (options.fdfName == "FRAMEWORK_BACKDROP") then
        self:prop("texture", "Framework\\ui\\nil.tga")
    end
    
    FrameTextBlock(options.frameIndex .. "->cBlock", self)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        :block(false)

end

---@private
---@return FrameTextBlock|nil
function class:childBlock()
    return FrameTextBlock(self:frameIndex() .. "->cBlock")
end

--- 宽高尺寸(0-0.8,0-0.6)
--- 百分比占比设置
---@param w number
---@param h number
---@return self|number[2]
function class:size(w, h)
    if (w ~= nil and h ~= nil) then
        super(class).size(self, w, h)
        self:childBlock():size(w, h)
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

--- 阻碍开关
---@param modify boolean|nil
---@return self|boolean
function class:block(modify)
    if (type(modify) == "boolean") then
        self:childBlock():block(modify)
        return self
    end
    return self:childBlock():block()
end