---@class Team:TeamClass
---@param key string 唯一标识key
---@return nil|Team
function Team(key)
    must(type(key) == "string")
    return Object(TeamClass, {
        static = key,
        options = {
            key = key,
        },
    })
end
