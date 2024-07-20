### 事件反应

> 用于增添事件发生时的效果补充，可自定义

```lua
-- prop事件捕捉
event.confPropChange({
    [UnitClass] = "any",
    [GameClass] = {
        i18nLang = true,
        infoCenter = true,
        playingQuantity = true,
    },
    [PlayerClass] = {
        i18nLang = true,
        skin = true,
        name = true,
        alert = true,
        selection = true,
    },
})

-- 事件反应
---@param u Unit
local function _z(u, offset)
    return u:h() + 130 + offset
end

---@param evtData noteOnUnitKillData
event.registerReaction(EVENT.Unit.Kill, function(evtData)
    local owner = evtData.targetUnit:owner()
    if (owner:selection() == evtData.targetUnit) then
        owner:prop("selection", evtData.triggerUnit)
    end
end)
---@param evtData noteOnUnitCritData
event.registerReaction(EVENT.Unit.Crit, function(evtData)
    evtData.targetUnit:attach("lik_crit", "origin", 0.5)
end)
---@param evtData noteOnUnitCritAbilityData
event.registerReaction(EVENT.Unit.CritAbility, function(evtData)
    evtData.targetUnit:attach("lik_crit_ability", "origin", 0.5)
    ttg.model({
        model = "lik_ttg_crit",
        size = 1.4,
        x = evtData.targetUnit:x(),
        y = evtData.targetUnit:y(),
        z = _z(evtData.targetUnit, -24),
        height = 50,
        speed = 0.5,
        duration = 0.8,
    })
end)
---@param evtData noteOnUnitAvoidData
event.registerReaction(EVENT.Unit.Avoid, function(evtData)
    evtData.triggerUnit:attach("lik_ttg_avoid", "overhead", 0.3)
end)
---@param evtData noteOnUnitImmuneInvincibleData
event.registerReaction(EVENT.Unit.ImmuneInvincible, function(evtData)
    evtData.triggerUnit:attach("DivineShieldTarget", "origin", 1)
    ttg.model({
        model = "lik_ttg_immune_invincible",
        size = 1.2,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData noteOnUnitImmuneDefendData
event.registerReaction(EVENT.Unit.ImmuneDefend, function(evtData)
    ttg.model({
        model = "lik_ttg_immune_damage",
        size = 0.7,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData noteOnUnitImmuneReductionData
event.registerReaction(EVENT.Unit.ImmuneReduction, function(evtData)
    ttg.model({
        model = "lik_ttg_immune_damage",
        size = 0.7,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData noteOnUnitImmuneEnchantData
event.registerReaction(EVENT.Unit.ImmuneEnchant, function(evtData)
    ttg.model({
        model = "lik_ttg_immune_enchant",
        size = 0.7,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData noteOnUnitHPSuckAttackData
event.registerReaction(EVENT.Unit.HPSuckAttack, function(evtData)
    evtData.triggerUnit:attach("HealTarget2", "origin", 0.5)
end)
---@param evtData noteOnUnitHPSuckAbilityData
event.registerReaction(EVENT.Unit.HPSuckAbility, function(evtData)
    evtData.triggerUnit:attach("HealTarget2", "origin", 0.5)
end)
---@param evtData noteOnUnitMPSuckAttackData
event.registerReaction(EVENT.Unit.MPSuckAttack, function(evtData)
    evtData.triggerUnit:attach("AImaTarget", "origin", 0.5)
end)
---@param evtData noteOnUnitMPSuckAbilityData
event.registerReaction(EVENT.Unit.MPSuckAbility, function(evtData)
    evtData.triggerUnit:attach("AImaTarget", "origin", 0.5)
end)
---@param evtData noteOnUnitBeStunData
event.registerReaction(EVENT.Unit.Be.Stun, function(evtData)
    evtData.triggerUnit:attach("ThunderclapTarget", "overhead", evtData.duration)
end)
---@param evtData noteOnUnitBeSplitData
event.registerReaction(EVENT.Unit.Be.Split, function(evtData)
    evtData.triggerUnit:effect("SpellBreakerAttack")
end)
---@param evtData noteOnUnitBeSplitSpreadData
event.registerReaction(EVENT.Unit.Be.SplitSpread, function(evtData)
    evtData.triggerUnit:effect("CleaveDamageTarget")
end)
---@param evtData noteOnUnitBeShieldData
event.registerReaction(EVENT.Unit.Be.Shield, function(evtData)
    local u = evtData.triggerUnit
    ttg.word({
        style = "default",
        str = math.format(evtData.value, 0),
        width = 7.5,
        size = 0.45,
        x = u:x(),
        y = u:y(),
        z = _z(u, 0),
        height = 150,
        duration = 0.6,
    })
end)
---@param evtData noteOnUnitHurtData
event.registerReaction(EVENT.Unit.Hurt, function(evtData)
    local str = math.format(evtData.damage, 0)
    local height = -50
    if (evtData.crit == true) then
        str = 'C' .. str
        height = 300
    end
    local u = evtData.triggerUnit
    ttg.word({
        style = "default",
        str = str,
        width = 12,
        size = 0.7,
        x = u:x(),
        y = u:y(),
        z = _z(u, 0),
        height = height,
        duration = 0.7,
    })
end)
---@param evtData noteOnUnitEnchantData
event.registerReaction(EVENT.Unit.Enchant, function(evtData)
    local m = {
        [DAMAGE_TYPE.fire.value] = "lik_ttg_e_fire",
        [DAMAGE_TYPE.water.value] = "lik_ttg_e_water",
        [DAMAGE_TYPE.ice.value] = "lik_ttg_e_ice",
        [DAMAGE_TYPE.rock.value] = "lik_ttg_e_rock",
        [DAMAGE_TYPE.wind.value] = "lik_ttg_e_wind",
        [DAMAGE_TYPE.light.value] = "lik_ttg_e_light",
        [DAMAGE_TYPE.dark.value] = "lik_ttg_e_dark",
        [DAMAGE_TYPE.grass.value] = "lik_ttg_e_grass",
        [DAMAGE_TYPE.thunder.value] = "lik_ttg_e_thunder",
        [DAMAGE_TYPE.poison.value] = "lik_ttg_e_poison",
        [DAMAGE_TYPE.steel.value] = "lik_ttg_e_steel",
    }
    if (m[evtData.enchantType.value] ~= nil) then
        local u = evtData.triggerUnit
        ttg.model({
            model = m[evtData.enchantType.value],
            size = 1.2,
            x = u:x() - math.rand(30, -30),
            y = u:y(),
            z = _z(u, -u:stature() * 2),
            height = 160,
            speed = 0.4,
            duration = 1,
        })
    end
end)
```
