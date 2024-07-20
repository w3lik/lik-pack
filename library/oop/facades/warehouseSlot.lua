---@class WarehouseSlot:WarehouseSlotClass
---@param bindPlayer Player
---@return Item
function WarehouseSlot(bindPlayer)
    must(isClass(bindPlayer, PlayerClass))
    return Object(WarehouseSlotClass, {
        protect = true,
        static = bindPlayer:id(),
        options = {
            bindPlayer = bindPlayer,
        }
    })
end
