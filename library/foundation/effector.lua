--- 精简展示特效
--- * 有的模型删除时不会播放，此时需要duration > 0
---@param model string 支持alias
---@param x number
---@param y number
---@param z number
---@param duration number 当等于0时为删除型播放，大于0时持续一段时间，不支持永远存在
---@return number|nil
function effector(model, x, y, z, duration)
    model = assets.model(model)
    if (model == nil) then
        return
    end
    z = z or japi.Z(x, y)
    duration = math.max(0, duration or 0)
    local e = J.AddSpecialEffect(model, x, y)
    if (e > 0) then
        J.HandleRef(e)
        if (type(z) == "number") then
            japi.YD_SetEffectZ(e, z)
        end
        if (duration == 0) then
            J.DestroyEffect(e)
            J.HandleUnRef(e)
            e = nil
            return
        end
        if (duration > 0) then
            time.setTimeout(duration, function()
                japi.YD_SetEffectSize(e, 0.01)
                J.DestroyEffect(e)
                J.HandleUnRef(e)
                e = nil
            end)
        end
    end
    return e
end