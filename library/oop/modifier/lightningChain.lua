local expander = ClassExpander(CLASS_EXPANDS_MOD, LightningChainClass)

---@param obj LightningChain
expander["lightningType"] = function(obj)
    if (type(obj._handle) == "number") then
        J.DestroyLightning(obj._handle)
    end
    local data = obj:propData("lightningType")
    local data1 = obj:propData("unit1")
    local data2 = obj:propData("unit2")
    if (data1:isAlive() and data2:isAlive()) then
        local x1, y1, z1 = data1:x(), data1:y(), data1:h()
        local x2, y2, z2 = data2:x(), data2:y(), data2:h()
        obj._handle = J.AddLightningEx(data.value, false, x1, y1, z1, x2, y2, z2)
    end
end

---@param obj LightningChain
expander["rgba"] = function(obj)
    ---@type number[]
    local data = obj:propData("rgba")
    J.SetLightningColor(obj:handle(), table.unpack(data))
end

---@param obj LightningChain
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

---@param obj LightningChain
expander["unit1"] = function(obj)
    ---@type Unit
    local data1 = obj:propData("unit1")
    ---@type Unit
    local data2 = obj:propData("unit2")
    if (isClass(data1, UnitClass) and isClass(data2, UnitClass)) then
        if (data1:isAlive() and data2:isAlive()) then
            local x1, y1, z1 = data1:x(), data1:y(), data1:h()
            local x2, y2, z2 = data2:x(), data2:y(), data2:h()
            J.MoveLightningEx(obj:handle(), false, x1, y1, z1, x2, y2, z2)
            local ct = obj:prop("chainTimer")
            if (false == isClass(ct, TimerClass)) then
                ct = time.setInterval(0.1, function()
                    data1 = obj:propData("unit1")
                    data2 = obj:propData("unit2")
                    if (false == isClass(data1, UnitClass) or false == isClass(data2, UnitClass) or data1:isDead() or data2:isDead()) then
                        obj:clear("chainTimer", true)
                        destroy(obj)
                        return
                    end
                    x1, y1, z1 = data1:x(), data1:y(), data1:h()
                    x2, y2, z2 = data2:x(), data2:y(), data2:h()
                    J.MoveLightningEx(obj:handle(), false, x1, y1, z1, x2, y2, z2)
                end)
                obj:prop("chainTimer", ct)
            end
        end
    end
end

---@param obj LightningChain
expander["unit2"] = function(obj)
    expander["unit1"](obj)
end