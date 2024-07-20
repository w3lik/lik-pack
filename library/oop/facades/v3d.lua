V3dVoice = V3dVoice or {}
V3dVoiceIdx = V3dVoiceIdx or {}

---@class V3d:V3dClass
---@param alias string
---@return nil|V3d
function V3d(alias)
    if (V3dVoice[alias] == nil) then
        return
    end
    local v = V3dVoice[alias][V3dVoiceIdx[alias]]
    V3dVoiceIdx[alias] = V3dVoiceIdx[alias] + 1
    if (V3dVoiceIdx[alias] >= #V3dVoice[alias]) then
        V3dVoiceIdx[alias] = 1
    end
    return v
end

---@private
---@param alias string
---@return V3d
function V3dCreator(alias, duration)
    if (V3dVoice[alias] == nil) then
        V3dVoice[alias] = {}
        V3dVoiceIdx[alias] = 1
    end
    local new = Object(V3dClass, {
        protect = true,
        options = {
            alias = alias,
            duration = duration,
        }
    })
    table.insert(V3dVoice[alias], new)
    return new
end