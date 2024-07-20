---@class alerter
alerter = alerter or {}

--- 直线方向
---@param x number
---@param y number
---@param distance number 距离
---@param angle Player
---@param duration number|1
---@return void
function alerter.line(x, y, distance, angle, duration)
    duration = duration or 1
    local e = effector("interface/BossAlert", x, y, 30 + japi.Z(x, y), duration)
    japi.YD_EffectMatRotateZ(e, angle)
    japi.YD_EffectMatScale(e, 128 / 100, distance / 750, 1)
end

--- 圆形范围
---@param x number
---@param y number
---@param radius number 半径
---@param duration number|1
---@return void
function alerter.circle(x, y, radius, duration)
    duration = duration or 1
    local e = effector("interface/BossAlertRing", x, y, 30 + japi.Z(x, y), duration)
    local siz = radius / 160
    japi.YD_EffectMatScale(e, siz, siz, 1)
end

--- 跟踪型
---@param whichUnit Unit
---@param radius number 半径
---@param duration number|1
---@return void
function alerter.follow(whichUnit, radius, duration)
    if (false == isClass(whichUnit, UnitClass)) then
        return
    end
    duration = duration or 1
    local x, y = whichUnit:x(), whichUnit:y()
    local e = effector("interface/BossAlertRing", x, y, 30 + japi.Z(x, y), duration)
    local siz = radius / 160
    japi.YD_EffectMatScale(e, siz, siz, 1)
    local ti = 0
    time.setInterval(0.03, function(curTimer)
        ti = ti + 0.03
        if (ti > duration or false == isClass(whichUnit, UnitClass) or whichUnit:isDead()) then
            destroy(curTimer)
            return
        end
        x, y = whichUnit:x(), whichUnit:y()
        japi.YD_SetEffectXY(e, x, y)
        japi.YD_SetEffectZ(e, 30 + japi.Z(x, y))
    end)
end

--- 矩形范围
---@param x number
---@param y number
---@param width number 宽
---@param height number 高
---@param duration number|1
---@return void
function alerter.square(x, y, width, height, duration)
    duration = duration or 1
    local e = effector("interface/BossAlertSquare", x, y, 30 + japi.Z(x, y), duration)
    japi.YD_EffectMatScale(e, width / 320, height / 320, 1)
end

--- 异步玩家警告提示
---@param whichPlayer Player
---@param vcm boolean 是否播放音效
---@param msg string 警告信息
---@param red number 红0-255
---@param green number 绿0-255
---@param blue number 蓝0-255
---@param alpha number 透明0-255
---@return void
function alerter.message(whichPlayer, vcm, msg, red, green, blue, alpha)
    if (false == isClass(whichPlayer, PlayerClass)) then
        return
    end
    async.call(whichPlayer, function()
        if (type(vcm) ~= "boolean") then
            vcm = true
        end
        if (type(msg) == "string" and string.len(msg) > 0) then
            if (vcm) then
                audio(Vcm("war3_Error"))
            end
            -- 默认金色
            alpha = alpha or 255
            red = red or 255
            green = green or 215
            blue = blue or 0
            local dur = math.max(3, 0.2 * mbstring.len(msg))
            japi.DZ_SimpleMessageFrameAddMessage(japi.DZ_FrameGetWorldFrameMessage(), msg, japi.DZ_GetColor(alpha, red, green, blue), dur, false)
        end
    end)
end