local expander = ClassExpander(CLASS_EXPANDS_PRE, UnitClass)

---@param obj Unit
expander[EffectAttachClass] = function(obj)
    local prev = obj:prop(EffectAttachClass)
    if (isClass(prev, ArrayClass)) then
        prev:forEach(function(_, e)
            destroy(e)
        end)
        obj:clear(EffectAttachClass, true)
    end
end

---@param obj Unit
expander["enchantMaterial"] = function(obj)
    local prev = obj:prop("enchantMaterial")
    enchant.subtract(obj, prev, enchant._material)
end

---@param obj Unit
expander["hpCur"] = function(obj, cur)
    if (cur <= 0) then
        event.syncTrigger(obj, EVENT.Unit.Be.Kill, { sourceUnit = obj:lastHurtSource() })
    end
end
