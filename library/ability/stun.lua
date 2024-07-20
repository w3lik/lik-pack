--[[
    模版技能 眩晕
    使用 Unit:isStunning() 判断是否眩晕
    options = {
        sourceUnit 源单位
        targetUnit 目标单位
        duration 持续时间
        odds 几率0-100
        effect 绑定特效路径
        attach 绑定特效位置
    }
]]
---@param options {targetUnit:Unit,sourceUnit:Unit,duration:number,odds:number,effect:string,attach:string}|noteAbilityBuff
function ability.stun(options)
    local targetUnit = options.targetUnit
    local sourceUnit = options.sourceUnit
    if (isClass(targetUnit, UnitClass) == false or targetUnit:isDead()) then
        return
    end
    if (isClass(sourceUnit, UnitClass)) then
        if (sourceUnit:isDead()) then
            return
        end
    end
    local duration = options.duration or 0
    if (duration <= 0) then
        return
    end
    local odds = (options.odds or 100) - targetUnit:resistance("stun")
    if (odds < math.rand(1, 100)) then
        return
    end
    if (sourceUnit) then
        event.syncTrigger(sourceUnit, EVENT.Unit.Stun, { targetUnit = targetUnit, duration = duration })
    end
    event.syncTrigger(targetUnit, EVENT.Unit.Be.Stun, { sourceUnit = sourceUnit, duration = duration })
    local effect = options.effect or "ThunderclapTarget"
    local attach = options.attach or "overhead"
    local b = targetUnit:buff("stun"):signal(BUFF_SIGNAL.down)
    b:name(options.name)
    b:icon(options.icon)
    b:description(options.description)
    b:duration(duration)
     :purpose(function(buffObj)
        buffObj:attach(effect, attach)
        buffObj:superposition("stun", "+=1")
        buffObj:superposition("pause", "+=1")
    end)
     :rollback(function(buffObj)
        buffObj:detach(effect, attach)
        buffObj:superposition("pause", "-=1")
        buffObj:superposition("stun", "-=1")
    end)
     :run()
end