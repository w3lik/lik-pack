### 属性配置

```lua
attribute.conf("str", "力量")
attribute.conf("agi", "敏捷")
attribute.conf("int", "智力")
attribute.conf("animateScale", "动作")
attribute.conf("reborn", "复活时间")
attribute.conf("hp", "HP")
attribute.conf("hpCur", "当前HP")
attribute.conf("hpRegen", "HP恢复", "每秒")
attribute.conf("hpSuckAttack", "攻击吸血", '%')
attribute.conf("hpSuckAbility", "技能吸血", '%')
attribute.conf("mp", "MP")
attribute.conf("mpCur", "当前MP")
attribute.conf("mpRegen", "MP恢复", "每秒")
attribute.conf("mpSuckAttack", "攻击吸魔", '%')
attribute.conf("mpSuckAbility", "技能吸魔", '%')
attribute.conf("move", "移动")
attribute.conf("defend", "防御")
attribute.conf("attackSpeed", "攻击速度", '%')
attribute.conf("attackSpace", "攻击间隔", "击每秒", true)
attribute.conf("attackSpaceBase", "原始攻击间隔", "击每秒", true)
attribute.conf("attack", "攻击")
attribute.conf("attackRipple", "攻击浮动")
attribute.conf("attackRange", "攻击范围")
attribute.conf("attackRangeAcquire", "主动攻击范围")
attribute.conf("sight", "白昼视野")
attribute.conf("nsight", "夜晚视野")
attribute.conf("visible", "反隐范围")
attribute.conf("avoid", "回避", '%')
attribute.conf("aim", "命中", '%')
attribute.conf("crit", "暴击", '%')
attribute.conf("stun", "眩晕", '%')
attribute.conf("invulnerable", "无敌", '%')
attribute.conf("cure", "治疗加成", '%')
attribute.conf("enchantMystery", "附魔精通", '%')
attribute.conf("shield", "护盾")
attribute.conf("shieldBack", "护盾恢复需时", "秒", true)
attribute.conf("hurtIncrease", "受伤加深", '%', true)
attribute.conf("hurtReduction", "受伤减轻", '%')
attribute.conf("hurtRebound", "反弹伤害", '%')
attribute.conf("damageIncrease", "伤害增幅", '%')
attribute.conf("coolDown", "冷却时间", "秒", true)
attribute.conf("coolDownPercent", "冷却时间", '%', true)
attribute.conf("castChant", "吟唱时间", "秒", true)
attribute.conf("castChantPercent", "吟唱时间", '%', true)
attribute.conf("castKeep", "施法持续时间", "秒")
attribute.conf("castKeepPercent", "施法持续时间", '%')
attribute.conf("castDistance", "施法距离")
attribute.conf("castDistancePercent", "施法距离", '%')
attribute.conf("castRange", "施法范围")
attribute.conf("castRangePercent", "施法范围", '%')
attribute.conf("cost", "施法消耗", nil, true)
attribute.conf("costPercent", "施法消耗", '%', true)
attribute.conf("sp", "额外特性")
--
for _, k in ipairs(ENCHANT_TYPES) do
    local name = Enchant(k):name()
    attribute.conf(k, name)
    attribute.conf(SYMBOL_E .. k, attribute.label(k) .. "强化", '%')
    attribute.conf(SYMBOL_E .. k .. "Weapon", attribute.label(k) .. "武装")
    attribute.conf(SYMBOL_E .. k .. "Append", attribute.label(k) .. "附着")
    attribute.conf(SYMBOL_EI .. k, attribute.label(k) .. "免疫")
end
for _, v in ipairs(ATTR_ODDS) do
    local k = string.replace(v, SYMBOL_E, '')
    attribute.conf(SYMBOL_ODD .. v, attribute.label(k) .. '几率', '%')
end
for _, v in ipairs(ATTR_RESISTANCE) do
    local k = string.replace(v, SYMBOL_E, '')
    attribute.conf(SYMBOL_RES .. v, attribute.label(k) .. '抗性', '%')
end

-- 定义智能属性描述体
-- [基础信息]
---@param this Ability|Item
---@param options {level:number}
Game():defineDescription("attributes", function(this, options)
    if (type(this.attributes) ~= "function") then
        return nil
    end
    local attributes = this:attributes()
    if (type(attributes) ~= "table" or #attributes == 0) then
        return nil
    end
    local desc = {}
    local lv = math.floor(options.level or this:level())
    for _, a in ipairs(attributes) do
        local method = a[1]
        local m2 = a[2] or 0
        local d1
        local d2
        if (type(m2) == "number") then
            d1 = m2
            d2 = a[3] or d1
        elseif (type(m2) == "string") then
            method = method .. '_' .. m2
            d1 = a[3] or 0
            d2 = a[4] or d1
        end
        local label = attribute.conf(method)
        if (label ~= nil) then
            local v = d1
            if (lv > 1) then
                v = v + (lv - 1) * d2
            end
            table.insert(desc, attribute.format(method, v))
        end
    end
    return desc
end)
```
