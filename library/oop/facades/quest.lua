---@class Quest:QuestClass
---@param key string 唯一标识key
---@return Quest|nil
function Quest(key)
    must(type(key) == "string")
    return Object(QuestClass, {
        static = key,
        options = {
            key = key,
        }
    })
end
