### Buff配置

```lua
buff.conf("rgba", "偏色", "ability/HunterBeastWithin")
buff.conf("invisible", "隐身", "ability/Vanish")
buff.conf("split", "分裂", "ability/CleavingAttack")
buff.conf("freeze", "冻结", "ability/HolyWrath")
buff.conf("silent", "沉默", "ability/Silence")
buff.conf("unArm", "缴械", "ability/ShadowCurseOfMannoroth")
buff.conf("breakArmor", "破甲", "ability/ShadowCurseOfSargeras")
buff.conf("lightningChain", "闪电链", "ability/ChainLightning")
buff.conf("leap", "冲锋中", "ability/Sprinter")
buff.conf("crackFly", "被击飞", "ability/Jumpback")
buff.conf("animateScale", nil, "ability/LightWork")
buff.conf("reborn", nil, "ability/HolyHolyGuidance")
buff.conf("hp", nil, "ability/HPRecharge")
buff.conf("hpCur", nil, "ability/HPRecharge")
buff.conf("hpRegen", nil, "ability/ReplenishHealth")
buff.conf("hpSuckAttack", nil, "ability/NatureHealingWay")
buff.conf("hpSuckAbility", nil, "ability/DrainLife")
buff.conf("mp", nil, "ability/ManaRecharge2")
buff.conf("mpCur", nil, "ability/ManaRecharge2")
buff.conf("mpRegen", nil, "ability/ReplenishMana")
buff.conf("mpSuckAttack", nil, "ability/ManaBurn2")
buff.conf("mpSuckAbility", nil, "ability/DrainMana")
buff.conf("move", nil, "ability/RogueFleetFooted")
buff.conf("defend", nil, "ability/ThickFur")
buff.conf("attackSpeed", nil, "ability/DemonhunterBladeDance")
buff.conf("attackSpace", nil, "ability/WarriorWeaponMastery")
buff.conf("attackSpaceBase", nil, "ability/WarriorWeaponMastery")
buff.conf("attack", nil, "ability/CrystalSlash")
buff.conf("attackRange", nil, "ability/HunterLockAndLoad")
buff.conf("attackRangeAcquire", nil, "ability/HunterLockAndLoad")
buff.conf("sight", nil, "ability/SigntDay")
buff.conf("nsight", nil, "ability/SigntNight")
buff.conf("visible", nil, "ability/MagicalSentry")
buff.conf("str", nil, "ability/Strength3")
buff.conf("agi", nil, "ability/RogueQuickRecovery")
buff.conf("int", nil, "ability/DeclarationofGod")
buff.conf("avoid", nil, "ability/Greenphantom")
buff.conf("aim", nil, "ability/DeadlyDoubleLine")
buff.conf("crit", nil, "ability/ShockCut")
buff.conf("stun", nil, "ability/Stun")
buff.conf("invulnerable", nil, "ability/Invulnerable")
buff.conf("cure", nil, "ability/Heal")
buff.conf("enchantMystery", nil, "ability/ElementalSilk")
buff.conf("shield", nil, "ability/HolyBlessingOfProtection")
buff.conf("shieldBack", nil, "ability/HolyBlessingOfProtection")
buff.conf("hurtIncrease", nil, "ability/IronmaidensBloodritual")
buff.conf("hurtReduction", nil, "ability/HolyGreaterBlessingofSanctuary")
buff.conf("hurtRebound", nil, "ability/MageMoltenArmor")
buff.conf("damageIncrease", nil, "ability/LingerSometimesConstantlyKnife")

local ei = {
    dark = "ability/Nightswallow",
    fire = "ability/IncendiaryBonds",
    grass = "ability/SpellLfieblood",
    ice = "ability/Glacier",
    light = "ability/HolyBolt",
    poison = "ability/SummonDemonicGateway",
    rock = "item/MiscQirajiCrystal01",
    steel = "ability/FlameCrystal",
    thunder = "ability/SplitLightning",
    water = "ability/DeathknightFrozencenter",
    wind = "ability/Greenengulfingtornado",
}
for _, k in ipairs(ENCHANT_TYPES) do
    local name = Enchant(k):name()
    buff.conf(k, name, ei[k])
    buff.conf(SYMBOL_E .. k, nil, ei[k])
end
for _, v in ipairs(ATTR_ODDS) do
    local k = string.replace(v, SYMBOL_E, '')
    buff.conf(SYMBOL_ODD .. v, nil, buff.icon(k))
end
for _, v in ipairs(ATTR_RESISTANCE) do
    local k = string.replace(v, SYMBOL_E, '')
    buff.conf(SYMBOL_RES .. v, nil, buff.icon(k))
end
```
