---@class ImageClass:Class
local class = Class(ImageClass)

---@private
function class:construct(options)
    local h = J.CreateImage(options.texture, options.width, options.height, 0, -options.width / 2, -options.height / 2, 0, 0, 0, 0, 3)
    J.SetImageAboveWater(h, true, true)
    J.SetImageRenderAlways(h, true)
    self:propChange("handle", "std", h, false)
    self:propChange("restruct", "std", Array(), false)
    self:propChange("position", "std", { 0, 0 }, false)
    self:propChange("rgba", "std", { 255, 255, 255, 255 }, false)
    self:propChange("texture", "std", options.texture, false)
    self:propChange("size", "std", { options.width, options.height }, false)
    self:propChange("show", "std", true, false)
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

---@private onlySync
function class:destruct()
    self:clear("restruct", true)
    local h = self:handle()
    J.ShowImage(h, false)
    J.DestroyImage(h)
    self:clear("handle")
end

--- handle
---@return number
function class:handle()
    return self:prop("handle")
end

--- 贴图路径
---@param modify string|nil
---@return self|string
function class:texture(modify)
    return self:prop("texture", modify)
end

--- 大小
---@param width number|nil
---@param height number|nil
---@return self|number[]
function class:size(width, height)
    if (type(width) == "number" and type(height) == "number") then
        local modify = { width, height }
        return self:prop("size", modify)
    end
    return self:prop("size")
end

--- 显示
---@param modify boolean|nil
---@return self|boolean
function class:show(modify)
    return self:prop("show", modify)
end

--- rgba颜色
---@param red number|nil
---@param green number|nil
---@param blue number|nil
---@param alpha number|nil
---@return self|number[]
function class:rgba(red, green, blue, alpha)
    if (type(red) == "number" or type(green) == "number" or type(blue) == "number" or type(alpha) == "number") then
        return self:prop("rgba", { red, green, blue, alpha })
    end
    return self:prop("rgba")
end

--- 移动到X,Y坐标
---@param x number|nil
---@param y number|nil
---@return void
function class:position(x, y)
    if (type(x) == "number" and type(y) == "number") then
        self:prop("position", { x, y })
    end
end