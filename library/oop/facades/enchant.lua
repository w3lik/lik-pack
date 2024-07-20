--- 附魔类型数组
ENCHANT_TYPES = {}

---@class Enchant:EnchantClass
---@param key string 附魔类型
---@return Enchant|nil
function Enchant(key)
    must(type(key) == "string")
    return Object(EnchantClass, {
        protect = true,
        static = key,
        options = {
            key = key,
        }
    })
end
