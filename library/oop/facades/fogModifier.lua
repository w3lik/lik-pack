---@class FogModifier:FogModifierClass
---@param bindPlayer Player
---@param key string
---@return FogModifier
function FogModifier(bindPlayer, key)
    must(isClass(bindPlayer, PlayerClass))
    must(type(key) == "string")
    return Object(FogModifierClass, {
        static = key .. '_' .. bindPlayer:index(),
        options = {
            bindPlayer = bindPlayer,
            key = key,
        }
    })
end