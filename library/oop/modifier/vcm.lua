local expander = ClassExpander(CLASS_EXPANDS_MOD, VcmClass)

---@param obj Vcm
---@param data number
expander["volume"] = function(obj)
    local data = obj:propData("volume")
    J.SetSoundVolume(obj:handle(), math.floor(data * 1.27))
end

---@param obj Vcm
expander["channel"] = function(obj)
    local data = obj:propData("channel")
    J.SetSoundChannel(obj:handle(), data.value)
end

---@param obj Vcm
expander["pitch"] = function(obj)
    J.SetSoundPitch(obj:handle(), obj:propData("pitch"))
end