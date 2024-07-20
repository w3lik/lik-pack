local expander = ClassExpander(CLASS_EXPANDS_MOD, V3dClass)

---@param obj V3d
expander["volume"] = function(obj)
    local data = obj:propData("volume")
    J.SetSoundVolume(obj:handle(), math.floor(data * 1.27))
end

---@param obj V3d
expander["channel"] = function(obj)
    local data = obj:propData("channel")
    J.SetSoundChannel(obj:handle(), data.value)
end

---@param obj V3d
expander["pitch"] = function(obj)
    J.SetSoundPitch(obj:handle(), obj:propData("pitch"))
end

---@param obj V3d
expander["distanceCutoff"] = function(obj)
    J.SetSoundDistanceCutoff(obj:handle(), obj:propData("distanceCutoff"))
end

---@param obj V3d
expander["distances"] = function(obj)
    local data = obj:propData("distances")
    if (#data == 2) then
        J.SetSoundDistances(obj:handle(), data[1], data[2])
    end
end