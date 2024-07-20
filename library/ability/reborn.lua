--- 复活回调
---@param whichUnit Unit
---@param invulnerable number
function ability.rebornRevive(whichUnit, invulnerable, x, y, eff)
    if (isClass(whichUnit, UnitClass) == false) then
        return
    end
    whichUnit:superposition("dead", "-=1")
    href(whichUnit, J.CreateUnit(whichUnit:owner():handle(), whichUnit:modelId(), x, y, 270))
    local hp = math.max(1, whichUnit:hp() * 0.01 * whichUnit:rebornHP())
    local mp = math.max(whichUnit:mp(), whichUnit:mp() * 0.01 * whichUnit:rebornMP())
    whichUnit:prop("hpCur", hp)
    whichUnit:prop("mpCur", mp)
    whichUnit:restruct()
    whichUnit:attach(eff, "origin", 3)
    if (invulnerable > 0) then
        ability.invulnerable({
            whichUnit = whichUnit,
            duration = invulnerable,
        })
    end
    --- 触发复活事件
    event.syncTrigger(whichUnit, EVENT.Unit.Reborn)
end

--- 重生
--- 使用 Unit:isAlive() 判断是否存活中
--- 使用 Unit:isDead() 判断是否已死亡
---@param whichUnit Unit
---@param delay number|0
---@param invulnerable number 复活后的无敌时间
---@param x number 在哪复活X
---@param y number 在哪复活Y
---@return Timer|nil
function ability.reborn(whichUnit, delay, invulnerable, x, y)
    if (isClass(whichUnit, UnitClass) == false) then
        return
    end
    local rebornTimer
    if (delay < 1) then
        delay = math.max(0.2, delay)
        time.setTimeout(delay, function()
            ability.rebornRevive(whichUnit, invulnerable, x, y, "DispelMagicTarget")
        end)
    else
        whichUnit:owner():mark(TEXTURE_MARK.dream, delay, 255, 0, 0)
        --- 复活标志
        local ux, uy = whichUnit:x(), whichUnit:y()
        local unitGhost = J.CreateUnit(PlayerPassive:handle(), whichUnit:modelId(), ux, uy, 270)
        J.HandleRef(unitGhost)
        J.SetUnitVertexColor(unitGhost, 255, 255, 255, 100)
        J.SetUnitScale(unitGhost, whichUnit:modelScale() * 0.9, whichUnit:modelScale() * 0.9, whichUnit:modelScale() * 0.9)
        J.SetUnitColor(unitGhost, PLAYER_COLOR[whichUnit:owner():index()])
        J.SetUnitPathing(unitGhost, false)
        J.UnitAddAbility(unitGhost, FRAMEWORK_ID["ability_fly"])
        J.UnitRemoveAbility(unitGhost, FRAMEWORK_ID["ability_fly"])
        J.SetUnitFlyHeight(unitGhost, 40, 9999)
        J.SetUnitFacing(unitGhost, 270)
        J.UnitAddAbility(unitGhost, FRAMEWORK_ID["ability_locust"])
        J.UnitAddAbility(unitGhost, FRAMEWORK_ID["ability_invulnerable"])
        local deathToken = J.CreateUnit(PlayerPassive:handle(), FRAMEWORK_ID["unit_token_reborn"], ux, uy, 270)
        J.HandleRef(deathToken)
        J.SetUnitVertexColor(deathToken, 255, 255, 255, 180)
        J.SetUnitScale(deathToken, whichUnit:modelScale() * 0.75, whichUnit:modelScale() * 0.75, whichUnit:modelScale() * 0.75)
        J.SetUnitTimeScale(deathToken, 10 / delay)
        rebornTimer = time.setTimeout(delay, function()
            J.RemoveUnit(deathToken)
            J.HandleUnRef(deathToken)
            J.RemoveUnit(unitGhost)
            J.HandleUnRef(unitGhost)
            ability.rebornRevive(whichUnit, invulnerable, x, y, "ResurrectTarget")
        end)
    end
    return rebornTimer
end