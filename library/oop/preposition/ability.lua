local expander = ClassExpander(CLASS_EXPANDS_PRE, AbilityClass)

---@param obj Ability
expander["bindUnit"] = function(obj)
    ---@type Unit
    local prev = obj:bindUnit()
    if (isClass(prev, UnitClass)) then
        prev:abilitySlot():remove(obj:abilitySlotIndex())
        obj:clear("bindUnit")
    end
end

---@param obj Ability
expander["bindItem"] = function(obj)
    ---@type Item
    local prev = obj:bindItem()
    if (isClass(prev, ItemClass)) then
        prev:clear("bindAbility")
        obj:clear("bindItem")
    end
end