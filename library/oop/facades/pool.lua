---@class Pool:PoolClass
---@param name string
---@return Pool
function Pool(name)
    must(type(name) == "string")
    return Object(PoolClass, {
        static = name,
        options = {
            name = name,
        }
    })
end