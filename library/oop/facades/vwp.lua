VwpVoices = VwpVoices or {}
VwpVoiceIdx = VwpVoiceIdx or {}

---@class Vwp:VwpClass
---@param sourceUnit Unit
---@param targetObj Unit|Item
---@return nil|Vwp
function Vwp(sourceUnit, targetObj)
    if (false == isClass(sourceUnit, UnitClass) or false == inClass(targetObj, UnitClass, ItemClass)) then
        return
    end
    local weaponSound = sourceUnit:weaponSound()
    if (weaponSound == nil) then
        return
    end
    local targetMaterial = targetObj:material()
    if (targetMaterial == nil) then
        targetMaterial = "any"
    else
        targetMaterial = targetMaterial.value
    end
    local r = math.rand(1, 3)
    local alias = weaponSound .. "_" .. targetMaterial .. "_" .. r
    if (VwpVoices[alias] == nil) then
        alias = weaponSound .. "_any_" .. r
        if (VwpVoices[alias] == nil) then
            return
        end
    end
    local v = VwpVoices[alias][VwpVoiceIdx[alias]]
    VwpVoiceIdx[alias] = VwpVoiceIdx[alias] + 1
    if (VwpVoiceIdx[alias] >= #VwpVoices[alias]) then
        VwpVoiceIdx[alias] = 1
    end
    v:prop("targetObj", targetObj)
    return v
end

---@private
---@param alias string
---@return V3d
function VwpCreator(alias, duration)
    if (VwpVoices[alias] == nil) then
        VwpVoices[alias] = {}
        VwpVoiceIdx[alias] = 1
    end
    local new = Object(VwpClass, {
        protect = true,
        options = {
            alias = alias,
            duration = duration,
        }
    })
    table.insert(VwpVoices[alias], new)
    return new
end