---@class Store:StoreClass
---@param key string 唯一标识key
---@return nil|Store
function Store(key)
    must(type(key) == "string")
    return Object(StoreClass, {
        static = key,
        options = {
            key = key,
        }
    })
end
