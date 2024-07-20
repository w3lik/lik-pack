local expander = ClassExpander(CLASS_EXPANDS_MOD, ImageClass)

---@param obj Image
expander["texture"] = function(obj, prev)
    local data = obj:propData("texture")
    local size = obj:size()
    if (prev ~= data and type(size) == "table") then
        local h = obj:handle()
        J.ShowImage(h, false)
        J.DestroyImage(h)
        obj:clear("handle")
        h = J.CreateImage(data, size[1], size[2], 0, -size[1] / 2, -size[2] / 2, 0, 0, 0, 0, 3)
        J.SetImageAboveWater(h, true, true)
        J.SetImageRenderAlways(h, true)
        obj:prop("handle", h)
        obj:propChange("texture", "std", data, false)
        obj:restruct()
    end
end

---@param obj Image
expander["size"] = function(obj, prev)
    local data = obj:propData("size")
    local texture = obj:texture()
    if (datum.equal(prev, data) == false and texture ~= nil) then
        local h = obj:handle()
        J.ShowImage(h, false)
        J.DestroyImage(h)
        obj:clear("handle")
        h = J.CreateImage(texture, data[1], data[2], 0, -data[1] / 2, -data[2] / 2, 0, 0, 0, 0, 3)
        J.SetImageAboveWater(h, true, true)
        J.SetImageRenderAlways(h, true)
        obj:prop("handle", h)
        obj:propChange("size", "std", data, false)
        obj:restruct()
    end
end

---@param obj Image
expander["show"] = function(obj)
    J.ShowImage(obj:handle(), obj:propData("show"))
end

---@param obj Image
expander["rgba"] = function(obj, prev)
    ---@type number[]
    local data = obj:propData("rgba")
    if (prev) then
        data[1] = data[1] or prev[1]
        data[2] = data[2] or prev[2]
        data[3] = data[3] or prev[3]
        data[4] = data[4] or prev[4]
    end
    J.SetImageColor(obj:handle(), table.unpack(data))
end

---@param obj Image
expander["position"] = function(obj)
    local data = obj:propData("position")
    local size = obj:size()
    J.SetImageConstantHeight(obj:handle(), false, 0)
    J.SetImagePosition(obj:handle(), data[1] - size[1] / 2, data[2] - size[2] / 2, 0)
end