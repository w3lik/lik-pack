--[[
    底层技能 伤害
    接引流 Flow `damage`
    使用 Unit:isHurting() 判断是否受伤中
    使用 Unit:isDamaging() 判断是否造成伤害中
    options = {
        sourceUnit 源单位
        targetUnit 目标单位
        damage 伤害值
        damageSrc 伤害来源
        damageType 伤害类型（影响元素反应或自定义效果）
        damageTypeLevel 伤害类级别（影响元素附着或自定义效果）
        breakArmor 破甲类型
    }
]]
---@see file variable/prop DAMAGE_TYPE|DAMAGE_SRC|BREAK_ARMOR
---@alias noteOnUnitDamagingData {sourceUnit:Unit,targetUnit:Unit,damage:number,damageSrc:table,damageType:table,damageTypeLevel:number,breakArmor:table[]}
---@param options noteOnUnitDamagingData
function ability.damage(options)
    options.damage = options.damage or 0
    if (options.damage < 1 or false == isClass(options.targetUnit, UnitClass)) then
        return
    end
    if (options.targetUnit:isDead()) then
        return
    end
    if (options.sourceUnit ~= nil) then
        if (false == isClass(options.sourceUnit, UnitClass)) then
            return
        end
        if (options.sourceUnit:isDead()) then
            return
        end
    end
    -- 禁用错误的伤害来源
    options.damageSrc = options.damageSrc or DAMAGE_SRC.common
    if (options.damageSrc == DAMAGE_SRC.attack and options.sourceUnit ~= nil and options.sourceUnit:isUnArming()) then
        return
    elseif (options.damageSrc == DAMAGE_SRC.ability and options.sourceUnit ~= nil and options.sourceUnit:isSilencing()) then
        return
    end
    event.syncTrigger(options.targetUnit, EVENT.Unit.BeforeHurt, options)
    options.damageType = options.damageType or DAMAGE_TYPE.common
    options.damageTypeLevel = options.damageTypeLevel or 0
    options.breakArmor = options.breakArmor or {}
    FlowRun("damage", options)
    if (options.damage >= 1) then
        if (options.sourceUnit ~= nil) then
            options.targetUnit:lastHurtSource(options.sourceUnit)
            options.sourceUnit:lastDamageTarget(options.targetUnit)
            options.sourceUnit:superposition("damage", "+=1")
            options.sourceUnit:owner():superposition("damage", "+=1")
            time.setTimeout(3.5, function()
                if (false == isDestroy(options.sourceUnit)) then
                    options.sourceUnit:superposition("damage", "-=1")
                    options.sourceUnit:owner():superposition("damage", "-=1")
                end
            end)
            event.syncTrigger(options.sourceUnit, EVENT.Unit.Damage, options)
            if (options.damageSrc == DAMAGE_SRC.attack) then
                event.syncTrigger(options.sourceUnit, EVENT.Unit.Attack, options)
            elseif (options.damageSrc == DAMAGE_SRC.rebound) then
                event.syncTrigger(options.sourceUnit, EVENT.Unit.Rebound, options)
            end
        end
        options.targetUnit:superposition("hurt", "+=1")
        options.targetUnit:owner():superposition("hurt", "+=1")
        time.setTimeout(3.5, function()
            if (false == isDestroy(options.targetUnit)) then
                options.targetUnit:superposition("hurt", "-=1")
                options.targetUnit:owner():superposition("hurt", "-=1")
            end
        end)
        event.syncTrigger(options.targetUnit, EVENT.Unit.Hurt, options)
        if (options.damageSrc == DAMAGE_SRC.attack) then
            event.syncTrigger(options.targetUnit, EVENT.Unit.Be.Attack, options)
        elseif (options.damageSrc == DAMAGE_SRC.rebound) then
            event.syncTrigger(options.targetUnit, EVENT.Unit.Be.Rebound, options)
        end
        options.targetUnit:hpCur("-=" .. options.damage)
    end
end
