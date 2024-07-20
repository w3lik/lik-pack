---@private
local _call = function(isOK, options, vec)
    local res = isOK
    options.buff:back()
    options.buff = nil
    local qty = 0
    if (type(options.bounce) == "table") then
        qty = options.bounce.qty or 0
    end
    if (res == true) then
        local resBounce = true
        if (qty > 0) then
            if (type(options.onBounce) == "function") then
                local r = options.onBounce(options, vec)
                if (type(r) == "boolean" and r == false) then
                    resBounce = false
                end
            end
            if (resBounce == true) then
                local di = options.bounce.distance or 0.8
                local he = options.bounce.height or 0.8
                local du = options.bounce.duration or 0.8
                if (isClass(options.targetUnit, UnitClass) and false == isDestroy(options.targetUnit)) then
                    ability.crackFly({
                        sourceUnit = options.sourceUnit,
                        targetUnit = options.targetUnit,
                        effect = options.effect,
                        attach = options.attach,
                        animate = options.animate,
                        animateScale = options.animateScale,
                        distance = options.distance * di,
                        height = options.height * he,
                        duration = options.duration * du,
                        bounce = { qty = qty - 1, distance = di, height = he, duration = du },
                        onMove = options.onMove,
                        onBounce = options.onBounce,
                        onEnd = options.onEnd,
                    })
                end
                return
            end
        end
        if (type(options.onEnd) == "function") then
            res = options.onEnd(options, vec)
        end
    end
end

--[[
    模版技能 击飞
    使用 Unit:isCrackFlying() 判断是否经历被击飞
    options = {
        sourceUnit = Unit, --[可选]伤害来源
        targetUnit = Unit, --[必须]目标单位
        effect = nil, --[可选]目标单位飞行特效
        attach = nil, --[可选]目标单位飞行特效位置默认origin
        animate = "dead", --[可选]目标单位飞行动作或序号,默认无
        animateScale = 1.00, --[可选]目标单位飞行动画速度，默认1
        distance = 0, --[可选]击退距离，默认0
        height = 100, --[可选]飞跃高度，默认100
        duration = 0.5, --[必须]击飞过程持续时间，可选，默认0.5秒
        bounce = noteAbilityCrackFlyBounceParam, --[可选]弹跳参数，noteAbilityCrackFlyBounceParam
        onMove = noteAbilityCrackFlyOnEvt, --[可选]每周期回调（return false时可强行中止循环）
        onBounce = noteAbilityCrackFlyOnEvt, --[可选]每弹跳回调（return false时可强行中止后续弹跳）
        onEnd = noteAbilityCrackFlyOnEvt, --[可选]结束回调（弹跳完毕才算结束）
    }
]]
---@alias noteAbilityCrackFlyBounceParam {qty:0, distance:0.8, height:0.8, duration:0.8} qty弹跳次数，后面三个为相对前1次的相乘变化率，默认0.8
---@alias noteAbilityCrackFlyParam {sourceUnit:Unit,targetUnit:Unit,effect:string,attach:string,animate:number,animateScale:number,distance:number,height:number,bounce:noteAbilityCrackFlyBounceParam,duration:number,onMove:noteAbilityCrackFlyOnEvt,onEnd:noteAbilityCrackFlyOnEvt,onBounce:noteAbilityCrackFlyOnEvt}
---@alias noteAbilityCrackFlyOnEvt fun(options:noteAbilityCrackFlyParam,vec:number[]):boolean
---@param options noteAbilityCrackFlyParam|noteAbilityBuff
function ability.crackFly(options)
    local sourceUnit = options.sourceUnit
    local targetUnit = options.targetUnit
    if (isClass(targetUnit, UnitClass) == false or targetUnit:isDead()) then
        return
    end
    options.distance = math.max(0, options.distance or 0)
    options.height = options.height or 100
    options.duration = options.duration or 0.5
    if (options.height <= 0 or options.duration < 0.1) then
        return
    end
    if (targetUnit:isCrackFlying()) then
        return
    end
    if (isClass(sourceUnit, UnitClass)) then
        event.syncTrigger(sourceUnit, EVENT.Unit.CrackFly, { targetUnit = targetUnit, distance = options.distance, height = options.height, duration = options.duration })
    end
    event.syncTrigger(targetUnit, EVENT.Unit.Be.CrackFly, { sourceUnit = sourceUnit, distance = options.distance, height = options.height, duration = options.duration })
    
    local frequency = 0.02
    if (options.animate) then
        targetUnit:animate(options.animate)
    end
    
    local flyHeight0 = targetUnit:flyHeight()
    local animateDiff = (options.animateScale or 1) - targetUnit:animateScale()
    local attach = options.attach or "origin"
    options.buff = targetUnit:buff("crackFly"):signal(BUFF_SIGNAL.down)
    options.buff:name(options.name)
    options.buff:icon(options.icon)
    options.buff:description(options.description)
    options.buff
           :duration(-1)
           :purpose(
        function(buffObj)
            buffObj:attach(options.effect, attach)
            if (animateDiff ~= 0) then
                buffObj:animateScale("+=" .. animateDiff)
            end
            buffObj:superposition("crackFly", "+=1")
            buffObj:superposition("noPath", "+=1")
            buffObj:superposition("pause", "+=1")
        end)
           :rollback(
        function(buffObj)
            buffObj:detach(options.effect, attach)
            if (animateDiff ~= 0) then
                buffObj:animateScale("-=" .. animateDiff)
            end
            buffObj:flyHeight(flyHeight0)
            buffObj:superposition("pause", "-=1")
            buffObj:superposition("noPath", "-=1")
            buffObj:superposition("crackFly", "-=1")
        end)
    local fac0 = 0
    if (isClass(sourceUnit, UnitClass)) then
        fac0 = vector2.angle(sourceUnit:x(), sourceUnit:y(), targetUnit:x(), targetUnit:y())
    else
        fac0 = targetUnit:facing() - 180
    end
    local vecS = { targetUnit:x(), targetUnit:y(), targetUnit:h() }
    local tx, ty = vector2.polar(targetUnit:x(), targetUnit:y(), options.distance, fac0)
    local vecT = { tx, ty, targetUnit:h() }
    
    local dtSpd = 1 / (options.duration / frequency)
    
    local mid = vector2.distance(vecS[1], vecS[2], vecT[1], vecT[2])
    local mx, my = vector2.polar(vecS[1], vecS[2], mid, fac0)
    local vecM = { mx, my, 1.5 * options.height }
    
    options.buff:run()
    local dt = 0
    local vecC
    time.setInterval(frequency, function(curTimer)
        if (targetUnit:isDead()) then
            destroy(curTimer)
            _call(false, options, vecC or vecS)
            return
        end
        dt = dt + dtSpd
        local nx, ny, nz = vector3.bezier2(vecS, vecM, vecT, dt)
        local vecN = { nx, ny, nz }
        if (RegionPlayable:isBorder(vecN[1], vecN[2])) then
            vecN = vecC
        end
        if (type(options.onMove) == "function") then
            local mRes = options.onMove(options, vecN or vecS)
            if (mRes == false) then
                destroy(curTimer)
                _call(false, options, vecC)
                return
            end
        end
        vecC = vecN
        targetUnit:flyHeight(vecC[3])
        if (dt >= 1) then
            targetUnit:position(vecC[1], vecC[2])
        else
            J.SetUnitX(targetUnit:handle(), vecC[1])
            J.SetUnitY(targetUnit:handle(), vecC[2])
        end
        if (dt >= 1) then
            destroy(curTimer)
            _call(true, options, vecT)
        end
    end)
end