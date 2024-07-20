---@private
local _call = function(isOK, options, vec)
    if (isClass(options.arrowToken, EffectClass)) then
        destroy(options.arrowToken)
    end
    local res = isOK
    if (res == true and type(options.onEnd) == "function") then
        res = options.onEnd(options, vec)
    end
    if (res == true and (options.reflex or 0) > 0) then
        if (isClass(options.targetUnit, UnitClass) and false == isDestroy(options.targetUnit)) then
            local nextUnit = Group():rand(UnitClass, {
                circle = {
                    x = vec[1],
                    y = vec[2],
                    radius = 600,
                },
                ---@param enumUnit Unit
                filter = function(enumUnit)
                    local ownerCheck = true
                    if (isClass(options.sourceUnit, UnitClass)) then
                        ownerCheck = enumUnit:isEnemy(options.sourceUnit:owner())
                    end
                    return ownerCheck and enumUnit:isOther(options.targetUnit) and enumUnit:isAlive()
                end
            })
            if (isClass(nextUnit, UnitClass)) then
                ability.missile({
                    modelAlias = options.modelAlias,
                    scale = options.scale,
                    sourceUnit = options.sourceUnit,
                    speed = options.speed,
                    height = options.height,
                    acceleration = options.acceleration,
                    shake = options.shake,
                    shakeOffset = options.shakeOffset,
                    reflexOffset = options.reflexOffset,
                    reflex = options.reflex - 1,
                    onMove = options.onMove,
                    onEnd = options.onEnd,
                    sourceVec = vec,
                    targetUnit = nextUnit,
                })
            else
                local reflexOffset = options.reflexOffset or 300
                local rx, ry = vector2.polar(vec[1], vec[2], reflexOffset, math.rand(0, 359))
                ability.missile({
                    modelAlias = options.modelAlias,
                    scale = options.scale,
                    speed = options.speed,
                    height = 0,
                    acceleration = options.acceleration,
                    shake = options.shake,
                    shakeOffset = options.shakeOffset,
                    sourceVec = vec,
                    targetVec = { rx, ry, vec[3] },
                    onEnd = function(_, vec2)
                        if (isClass(options.targetUnit, UnitClass)) then
                            ability.missile({
                                modelAlias = options.modelAlias,
                                scale = options.scale,
                                sourceUnit = options.sourceUnit,
                                speed = options.speed,
                                height = options.height,
                                acceleration = options.acceleration,
                                shake = options.shake,
                                shakeOffset = options.shakeOffset,
                                reflexOffset = options.reflexOffset,
                                reflex = options.reflex - 1,
                                onMove = options.onMove,
                                onEnd = options.onEnd,
                                sourceVec = vec2,
                                targetUnit = options.targetUnit,
                            })
                        end
                    end
                })
            end
        end
    end
end

