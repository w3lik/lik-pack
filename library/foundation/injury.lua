---@class injury 受伤
injury = injury or {}

---@param sourceUnit Unit
---@param targetUnit Unit
---@return void
function injury.arriveUnit(sourceUnit, targetUnit)
    if (isClass(sourceUnit, UnitClass) == false or isClass(targetUnit, UnitClass) == false) then
        return
    end
    if (sourceUnit:isDead() or targetUnit:isDead()) then
        return
    end
    if (sourceUnit:weaponSoundMode() == 1) then
        audio(Vwp(sourceUnit, targetUnit))
    end
    local dmg = sourceUnit:attack() + math.rand(0, sourceUnit:attackRipple())
    if (dmg >= 1) then
        local am = sourceUnit:attackMode()
        local dt, dtl
        if (isClass(am, AttackModeClass)) then
            dt = am:damageType()
            dtl = am:damageTypeLevel()
        end
        ability.damage({
            sourceUnit = sourceUnit,
            targetUnit = targetUnit,
            damage = dmg,
            damageSrc = DAMAGE_SRC.attack,
            damageType = dt,
            damageTypeLevel = dtl,
        })
    end
end

---@param sourceUnit Unit
---@param targetUnit Unit
---@return void
function injury.attackUnit(sourceUnit, targetUnit)
    if (isClass(sourceUnit, UnitClass) == false or isClass(targetUnit, UnitClass) == false) then
        return
    end
    if (sourceUnit:isDead() or targetUnit:isDead()) then
        return
    end
    if (sourceUnit:isMelee()) then
        injury.arriveUnit(sourceUnit, targetUnit)
    else
        local am = sourceUnit:attackMode()
        if (isClass(am, AttackModeClass)) then
            local mode = am:mode()
            if (mode == "lightning") then
                local lDur = 0.3
                local lDelay = lDur * 0.6
                local focus = am:focus()
                if (focus < 1) then
                    focus = 1
                end
                local x1, y1, z1 = sourceUnit:x(), sourceUnit:y(), sourceUnit:h() + sourceUnit:weaponHeight()
                local x2, y2, z2 = targetUnit:x(), targetUnit:y(), targetUnit:h() + targetUnit:stature() / 2 + math.rand(30, 70)
                x1, y1 = vector2.polar(x1, y1, sourceUnit:weaponLength(), vector2.angle(x1, y1, x2, y2))
                for _ = 1, focus do
                    lightning(am:lightningType(), x1, y1, z1, x2, y2, z2, lDur)
                    time.setTimeout(lDelay, function()
                        injury.arriveUnit(sourceUnit, targetUnit)
                    end)
                end
                if (am:scatter() > 0 and am:radius() > 0) then
                    Group():forEach(UnitClass, {
                        limit = am:scatter(),
                        circle = {
                            x = targetUnit:x(),
                            y = targetUnit:y(),
                            radius = am:radius(),
                        },
                        filter = function(enumUnit)
                            return enumUnit:isOther(targetUnit) and enumUnit:isAlive() and enumUnit:isEnemy(sourceUnit:owner())
                        end
                    }, function(enumUnit)
                        x1, y1, z1 = sourceUnit:x(), sourceUnit:y(), sourceUnit:h() + sourceUnit:weaponHeight()
                        x2, y2, z2 = enumUnit:x(), enumUnit:y(), enumUnit:h() + targetUnit:stature() / 2 + math.rand(30, 70)
                        x1, y1 = vector2.polar(x1, y1, sourceUnit:weaponLength(), vector2.angle(x1, y1, x2, y2))
                        lightning(am:lightningType(), x1, y1, z1, x2, y2, z2, lDur)
                        time.setTimeout(lDelay, function()
                            injury.arriveUnit(sourceUnit, enumUnit)
                        end)
                    end)
                end
            elseif (mode == "missile") then
                local gatlin = am:gatlin()
                local options = {
                    modelAlias = am:missileModel(),
                    scale = sourceUnit:modelScale(),
                    sourceUnit = sourceUnit,
                    targetUnit = targetUnit,
                    scale = am:scale(),
                    speed = am:speed(),
                    height = am:height(),
                    weaponHeight = sourceUnit:weaponHeight(),
                    weaponLength = sourceUnit:weaponLength(),
                    acceleration = am:acceleration(),
                    shake = am:shake(),
                    reflex = am:reflex(),
                    onEnd = function(opt, vec)
                        if (vector2.distance(vec[1], vec[2], opt.targetUnit:x(), opt.targetUnit:y()) <= 100) then
                            injury.arriveUnit(opt.sourceUnit, opt.targetUnit)
                            return true
                        end
                        return false
                    end,
                }
                if (false == am:homing()) then
                    options.targetVec = { targetUnit:x(), targetUnit:y(), targetUnit:h() + targetUnit:stature() / 2 + math.rand(30, 70) }
                end
                ability.missile(options)
                if (gatlin > 0) then
                    time.setInterval(0.25, function(gatlinTimer)
                        if (gatlin <= 0
                            or false == isClass(sourceUnit, UnitClass) or sourceUnit:isDead()
                            or false == isClass(targetUnit, UnitClass) or targetUnit:isDead()) then
                            destroy(gatlinTimer)
                            return
                        end
                        gatlin = gatlin - 1
                        local gatlinOptions = {
                            modelAlias = options.modelAlias,
                            scale = options.scale,
                            sourceUnit = sourceUnit,
                            targetUnit = targetUnit,
                            scale = options.scale,
                            speed = options.speed,
                            height = options.height,
                            weaponHeight = options.weaponHeight,
                            weaponLength = options.weaponLength,
                            acceleration = options.acceleration,
                            shake = options.shake,
                            reflex = options.reflex,
                            onEnd = options.onEnd,
                        }
                        if (false == am:homing()) then
                            gatlinOptions.targetVec = { targetUnit:x(), targetUnit:y(), targetUnit:h() + targetUnit:stature() / 2 + math.rand(30, 70) }
                        end
                        ability.missile(gatlinOptions)
                    end)
                end
                if (am:scatter() > 0 and am:radius() > 0) then
                    Group():forEach(UnitClass, {
                        limit = am:scatter(),
                        circle = {
                            x = targetUnit:x(),
                            y = targetUnit:y(),
                            radius = am:radius(),
                        },
                        filter = function(enumUnit)
                            return enumUnit:isOther(targetUnit) and enumUnit:isAlive() and enumUnit:isEnemy(sourceUnit:owner())
                        end
                    }, function(enumUnit)
                        local scatterOptions = {
                            modelAlias = options.modelAlias,
                            scale = options.scale,
                            sourceUnit = sourceUnit,
                            targetUnit = enumUnit,
                            scale = options.scale,
                            height = options.height,
                            speed = options.speed,
                            acceleration = options.acceleration,
                            shake = options.shake,
                            reflex = options.reflex,
                            onEnd = options.onEnd,
                        }
                        if (false == am:homing()) then
                            scatterOptions.targetVec = { enumUnit:x(), enumUnit:y(), enumUnit:h() + enumUnit:stature() / 2 + math.rand(30, 70) }
                        end
                        ability.missile(scatterOptions)
                    end)
                end
            end
        end
    end
