---@class AbilitySlot:AbilitySlotClass
---@param bindUnit Unit
---@return Item
function AbilitySlot(bindUnit)
    must(isClass(bindUnit, UnitClass))
    return Object(AbilitySlotClass, {
        static = bindUnit:id(),
        options = {
            bindUnit = bindUnit,
        }
    })
end
