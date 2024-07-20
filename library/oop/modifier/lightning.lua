local expander = ClassExpander(CLASS_EXPANDS_MOD, LightningClass)

---@param obj Lightning
expander["lightningType"] = function(obj)
    if (type(obj._handle) == "number") then
        J.DestroyLightning(obj._handle)
    end
    local position = obj:propData("position")
    local data = obj:propData("lightningType")
    obj._handle = J.AddLightningEx(data.value, false, table.unpack(position))
end

---@param obj Lightning
expander["rgba"] = function(obj)
    ---@type number[]
    local data = obj:propData("rgba")
    J.SetLightningColor(obj:handle(), table.unpack(data))
end

---@param obj Lightning
expander["duration"] = function(obj)
    ---@type Timer
    local t = obj:prop("durationTimer")
    if (isClass(t, TimerClass)) then
        obj:clear("durationTimer", true)
    end
    ---@type number
    local data = obj:propData("duration")
    if (data == 0) then
        destroy(obj)
    elseif (data > 0) then
        t = time.setTimeout(data, function()
            destroy(obj)
        end)
        obj:prop("durationTimer", t)
    end
end

---@param obj Lightning
expander["position"] = function(obj)
    ---@type number[]
    local data = obj:propData("position")
    J.MoveLightningEx(obj:handle(), false, table.unpack(data))
end