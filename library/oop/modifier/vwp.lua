local expander = ClassExpander(CLASS_EXPANDS_MOD, VwpClass)

---@param obj Vwp
expander["volume"] = function(obj)
    local data = obj:propData("volume")
    J.SetSoundVolume(obj:handle(), math.floor(data * 1.27))
end

---@param obj Vwp
expander["channel"] = function(obj)
    local data = obj:propData("channel")
    J.SetSoundChannel(obj:handle(), data.value)
end

---@param obj Vwp
expander["pitch"] = function(obj)
    J.SetSoundPitch(obj:handle(), obj:propData("pitch"))
end

---@param obj Vwp
expander["distanceCutoff"] = function(obj)
    J.SetSoundDistanceCutoff(obj:handle(), obj:propData("distanceCutoff"))
end

---@param obj Vwp
expander["distances"] = function(obj)
    local data = obj:propData("distances")
    if (#data == 2) then
        J.SetSoundDistances(obj:handle(), data[1], data[2])
    end
end