end

---@param sourceUnit Unit
---@param targetItem Item
---@return void
function injury.arriveItem(sourceUnit, targetItem)
    if (isClass(sourceUnit, UnitClass) == false or isClass(targetItem, ItemClass) == false) then
        return
    end
    if (sourceUnit:weaponSoundMode() == 1) then
        audio(Vwp(sourceUnit, targetItem))
    end
    local dmg = sourceUnit:attack() + math.rand(0, sourceUnit:attackRipple())
    if (dmg >= 1) then
        targetItem:lastHurtSource(sourceUnit)
        event.syncTrigger(targetItem, EVENT.Item.Be.Attack, { sourceUnit = sourceUnit, damage = dmg })
        targetItem:hpCur("-=" .. dmg)
    end
end

---@param sourceUnit Unit
---@param targetItem Item
---@return void
function injury.attackItem(sourceUnit, targetItem)
    if (isClass(sourceUnit, UnitClass) == false or isClass(targetItem, ItemClass) == false) then
        return
    end
    if (sourceUnit:isMelee()) then
        injury.arriveItem(sourceUnit, targetItem)
    else
        local am = sourceUnit:attackMode()
        if (isClass(am, AttackModeClass)) then
            local mode = am:mode()
            if (mode == "lightning") then
                local lDur = 0.3
                local lDelay = lDur * 0.6
                local focus = am:focus()
                if (focus < 1) then
                    focus = 1
                end
                local x1, y1, z1 = sourceUnit:x(), sourceUnit:y(), sourceUnit:h() + sourceUnit:weaponHeight()
                local x2, y2, z2 = targetItem:x(), targetItem:y(), targetItem:z() + 30
                x1, y1 = vector2.polar(x1, y1, sourceUnit:weaponLength(), vector2.angle(x1, y1, x2, y2))
                for _ = 1, focus do
                    lightning(am:lightningType(), x1, y1, z1, x2, y2, z2, lDur)
                    time.setTimeout(lDelay, function()
                        injury.arriveItem(sourceUnit, targetItem)
                    end)
                end
            elseif (mode == "missile") then
                local x, y, z = targetItem:x(), targetItem:y(), targetItem:z() + 30
                local options = {
                    modelAlias = am:missileModel(),
                    scale = sourceUnit:modelScale(),
                    sourceUnit = sourceUnit,
                    targetVec = { x, y, z },
                    scale = am:scale(),
                    speed = am:speed(),
                    height = am:height(),
                    acceleration = am:acceleration(),
                    shake = am:shake(),
                    reflex = am:reflex(),
                    onEnd = function(opt, vec)
                        if (vector2.distance(vec[1], vec[2], x, y) <= 100) then
                            injury.arriveItem(opt.sourceUnit, targetItem)
                            return true
                        end
                        return false
                    end,
                }
                ability.missile(options)
            end
        end
    end
