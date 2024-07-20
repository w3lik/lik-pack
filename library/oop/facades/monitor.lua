---@class Monitor:MonitorClass
---@param key string
---@return Monitor
function Monitor(key)
    must(type(key) == "string")
    return Object(MonitorClass, {
        static = key,
        options = {
            key = key
        }
    })
end