--[[
    模版技能 虚拟箭矢
    options = {
        sourceUnit = Unit, --[可选]伤害来源（没有来源单位时，必须有sourceVec）
        targetUnit = Unit, --[可选]目标单位（有单位目标，那么冲击跟踪到单位就结束）
        sourceVec = number[3][可选]强制设定初始坐标
        targetVec = number[3][可选]强制设定目标坐标
        modelAlias = nil, --[必须]虚拟箭矢的特效
        animateScale = 1.00, --[可选]虚拟箭矢的动画速度，默认1
        scale = 1.00, --[可选]虚拟箭矢的模型缩放，默认1
        speed = 500, --[可选]每秒冲击的距离，默认1秒500px
        acceleration = 0, --[可选]冲击加速度，每个周期[0.02秒]都会增加一次
        height = 0, --[可选]飞跃高度，默认0
        weaponHeight = 0, --[可选]武器高度，默认20
        weaponLength = 0, --[可选]武器长度，默认20
        reflex = 0, --[可选]弹射次数，默认0，优先选择其余单位，没有则跳回原target
        reflexOffset = 300, --[可选]弹射跳回原target时的偏移距离，默认300
        shake = 0, --[可选]摇摆角度[number|"rand"]默认0
        shakeOffset = 50%, --[可选]摇摆偏移，默认为距离的50%
        onMove = noteAbilityMissileOnEvt, --[可选]每周期回调,当return false时可强行中止循环
        onEnd = noteAbilityMissileOnEvt, --[可选]结束回调,当return true时才会执行reflex
    }
]]
---@alias noteAbilityMissileOnEvt fun(options:noteAbilityMissileOptions,vec:number[]):boolean
---@alias noteAbilityMissileOptions {modelAlias:string,animateScale:number,scale:number,speed:number,acceleration:number,height:number,weaponHeight:number,weaponLength:number,shake:number,shakeOffset:number,reflex:number,reflexOffset:number,sourceUnit:Unit,targetUnit:Unit,sourceVec:number[],targetVec:number[],onMove:noteAbilityMissileOnEvt,onEnd:noteAbilityMissileOnEvt}
---@param options noteAbilityMissileOptions
function ability.missile(options)
    must(type(options.modelAlias) == "string")
    if (type(options.targetVec) ~= "table") then
        must(isClass(options.targetUnit, UnitClass))
    end
    
    options.acceleration = options.acceleration or 0
    options.animateScale = options.animateScale or 1
    options.scale = options.scale or 1
    local frequency = 0.02
    local speed = math.min(5000, math.max(50, options.speed or 500))
    local collision = 0
    local swh
    if (isClass(options.sourceUnit, UnitClass)) then
        swh = options.sourceUnit:weaponHeight()
    end
    local weaponHeight = (options.weaponHeight or swh) or 20
    
    local vecS = options.sourceVec
    local vecT
    if (type(options.targetVec) == "table") then
        vecT = { options.targetVec[1], options.targetVec[2], options.targetVec[3] or japi.Z(options.targetVec[1], options.targetVec[2]) }
    else
        vecT = { options.targetUnit:x(), options.targetUnit:y(), weaponHeight + options.targetUnit:h() + options.targetUnit:stature() / 2 }
        collision = options.targetUnit:collision()
    end
    local facing = 0
    if (type(vecS) ~= "table") then
        facing = vector2.angle(options.sourceUnit:x(), options.sourceUnit:y(), vecT[1], vecT[2])
        local wl = options.weaponLength or options.sourceUnit:weaponLength()
        local sx, sy = vector2.polar(options.sourceUnit:x(), options.sourceUnit:y(), wl, facing)
        vecS = { sx, sy, weaponHeight + options.sourceUnit:h() }
    else
        vecS[3] = vecS[3] or japi.Z(vecS[1], vecS[2])
        facing = vector2.angle(vecS[1], vecS[2], vecT[1], vecT[2])
    end
    must(type(vecS) == "table", "sourceVec")
    
    local distance = vector2.distance(vecS[1], vecS[2], vecT[1], vecT[2])
    local deviateX = math.min(1, distance / 300)
    local deviateY = math.min(1, distance / 500)
    local width = distance * (1 - 0.5 * math.min(1, deviateX))
    local height = (options.height or 0)
    height = height * deviateY
    local agl = math.atan(math.abs(vecT[3] - vecS[3]), distance)
    local xRot, yRot = vector2.rotate(width, height, math._r2d * agl)
    local zRot = yRot + vecS[3]
    local rotL1 = -math._r2d * math.atan(yRot, xRot)
    local rotL2 = -math._r2d * math.atan(zRot - vecT[3], distance - xRot)
    local rotateRate = 2.2
    local dtStep = distance / speed / frequency
    local dtSpd = 1 / dtStep
    local dtRot1 = rotateRate * rotL1 / dtStep
    local dtRot2 = rotateRate * rotL2 / dtStep
    
    local shake = options.shake
    local shakeOffset = options.shakeOffset or xRot
    if (shake == "rand") then
        shake = math.rand(0, 359)
    elseif (type(shake) == "number") then
        shake = math.ceil(shake) % 360
    else
        shake = 0
    end
    local mx, my = vector2.polar(vecS[1], vecS[2], shakeOffset, facing + shake)
    local vecM = { mx, my, zRot }
    
    options.arrowToken = Effect(options.modelAlias, vecS[1], vecS[2], vecS[3], -1)
    options.arrowToken:speed(options.animateScale):size(options.scale):rotateZ(facing):rotateY(rotL1)
    
    local dt = 0
    local distanceCur = distance
    local distancePrev
    local faraway = frequency * speed * 30
    local rotY = rotL1
    local vecC
    time.setInterval(frequency, function(curTimer)
        if (isDestroy(options.arrowToken) or (isClass(options.targetUnit, UnitClass) and isDestroy(options.targetUnit))) then
            destroy(curTimer)
            _call(false, options, vecC or vecS)
            return
        end
        local di = 1
        if (type(options.targetVec) ~= "table") then
            if (options.targetUnit ~= nil and options.targetUnit:isAlive()) then
                vecT = { options.targetUnit:x(), options.targetUnit:y(), options.targetUnit:h() + options.targetUnit:stature() / 2 }
                di = distance / distanceCur
            end
        end
        di = math.min(1, di)
        dt = dt + dtSpd * di
        if (options.acceleration > 0) then
            dtSpd = dtSpd + 1 / (distance / options.acceleration / frequency)
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
        options.arrowToken:position(vecC[1], vecC[2], vecC[3])
        options.arrowToken:rotateZ(vector2.angle(vecC[1], vecC[2], vecT[1], vecT[2]))
        if (dt <= 0.5) then
            rotY = rotY - dtRot1 * di
        else
            rotY = rotY - dtRot2 * di
        end
        options.arrowToken:rotateY(rotY)
        distancePrev = distanceCur
        if (dt >= 1 or distanceCur <= collision) then
            destroy(curTimer)
            _call(true, options, vecT)
        end
    end)
end