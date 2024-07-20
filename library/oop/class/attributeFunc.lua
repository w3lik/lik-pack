---@class AttributeFuncClass:TplClass
local class = Class(AttributeFuncClass):extend(TplClass)

--- 攻击模式
---@param modify AttackMode|nil
---@return self|AttackMode
function class:attackMode(modify)
    return self:prop("attackMode", modify)
end

--- 复活时间
--- 负数表示不能复活，建议不能复活设置-999以上，排除动态影响
---@param modify number|nil
---@return self|number
function class:reborn(modify)
    return self:prop("reborn", modify)
end

--- 复活HP百分比（%）0-100
--- 设为0复活HP最低也会有1点
---@param modify number|nil
---@return self|number
function class:rebornHP(modify)
    return self:prop("rebornHP", modify)
end

--- 复活MP百分比（%）0-100
--- 当设定数值计算后比死亡前MP数值小，取前MP数值
---@param modify number|nil
---@return self|number
function class:rebornMP(modify)
    return self:prop("rebornMP", modify)
end

--- 复活后无敌时间
--- 默认3.476
---@param modify number|nil
---@return self|number
function class:rebornInvulnerable(modify)
    return self:prop("rebornInvulnerable", modify)
end

--- HP
---@param modify number
---@return self|number
function class:hp(modify)
    return self:prop("hp", modify)
end

--- HP[当前]
---@param modify number
---@return self|number
function class:hpCur(modify)
    return self:prop("hpCur", modify)
end

--- HP[恢复]
---@param modify number
---@return self|number
function class:hpRegen(modify)
    return self:prop("hpRegen", modify)
end

--- 攻击吸HP
---@param modify number
---@return self|number
function class:hpSuckAttack(modify)
    return self:prop("hpSuckAttack", modify)
end

--- 施法吸HP
---@param modify number
---@return self|number
function class:hpSuckAbility(modify)
    return self:prop("hpSuckAbility", modify)
end

--- MP
---@param modify number
---@return self|number
function class:mp(modify)
    return self:prop("mp", modify)
end

--- MP[当前]
---@param modify number
---@return self|number
function class:mpCur(modify)
    return self:prop("mpCur", modify)
end

--- MP[恢复]
---@param modify number
---@return self|number
function class:mpRegen(modify)
    return self:prop("mpRegen", modify)
end

---攻击吸MP
---@param modify number
---@return self|number
function class:mpSuckAttack(modify)
    return self:prop("mpSuckAttack", modify)
end

--- 施法吸MP
---@param modify number
---@return self|number
function class:mpSuckAbility(modify)
    return self:prop("mpSuckAbility", modify)
end

--- 白昼视野
---@param modify number
---@return self|number
function class:sight(modify)
    return self:prop("sight", modify)
end

--- 黑夜视野
---@param modify number
---@return self|number
function class:nsight(modify)
    return self:prop("nsight", modify)
end

--- 基础视野
---@return self|number
function class:sightBase()
    return self:prop("sightBase")
end

--- 昼夜视野差
---@return self|number
function class:sightDiff()
    return self:prop("sightDiff")
end

--- 攻击
---@param modify number
---@return self|number
function class:attack(modify)
    return self:prop("attack", modify)
end

--- 攻击基础频率
---@param modify number
---@return self|number
function class:attackSpaceBase(modify)
    return self:prop("attackSpaceBase", modify)
end

--- 攻击频率[当前]
---@return number
function class:attackSpace()
    return self:prop("attackSpace")
end

--- 攻击速度加成[%]
---@param modify number
---@return self|number
function class:attackSpeed(modify)
    return self:prop("attackSpeed", modify)
end

--- 主动攻击范围
---@param modify number
---@return self|number
function class:attackRangeAcquire(modify)
    return self:prop("attackRangeAcquire", modify)
end

