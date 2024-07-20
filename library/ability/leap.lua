---@private
local _call = function(isOK, options, vec)
    options.buff:back()
    options.buff = nil
    local qty = options.reflex or 0
    local res = isOK
    if (res == true) then
        local resReflex = true
        if (qty > 0 and isClass(options.targetUnit, UnitClass)) then
            if (type(options.onReflex) == "function") then
                local r = options.onReflex(options, vec)
                if (type(r) == "boolean" and r == false) then
                    resReflex = false
                end
            end
            if (resReflex == true) then
                local nextUnit = Group():rand(UnitClass, {
                    circle = {
                        x = vec[1],
                        y = vec[2],
                        radius = 600,
                    },
                    ---@param enumUnit Unit
                    filter = function(enumUnit)
                        return enumUnit:isOther(options.targetUnit) and enumUnit:isAlive() and enumUnit:isEnemy(options.sourceUnit:owner())
                    end,
                })
                if (isClass(nextUnit, UnitClass)) then
                    ability.leap({
                        sourceUnit = options.sourceUnit,
                        targetUnit = nextUnit,
                        modelAlias = options.modelAlias,
                        speed = options.speed,
                        acceleration = options.acceleration,
                        height = options.height,
                        shake = options.shake,
                        shakeOffset = options.shakeOffset,
                        reflex = options.reflex - 1,
                        onMove = options.onMove,
                        onReflex = options.onReflex,
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
    模版技能 冲锋
    使用 Unit:isLeaping() 判断是否冲锋中
    options = {
        sourceUnit, --[必须]冲锋单位，同时也是伤害来源
        targetUnit, --[可选]目标单位（有单位目标，那么冲击跟踪到单位就结束）
        targetVec = number[3][可选]强制设定目标坐标
        modelAlias = nil, --[可选]冲锋单位origin特效
        animate = "attack", --[可选]冲锋动作
        animateScale = 1.00, --[可选]冲锋的动画速度
        speed = 500, --[可选]每秒冲击的距离（默认1秒500px)
        acceleration = 0, --[可选]冲击加速度（每个周期[0.02秒]都会增加一次)
        height = 0, --[可选]飞跃高度（默认0)
        shake = 0, --[可选]摇摆角度[number|"rand"]默认0
        shakeOffset = 50%, --[可选]摇摆偏移，默认为距离的50%
        reflex = 0, --[可选]弹射次数，当targetUnit存在时才有效，默认0
        onMove = [function], --[可选]每周期移动回调（return false时可强行中止循环）
        onReflex = [function], --[可选]每弹跳回调（return false时可强行中止后续弹跳）
        onEnd = [function], --[可选]结束回调（弹跳完毕才算结束）
    }
]]
---@alias noteAbilityLeapOnEvt fun(options:noteAbilityLeapOptions,vec:number[]):nil|boolean
---@alias noteAbilityLeapOptions {sourceUnit:Unit,targetUnit:Unit,targetVec:number[],animate:string,animateScale:number,speed:number,acceleration:number,height:number,shake:number,shakeOffset:number,reflex:number,modelAlias:string,onMove:noteAbilityLeapOnEvt,onEnd:noteAbilityLeapOnEvt,onReflex:noteAbilityLeapOnEvt}
---@param options noteAbilityLeapOptions|noteAbilityBuff
function ability.leap(options)
    local sourceUnit = options.sourceUnit
    must(isClass(sourceUnit, UnitClass))
    if (type(options.targetVec) ~= "table") then
        must(isClass(options.targetUnit, UnitClass))
    end
    if (sourceUnit:isLeaping()) then
        return
    end
    
    options.acceleration = options.acceleration or 0
    local frequency = 0.02
    local speed = math.min(5000, math.max(100, options.speed or 500))
    
    local vecS = { sourceUnit:x(), sourceUnit:y(), sourceUnit:h() }
    ---@type number[]
    local vecT
    if (type(options.targetVec) == "table") then
        vecT = { options.targetVec[1], options.targetVec[2], options.targetVec[3] or japi.Z(options.targetVec[1], options.targetVec[2]) }
    else
        vecT = { options.targetUnit:x(), options.targetUnit:y(), options.targetUnit:h() }
    end
    
    local distance0 = vector2.distance(vecS[1], vecS[2], vecT[1], vecT[2])
    local dtStep = distance0 / speed / frequency
    local dtSpd = 1 / dtStep
    
    local height = vecS[3] + (vecT[3] - vecS[3]) * 0.5 + (options.height or 0)
    
    local shake = options.shake
    local shakeOffset = options.shakeOffset or distance0 / 2
    if (shake == "rand") then
        shake = math.rand(0, 359)
    elseif (type(shake) == "number") then
        shake = math.ceil(shake) % 360
    else
        shake = 0
    end
    
    local facing = vector2.angle(vecS[1], vecS[2], vecT[1], vecT[2])
    local mx, my = vector2.polar(vecS[1], vecS[2], shakeOffset, facing + shake)
    local vecM = { mx, my, height }
    
    if (options.animate) then
        sourceUnit:animate(options.animate)
    end
    
    local flyHeight0 = sourceUnit:flyHeight()
    local animateDiff = (options.animateScale or 1) - sourceUnit:animateScale()
    
    options.buff = sourceUnit:buff("leap")
    options.buff:name(options.name)
    options.buff:icon(options.icon)
    options.buff:description(options.description)
    options.buff
           :duration(-1)
           :purpose(
        function(buffObj)
            buffObj:attach(options.modelAlias, "origin")
            if (animateDiff ~= 0) then
                buffObj:animateScale("+=" .. animateDiff)
            end
            buffObj:superposition("leap", "+=1")
            buffObj:superposition("noPath", "+=1")
            buffObj:superposition("pause", "+=1")
        end)
           :rollback(
        function(buffObj)
            buffObj:detach(options.modelAlias, "origin")
            if (animateDiff ~= 0) then
                buffObj:animateScale("-=" .. animateDiff)
            end
            buffObj:flyHeight(flyHeight0)
            buffObj:superposition("pause", "-=1")
            buffObj:superposition("noPath", "-=1")
            buffObj:superposition("leap", "-=1")
        end)
           :run()
    
    local dt = 0
    local distanceCur = distance0
    local distancePrev
    local collision = sourceUnit:collision() * 2
    local faraway = frequency * speed * 30
    local vecC
    time.setInterval(frequency, function(curTimer)
        if (sourceUnit:isDead()) then
            destroy(curTimer)
            _call(false, options, vecC or vecS)
            return
        end
        local di = 1
        if (type(options.targetVec) ~= "table") then
            if (options.targetUnit ~= nil and options.targetUnit:isAlive()) then
                vecT = { options.targetUnit:x(), options.targetUnit:y(), options.targetUnit:h() }
                di = distance0 / distanceCur
            end
        end
        di = math.min(1, di)
        dt = dt + dtSpd * di
        if (options.acceleration > 0) then
            dtSpd = dtSpd + 1 / (distance0 / options.acceleration / frequency)
        end
        
        local nx, ny, nz = vector3.bezier2(vecS, vecM, vecT, dt)
        local vecN = { nx, ny, nz }
        if (RegionPlayable:isBorder(vecN[1], vecN[2])) then
            destroy(curTimer)
            _call(false, options, vecC)
            return
        end
        vecC = vecN
        distanceCur = vector2.distance(vecC[1], vecC[2], vecT[1], vecT[2])
        if (distanceCur > collision and distancePrev ~= nil) then
            if ((distanceCur - distancePrev) > faraway) then
                destroy(curTimer)
                _call(false, options, vecC)
                return
            end
        end
        if (distanceCur <= collision) then
            vecC = { vecT[1], vecT[2], vecT[3] }
        end
        if (type(options.onMove) == "function") then
            local mRes = options.onMove(options, vecC)
            if (mRes == false) then
                destroy(curTimer)
                _call(false, options, vecC)
                return
            end
        end
        if (dt >= 1) then
            sourceUnit:position(vecC[1], vecC[2])
        else
            J.SetUnitX(sourceUnit:handle(), vecC[1])
            J.SetUnitY(sourceUnit:handle(), vecC[2])
        end
        sourceUnit:flyHeight(vecC[3])
        sourceUnit:facing(vector2.angle(vecC[1], vecC[2], vecT[1], vecT[2]))
        distancePrev = distanceCur
        if (dt >= 1 or distanceCur <= collision) then
            destroy(curTimer)
            _call(true, options, vecT)
        end
    end)
end