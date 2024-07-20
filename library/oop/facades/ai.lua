---@class AI:AIClass
---@alias key string
---@return AI
function AI(key)
    must(type(key) == "string")
    return Object(AIClass, {
        static = key,
        options = {
            key = key,
        }
    })
end
