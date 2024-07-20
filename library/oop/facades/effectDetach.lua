---@class EffectDetach
---@param detachUnit Unit
---@param modelAlias string
---@param attachPosition string | "'origin'" | "'head'" | "'chest'" | "'weapon'"
---@return void
function EffectDetach(detachUnit, modelAlias, attachPosition)
    local model = assets.model(modelAlias)
    if (type(model) ~= "string" or isClass(detachUnit, UnitClass) ~= true) then
        return
    end
    if (J.GetUnitName(detachUnit:handle()) == nil) then
        return
    end
    attachPosition = attachPosition or "origin"
    ---@type Array
    local es = detachUnit:prop(EffectAttachClass)
    if (isClass(es, ArrayClass)) then
        local k = model .. attachPosition
        local e = es:get(k)
        if (isClass(e, EffectAttachClass)) then
            e:dePile()
        end
    end
end