--- 最小攻击范围
--- 默认0，只在攻击模式为远程时生效，不可大于攻击范围
---@param modify number
---@return self|number
function class:attackRangeMin(modify)
    return self:prop("attackRangeMin", modify)
end

--- 攻击范围
---@param modify number
---@return self|number
function class:attackRange(modify)
    return self:prop("attackRange", modify)
end

--- 随机浮动动态攻击
---@param modify number
---@return self|number
function class:attackRipple(modify)
    return self:prop("attackRipple", modify)
end

--- 防御
--- 直接扣减伤害
---@param modify number
---@return self|number
function class:defend(modify)
    return self:prop("defend", modify)
end

--- 移动
---@param modify number
---@return self|number
function class:move(modify)
    return self:prop("move", modify)
end

--- 力量
---@param modify number
---@return self|number
function class:str(modify)
    return self:prop("str", modify)
end

--- 敏捷
---@param modify number
---@return self|number
function class:agi(modify)
    return self:prop("agi", modify)
end

--- 智力
---@param modify number
---@return self|number
function class:int(modify)
    return self:prop("int", modify)
end

--- 治疗加成[%]
---@param modify number
---@return self|number
function class:cure(modify)
    return self:prop("cure", modify)
end

--- 回避[%]
---@param modify number
---@return self|number
function class:avoid(modify)
    return self:prop("avoid", modify)
end

--- 命中[%]
---@param modify number
---@return self|number
function class:aim(modify)
    return self:prop("aim", modify)
end

--- 护盾
---@param modify number
---@return self|number
function class:shield(modify)
    return self:prop("shield", modify)
end

--- 护盾[当前]
---@param modify number
---@return self|number
function class:shieldCur(modify)
    return self:prop("shieldCur", modify)
end

--- 护盾[恢复][秒]
--- 护盾被击破后会消失一段时间
--- 这个值就是那段时长，默认30秒
---@param modify number
---@return self|number
function class:shieldBack(modify)
    return self:prop("shieldBack", modify)
end

--- 受伤加深[%]
---@param modify number
---@return self|number
function class:hurtIncrease(modify)
    return self:prop("hurtIncrease", modify)
end

--- 减伤比例[%]
---@param modify number
---@return self|number
function class:hurtReduction(modify)
    return self:prop("hurtReduction", modify)
end

--- 受伤反弹比例[%]
---@param modify number
---@return self|number
function class:hurtRebound(modify)
    return self:prop("hurtRebound", modify)
end

--- 伤害加深[%]
---@param modify number
---@return self|number
function class:damageIncrease(modify)
    return self:prop("damageIncrease", modify)
end

--- 暴击[%]
---@param modify number
---@return self|number
function class:crit(modify)
    return self:prop("crit", modify)
end

--- 击晕持续时长[%]
---@param modify number
---@return self|number
function class:stun(modify)
    return self:prop("stun", modify)
end

--- 反隐半径范围
--- 范围[100-2000]只对整百生效
---@param modify number
---@return self|number
function class:visible(modify)
    return self:prop("visible", modify)
end

--- 技能消耗变化[值]
---@param modify number
---@return self|number
function class:cost(modify)
    return self:prop("cost", modify)
end

--- 技能消耗变化[值(资源型)]
---@param modify table
---@return self|table
function class:costWorth(modify)
    return self:prop("costWorth", modify)
end

--- 技能消耗变化[%]
---@param modify number
---@return self|number
function class:costPercent(modify)
    return self:prop("costPercent", modify)
end

--- 技能施法前摇变化[秒]
---@param modify number
---@return self|number
function class:castChant(modify)
    return self:prop("castChant", modify)
end

--- 技能施法前摇变化[%]
---@param modify number
---@return self|number
function class:castChantPercent(modify)
    return self:prop("castChantPercent", modify)
end

--- 技能冷却变化[%]
--- 负数则技能变快
---@param modify number
---@return self|number
function class:coolDownPercent(modify)
    return self:prop("coolDownPercent", modify)
