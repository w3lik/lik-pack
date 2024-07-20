---@class EffectAttach:EffectAttachClass
---@param attachUnit Unit
---@param modelAlias string
---@param attachPosition string | "'origin'" | "'head'" | "'chest'" | "'weapon'"
---@param duration number 默认-1，无限持续
---@return EffectAttach|nil
function EffectAttach(attachUnit, modelAlias, attachPosition, duration)
    local model = assets.model(modelAlias)
    if (type(model) ~= "string" or isClass(attachUnit, UnitClass) ~= true) then
        return
    end
    if (J.GetUnitName(attachUnit:handle()) == nil) then
        return
    end
    duration = duration or -1
    attachPosition = attachPosition or "origin"
    ---@type Array
    local es = attachUnit:prop(EffectAttachClass)
    if (es == nil) then
        es = Array()
        attachUnit:prop(EffectAttachClass, es)
    end
    local k = model .. attachPosition
    ---@type EffectAttach
    local e = es:get(k)
    if (e ~= nil) then
        e:duration(duration)
    else
        e = Object(EffectAttachClass, {
            options = {
                model = model,
                attachUnit = attachUnit,
                attachPosition = attachPosition,
                duration = duration,
            }
        })
        es:set(k, e)
    end
    return e
end
