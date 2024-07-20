--- 精简闪电特效
---@param lightningType table LIGHTNING_TYPE
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@param duration number 持续时间，最少0.1秒
---@return number
function lightning(lightningType, x1, y1, z1, x2, y2, z2, duration)
    must(type(lightningType) == "table")
    x1 = x1 or 0
    y1 = y1 or 0
    z1 = z1 or 0
    x2 = x2 or 0
    y2 = y2 or 0
    z2 = z2 or 0
    duration = math.max(0.05, duration or 0)
    local l = J.AddLightningEx(lightningType.value, false, x1, y1, z1, x2, y2, z2)
    effector(lightningType.effect, x2, y2, z2, 0.25)
    time.setTimeout(duration, function()
        J.DestroyLightning(l)
        l = nil
    end)
    return l
end