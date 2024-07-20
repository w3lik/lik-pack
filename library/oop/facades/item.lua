---@class Item:ItemClass
---@param tpl ItemTpl
---@return Item
function Item(tpl)
    must(isClass(tpl, ItemTplClass))
    return Object(ItemClass, {
        options = {
            tpl = tpl,
        }
    })
end
