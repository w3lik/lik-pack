--- 领域绑定
---@class Aura:AuraClass
---@param key string|nil 领域名
---@return Aura
function AuraAttach(key)
    local set = {}
    if (type(key) == "string") then
        set.static = key
    end
    return Object(AuraClass, set)
end