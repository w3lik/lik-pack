---@class Process:ProcessClass
---@param key string 唯一标识key
---@return Process|nil
function Process(key)
    must(type(key) == "string")
    return Object(ProcessClass, {
        static = key,
        options = {
            name = key
        }
    })
end