end

--- 技能冷却变化[秒]
--- 负数则技能变快
---@param modify number
---@return self|number
function class:coolDown(modify)
    return self:prop("coolDown", modify)
end

--- 施法持续时间变化[%]
---@param modify number
---@return self|number
function class:castKeepPercent(modify)
    return self:prop("castKeepPercent", modify)
end

--- 施法持续时间变化[秒]
---@param modify number
---@return self|number
function class:castKeep(modify)
    return self:prop("castKeep", modify)
end

--- 施法距离变化[%]
---@param modify number
---@return self|number
function class:castDistancePercent(modify)
    return self:prop("castDistancePercent", modify)
end

--- 施法距离变化[px]
---@param modify number
---@return self|number
function class:castDistance(modify)
    return self:prop("castDistance", modify)
end

--- 施法范围变化[%]
---@param modify number
---@return self|number
function class:castRangePercent(modify)
    return self:prop("castRangePercent", modify)
end

--- 施法范围变化[px]
---@param modify number
---@return self|number
function class:castRange(modify)
    return self:prop("castRange", modify)
end

--- 通用几率[%]
---@param key string
---@param modify number
---@return self|number
function class:odds(key, modify)
    if (modify ~= nil) then
        self:prop(SYMBOL_ODD .. key, modify)
        return self
    end
    return self:prop(SYMBOL_ODD .. key) or 0
end

--- 通用抵抗[%]
---@param key string
---@param modify number
---@return self|number
function class:resistance(key, modify)
    if (type(key) == "table") then
        key = key.value
    end
    must(type(key) == "string")
    if (modify ~= nil) then
        self:prop(SYMBOL_RES .. key, modify)
        return self
    end
    return self:prop(SYMBOL_RES .. key) or 0
end

--- 附魔强化[%]
---@param key string|table 附魔类型|DAMAGE_TYPE
---@param modify number|nil
---@return self|number
function class:enchant(key, modify)
    if (type(key) == "table") then
        key = key.value
    end
    must(type(key) == "string")
    if (modify ~= nil) then
        self:prop(SYMBOL_E .. key, modify)
        return self
    end
    return self:prop(SYMBOL_E .. key) or 0
end

--- 附魔抵抗[%]
---@param key string|table 附魔类型|DAMAGE_TYPE
---@param modify number|nil
---@return self|number
function class:enchantResistance(key, modify)
    if (type(key) == "table") then
        key = key.value
    end
    must(type(key) == "string")
    if (modify ~= nil) then
        self:resistance(SYMBOL_E .. key, modify)
        return self
    end
    return self:resistance(SYMBOL_E .. key) or 0
end

--- 附魔免疫
---@param key string|table 附魔类型|DAMAGE_TYPE
---@param modify number|nil
---@return self|number
function class:enchantImmune(key, modify)
    if (type(key) == "table") then
        key = key.value
    end
    must(type(key) == "string")
    if (modify ~= nil) then
        self:prop(SYMBOL_EI .. key, modify)
        return self
    end
    return self:prop(SYMBOL_EI .. key) or 0
end

--- 是否附魔免疫
---@param key string|table 附魔类型|DAMAGE_TYPE
---@return boolean
function class:isEnchantImmune(key)
    return self:enchantImmune(key) > 0
end

--- 附魔原始材质
--- 如火史莱姆之类的会用这方法在初始化就绑定一种属性
---@param modify table|nil DAMAGE_TYPE
---@return self|table
function class:enchantMaterial(modify)
    if (type(modify) == "table") then
        return self:prop("enchantMaterial", modify)
    end
    return self:prop("enchantMaterial")
end

--- 附魔精通[%]
--- 影响所有元素伤害，影响附魔反应的效果
---@param modify number
---@return self|number
function class:enchantMystery(modify)
    if (modify) then
        return self:prop("enchantMystery", modify)
    end
    return self:prop("enchantMystery") or 0
end