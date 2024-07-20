---@class Effect:EffectClass
---@param modelAlias string
---@param x number
---@param y number
---@param z number
---@param duration number 默认0，瞬间删除特效有的特效能播放一次
---@return Effect|nil
function Effect(modelAlias, x, y, z, duration)
    local model = assets.model(modelAlias)
    if (type(model) ~= "string") then
        return
    end
    duration = duration or 0
    return Object(EffectClass, {
        options = {
            model = model,
            x = x,
            y = y,
            z = z,
            duration = duration,
        }
    })
end
