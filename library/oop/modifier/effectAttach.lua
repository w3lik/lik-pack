local expander = ClassExpander(CLASS_EXPANDS_MOD, EffectAttachClass)

---@param obj EffectAttach
expander["duration"] = function(obj)
    local data = obj:propData("duration")
    ---@type Timer
    local t = obj:prop("durationTimer")
    if (isClass(t, TimerClass)) then
        if (data > 0) then
            if (data > t:remain()) then
                if (data > t:period()) then
                    t:period(data)
                end
                t:remain(data)
            end
            return
        end
        obj:clear("durationTimer", true)
    else
        obj:prop("pile", "+=1")
    end
    if (data > 0) then
        t = time.setTimeout(data, function()
            obj:clear("durationTimer")
            obj:dePile()
        end)
        obj:prop("durationTimer", t)
    end
end