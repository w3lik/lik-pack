--[[
    模版技能 暴击
    options = {
        sourceUnit 伤害来源
        targetUnit 目标单位
        damage 暴击最终伤害
        damageSrc 伤害来源 DAMAGE_SRC
        damageType 伤害类型
        damageTypeLevel 伤害等级
        breakArmor 破防类型
    }
]]
---@param options {sourceUnit:Unit,targetUnit:Unit,effect:string,damage:number,damageSrc:table,damageType:table,damageTypeLevel:number,breakArmor:table}
function ability.crit(options)
    local sourceUnit = options.sourceUnit
    local targetUnit = options.targetUnit
    if (isClass(sourceUnit, UnitClass) == false or sourceUnit:isDead()) then
        return
    end
    if (isClass(targetUnit, UnitClass) == false or targetUnit:isDead()) then
        return
    end
    targetUnit:effect(options.effect, 0.2)
    event.syncTrigger(sourceUnit, EVENT.Unit.CritAbility, { targetUnit = targetUnit })
    event.syncTrigger(targetUnit, EVENT.Unit.Be.CritAbility, { sourceUnit = sourceUnit })
    local damage = options.damage or 0
    if (damage > 0) then
        ability.damage({
            sourceUnit = sourceUnit,
            targetUnit = targetUnit,
            damage = damage,
            damageSrc = options.damageSrc or DAMAGE_SRC.ability,
            damageType = options.damageType or DAMAGE_TYPE.common,
            damageTypeLevel = options.damageTypeLevel,
            breakArmor = options.breakArmor or { BREAK_ARMOR.avoid }
        })
    end
end