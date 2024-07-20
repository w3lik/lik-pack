local expander = ClassExpander(CLASS_EXPANDS_MOD, AuraClass)

---@param obj Aura
expander["useEvent"] = function(obj)
    ---@type boolean
    local data = obj:propData("useEvent")
    if (data == true) then
        local t = obj:prop("eventTimer")
        if (isClass(t, TimerClass)) then
            return
        end
        local frq = obj:frequency()
        t = time.setInterval(frq, function(curTimer)
            if (isDestroy(obj)) then
                destroy(curTimer)
                return
            end
            local cu = obj:prop("centerUnit")
            local cp = obj:prop("centerPosition")
            if cp == nil and false == isClass(cu, UnitClass) then
                destroy(curTimer)
                destroy(obj)
                return
            end
            local prevUnit = obj:prop("prevUnits")
            local newUnits = Group():catch(UnitClass, {
                circle = {
                    x = obj:x(),
                    y = obj:y(),
                    radius = obj:radius(),
                },
                limit = obj:limit(),
                filter = obj:filter(),
            })
            local prevEnter = {}
            local newEnter = {}
            if (type(prevUnit) == "table") then
                for _, u in ipairs(prevUnit) do
                    prevEnter[u:id()] = true
                end
            end
            for _, u in ipairs(newUnits) do
                newEnter[u:id()] = true
            end
            if (type(prevUnit) == "table") then
                for _, u in ipairs(prevUnit) do
                    if (newEnter[u:id()] == nil) then
                        event.syncTrigger(obj, EVENT.Aura.Leave, { triggerUnit = u })
                    end
                end
            end
            obj:prop("prevUnits", newUnits)
            if (#newUnits > 0) then
                for _, u in ipairs(newUnits) do
                    if (prevEnter[u:id()] == nil) then
                        event.syncTrigger(obj, EVENT.Aura.Enter, { triggerUnit = u })
                    end
                end
            end
        end)
        obj:prop("eventTimer", t)
    else
        obj:unEvent()
    end
end

---@param obj Aura
expander["centerEffect"] = function(obj)
    obj:clear("centerEffectObj", true)
    ---@type number
    local data = obj:propData("centerEffect")
    local e
    local u = obj:prop("centerUnit")
    local v = obj:prop("centerPosition")
    if (type(v) == "table") then
        e = Effect(data[1], v[1], v[2], v[3], -1)
        if (type(data[3]) == "number" and data[3] ~= 1) then
            e:size(data[3])
        end
    elseif (isClass(u, UnitClass)) then
        e = EffectAttach(u, data[1], data[2] or "origin", -1)
    else
        return
    end
    obj:prop("centerEffectObj", e)
end

---@param obj Aura
expander["duration"] = function(obj)
    ---@type number
    local data = obj:propData("duration")
    ---@type Timer
    local t = obj:prop("durationTimer")
    if (isClass(t, TimerClass)) then
        obj:clear("durationTimer", true)
    end
    if (data == 0) then
        destroy(obj)
    elseif (data > 0) then
        t = time.setTimeout(data, function()
            destroy(obj)
        end)
        obj:prop("durationTimer", t)
    end
end