end

---@param deadUnit Unit
function injury.killUnit(deadUnit)
    if (isClass(deadUnit, UnitClass) == false) then
        return
    end
    local x, y = deadUnit:x(), deadUnit:y()
    deadUnit:superposition("dead", "+=1")
    --- 触发击杀事件
    local killer = deadUnit:lastHurtSource()
    if (isClass(killer, UnitClass)) then
        event.syncTrigger(killer, EVENT.Unit.Kill, { targetUnit = deadUnit })
    end
    -- 复活判断
    local rebornDelay = deadUnit:reborn()
    if (rebornDelay < 0) then
        --- 触发死亡事件
        event.syncTrigger(deadUnit, EVENT.Unit.Dead, { sourceUnit = killer })
        destroy(deadUnit, deadUnit:corpse())
    else
        --- 触发假死事件
        event.syncTrigger(deadUnit, EVENT.Unit.FeignDead, { sourceUnit = killer })
        deadUnit:buffClear()
        enchant.clear(deadUnit)
        ability.reborn(deadUnit, rebornDelay, deadUnit:rebornInvulnerable(), x, y, true)
    end
end

---@param deadItem Item
function injury.killItem(deadItem)
    if (isClass(deadItem, ItemClass) == false) then
        return
    end
    deadItem:superposition("dead", "+=1")
    --- 触发死亡事件
    event.syncTrigger(deadItem, EVENT.Item.Dead, { sourceUnit = deadItem:lastHurtSource() })
    J.PauseUnit(deadItem:handle(), true)
    J.ShowUnit(deadItem:handle(), false)
    destroy(deadItem)
end