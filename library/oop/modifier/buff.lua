local expander = ClassExpander(CLASS_EXPANDS_MOD, BuffClass)

---@param obj Buff
expander["duration"] = function(obj)
    ---@type number
    local data = obj:propData("duration")
    if (obj:isRunning()) then
        ---@type Timer
        local durationTimer = obj:prop("durationTimer")
        if (data > 0) then
            if (isClass(durationTimer, TimerClass)) then
                durationTimer:period(data)
                durationTimer:remain(data)
            else
                durationTimer = time.setTimeout(data, function()
                    obj:back()
                end)
                obj:prop("durationTimer", durationTimer)
            end
        end
    end
end