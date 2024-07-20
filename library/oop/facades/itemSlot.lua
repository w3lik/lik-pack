---@class ItemSlot:ItemSlotClass
---@param bindUnit Unit
---@return ItemSlot
function ItemSlot(bindUnit)
    must(isClass(bindUnit, UnitClass))
    return Object(ItemSlotClass, {
        static = bindUnit:id(),
        options = {
            bindUnit = bindUnit,
        }
    })
end
