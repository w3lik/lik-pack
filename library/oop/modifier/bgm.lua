local expander = ClassExpander(CLASS_EXPANDS_MOD, BgmClass)

---@param obj Bgm
expander["volume"] = function(obj)
    J.SetMusicVolume(math.floor(obj:propData("volume") * 1.27))
end

---@param obj Bgm
expander["currentMusic"] = function(obj)
    ---@type string
    local data = obj:propData("currentMusic")
    J.StopMusic(true)
    local delay = 3.3
    ---@type Timer
    local dt = obj:prop("delayTimer")
    if (isClass(dt, TimerClass)) then
        delay = math.max(0, dt:remain())
        destroy(dt)
        obj:clear("delayTimer")
        dt = nil
    end
    if (data ~= "") then
        obj:prop("delayTimer", time.setTimeout(delay, function()
            obj:clear("delayTimer")
            J.PlayMusic(data)
        end))
    end
end