VcmVoices = VcmVoices or {}
VcmVoiceIdx = VcmVoiceIdx or {}

---@class Vcm:VcmClass
---@param alias string
---@return nil|Vcm
function Vcm(alias)
    if (VcmVoices[alias] == nil) then
        return
    end
    local v = VcmVoices[alias][VcmVoiceIdx[alias]]
    VcmVoiceIdx[alias] = VcmVoiceIdx[alias] + 1
    if (VcmVoiceIdx[alias] >= #VcmVoices[alias]) then
        VcmVoiceIdx[alias] = 1
    end
    return v
end

---@private
---@param alias string
---@return Vcm
function VcmCreator(alias, duration)
    if (VcmVoices[alias] == nil) then
        VcmVoices[alias] = {}
        VcmVoiceIdx[alias] = 1
    end
    local new = Object(VcmClass, {
        protect = true,
        options = {
            alias = alias,
            duration = duration,
        }
    })
    table.insert(VcmVoices[alias], new)
    return new
end