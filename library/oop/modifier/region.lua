local expander = ClassExpander(CLASS_EXPANDS_MOD, RegionClass)

---@param obj Region
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
            local shape = obj:shape()
            local square, circle
            if (shape == "square") then
                square = {
                    x = obj:x(),
                    y = obj:y(),
                    width = obj:width(),
                    height = obj:height(),
                }
            elseif (shape == "circle") then
                circle = {
                    x = obj:x(),
                    y = obj:y(),
                    radius = obj:radius(),
                }
            end
            local prevUnit = obj:prop("prevUnits")
            local newUnits = Group():catch(UnitClass, {
                square = square,
                circle = circle,
                ---@param enumUnit Unit
                filter = function(enumUnit)
                    return enumUnit:isAlive()
                end,
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
                        event.syncTrigger(obj, EVENT.Region.Leave, { triggerUnit = u })
                    end
                end
            end
            obj:prop("prevUnits", newUnits)
            if (#newUnits > 0) then
                for _, u in ipairs(newUnits) do
                    if (prevEnter[u:id()] == nil) then
                        event.syncTrigger(obj, EVENT.Region.Enter, { triggerUnit = u })
                    end
                end
            end
        end)
        obj:prop("eventTimer", t)
    else
        obj:unEvent()
    end
end