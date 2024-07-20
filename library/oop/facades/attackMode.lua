---@class AttackMode:AttackModeClass
---@return AttackMode|nil
function AttackMode()
    return Object(AttackModeClass)
end

---@param key string
---@return AttackMode|nil
function AttackModeStatic(key)
    must(type(key) == "string")
    return Object(AttackModeClass, {
        static = key,
    })
end
