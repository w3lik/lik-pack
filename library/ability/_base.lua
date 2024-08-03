--[[
    ability 技能模组
    一些技能通用的技能计算方法规则函数
    一些技能通用的执行过程
    用于Ability或单独调用
]]

---@alias noteAbilityBuff {name:string,icon:string,description:string[]}
ability = ability or {}

--- [实际]计算整合数值型
---@param obj Ability
---@param whichLevel number|nil
---@param key string
---@param percent string|nil
---@param fixed string|nil
---@return number
function ability.caleValueNumber(obj, whichLevel, key, percent, fixed)
    whichLevel = whichLevel or obj:level()
    local base = key .. "Base"
    local vary = key .. "Vary"
    local val = (obj:prop(base) or 0) + (whichLevel - 1) * (obj:prop(vary) or 0)
    ---@type Unit
    local u = obj:prop("bindUnit")
    if (isClass(u, UnitClass)) then
        if (percent) then
            local p = u:prop(percent)
            if (type(p) == "number") then
                val = val * (1 + 0.01 * p)
            end
        end
        if (fixed) then
            local f = u:prop(fixed)
            if (type(f) == "number") then
                val = val + f
            end
        end
    end
    return val
end

--- [实际]计算整合数资源型
---@param obj Ability
---@param whichLevel number|nil
---@param percent string|nil
---@return number
function ability.caleValueWorth(obj, whichLevel, percent)
    local base = obj:prop("worthCostBase")
    if (base == nil) then
        return
    end
    whichLevel = whichLevel or obj:level()
    local worthKeys = Game():worth():keys()
    local val = {}
    local vary
    if (whichLevel > 1) then
        vary = obj:prop("worthCostVary")
    end
    for _, k in ipairs(worthKeys) do
        if (type(base[k]) == "number" and base[k] ~= 0) then
            val[k] = base[k]
        end
        if (type(vary) == "table" and type(vary[k]) == "number" and vary[k] ~= 0) then
            val[k] = (val[k] or 0) + (whichLevel - 1) * vary[k]
        end
    end
    ---@type Unit
    local u = obj:prop("bindUnit")
    if (isClass(u, UnitClass)) then
        if (percent) then
            local p = u:prop(percent)
            if (type(p) == "number") then
                val = Game():worthCale(val, "*", 1 + 0.01 * p)
            end
        end
        local fixed = u:costWorth()
        if (fixed ~= nil) then
            val = Game():worthCale(val, "+", fixed)
        end
    end
    return val
end

--- [实际]HP
---@param obj Ability
---@return void
function ability.hpCostValue(obj, whichLevel)
    local val = ability.caleValueNumber(obj, whichLevel, "hpCost", "costPercent", "cost")
    return math.ceil(math.max(0, val))
end

--- [条件]HP
---@param obj Ability
---@return boolean
function ability.hpCostCond(obj)
    local val = ability.hpCostValue(obj)
    return not (val > 0 and val >= obj:bindUnit():hpCur())
end

--- [实消]HP
---@param obj Ability
---@return void
function ability.hpCostDeplete(obj)
    local val = ability.hpCostValue(obj)
    obj:bindUnit():hpCur("-=" .. val)
end

--- [实际]MP
---@param obj Ability
---@return void
function ability.mpCostValue(obj, whichLevel)
    local val = ability.caleValueNumber(obj, whichLevel, "mpCost", "costPercent", "cost")
    return math.ceil(math.max(0, val))
end

--- [条件]MP
---@param obj Ability
---@return boolean
function ability.mpCostCond(obj)
    local val = ability.mpCostValue(obj)
    return not (val > 0 and val > obj:bindUnit():mpCur())
end

--- [实消]MP
---@param obj Ability
---@return void
function ability.mpCostDeplete(obj)
    local val = ability.mpCostValue(obj)
    obj:bindUnit():mpCur("-=" .. val)
end

--- [实际]资源型
---@param obj Ability
---@return void
function ability.worthCostValue(obj, whichLevel)
    local val = ability.caleValueWorth(obj, whichLevel, "costPercent")
    return Game():worthL2U(val)
end

--- [条件]资源型
---@param obj Ability
---@return boolean
function ability.worthCostCond(obj)
    local val = ability.worthCostValue(obj)
    return not (val ~= nil and Game():worthGreater(val, obj:bindUnit():owner():worth()))
end

--- [实消]资源型
---@param obj Ability
---@return void
function ability.worthCostDeplete(obj)
    local val = ability.worthCostValue(obj)
    obj:bindUnit():owner():worth("-", val)
end

--- casting
---@param whichAbility Ability
---@param triggerUnit Unit
---@param evtData noteAbilitySpellEvt
---@return void
function ability.casting(whichAbility, triggerUnit, evtData)
    local ka = triggerUnit:keepAnimation() or whichAbility:keepAnimation()
    if (ka) then
        triggerUnit:animate(ka)
    end
    event.syncTrigger(whichAbility, EVENT.Ability.Casting, evtData) --触发技能持续每周期做动作时
    event.syncTrigger(triggerUnit, EVENT.Unit.Ability.Casting, evtData) --触发技能持续每周期做动作时
end

--- castStart
---@param whichAbility Ability
---@param triggerUnit Unit
---@param evtData noteAbilitySpellEvt
---@return void
function ability.castStart(whichAbility, triggerUnit, evtData)
    local tt = whichAbility:targetType()
    if (tt == ABILITY_TARGET_TYPE.tag_unit) then
        if (isDestroy(evtData.targetUnit) or evtData.targetUnit:isDead()) then
            return
        end
    end
    whichAbility:coolingEnter()
    event.syncTrigger(whichAbility, EVENT.Ability.Effective, evtData) --触发技能被施放
    event.syncTrigger(triggerUnit, EVENT.Unit.Ability.Effective, evtData) --触发单位施放了技能
    local ck = whichAbility:castKeep()
    if (ck > 0) then
        triggerUnit:superposition("pause", "+=1")
        triggerUnit:prop("abilityCastRevert", function(isInterrupt)
            triggerUnit:clear("abilityCastRevert")
            triggerUnit:clear("abilityKeepTimer", true)
            triggerUnit:superposition("pause", "-=1")
            if (isInterrupt) then
                ability.castStop(whichAbility, triggerUnit, evtData)
            end
        end)
        local ti = 0
        local period = 0.1
        ability.casting(whichAbility, triggerUnit, evtData)
        triggerUnit:prop("abilityKeepTimerInc", ti)
        triggerUnit:prop("abilityKeepTimerEnd", ck / period)
        triggerUnit:prop("abilityKeepTimer", time.setInterval(period, function()
            ti = ti + 1
            triggerUnit:prop("abilityKeepTimerInc", ti)
            if (triggerUnit:isInterrupt()) then
                local revert = triggerUnit:prop("abilityCastRevert")
                if (type(revert) == "function") then
                    revert(true)
                end
            elseif (ti >= triggerUnit:prop("abilityKeepTimerEnd")) then
                local revert = triggerUnit:prop("abilityCastRevert")
                if (type(revert) == "function") then
                    revert(false)
                    event.syncTrigger(whichAbility, EVENT.Ability.Over, evtData) --触发持续技能结束
                    event.syncTrigger(triggerUnit, EVENT.Unit.Ability.Over, evtData) --触发单位持续技能结束
                end
            else
                if (ti % 10 == 0) then
                    ability.casting(whichAbility, triggerUnit, evtData)
                end
            end
        end))
        ---@param interruptInData noteOnAbilityEffectiveData
        triggerUnit:onEvent(EVENT.Unit.InterruptIn, "cast_", function(interruptInData)
            event.syncUnregister(triggerUnit, EVENT.Unit.InterruptIn, "cast_")
            local revert = interruptInData.triggerUnit:prop("abilityCastRevert")
            if (type(revert) == "function") then
                revert(true)
            end
        end)
    end
end

--- castStop
---@param whichAbility Ability
---@param triggerUnit Unit
---@param evtData noteAbilitySpellEvt
---@return void
function ability.castStop(whichAbility, triggerUnit, evtData)
    event.syncTrigger(whichAbility, EVENT.Ability.Stop, evtData) --触发技能被停止
    event.syncTrigger(triggerUnit, EVENT.Unit.Ability.Stop, evtData) --触发单位停止施放技能
end

--- effective
---@param whichAbility Ability
---@param evtData noteAbilitySpellEvt
---@return void
function ability.effective(whichAbility, evtData)
    local costAdv = whichAbility:prop("costAdv")
    local check = true
    if (isClass(costAdv, ArrayClass)) then
        costAdv:forEach(function(_, v)
            if (v.cond(whichAbility) == false) then
                check = false
                return false
            end
        end)
    end
    if (check == false) then
        return
    end
    local tt = whichAbility:targetType()
    if (isClass(costAdv, ArrayClass)) then
        costAdv:forEach(function(_, v)
            v.deplete(whichAbility)
        end)
    end
    local triggerUnit = evtData.triggerUnit
    if (evtData.targetX and evtData.targetY) then
        triggerUnit:facing(vector2.angle(triggerUnit:x(), triggerUnit:y(), evtData.targetX, evtData.targetY))
    end
    local bIt = whichAbility:bindItem()
    if (isClass(bIt, ItemClass)) then
        if (bIt:charges() <= 0 and bIt:consumable()) then
            return
        end
        evtData.triggerItem = bIt
        event.syncTrigger(bIt, EVENT.Item.Used, evtData)
        event.syncTrigger(triggerUnit, EVENT.Unit.Item.Used, evtData)
    end
    event.syncTrigger(whichAbility, EVENT.Ability.Spell, evtData)
    event.syncTrigger(triggerUnit, EVENT.Unit.Ability.Spell, evtData)
    local cc = 0
    if (tt ~= ABILITY_TARGET_TYPE.pas) then
        cc = whichAbility:castChant()
    end
    if (cc > 0) then
        triggerUnit:superposition("pause", "+=1")
        local ca = triggerUnit:castAnimation() or whichAbility:castAnimation()
        if (ca) then
            time.setTimeout(0, function()
                triggerUnit:animate(ca)
            end)
        end
        local animateScale = triggerUnit:animateScale()
        triggerUnit:animateScale(1 / cc)
        triggerUnit:prop("abilityCastRevert", function(isInterrupt)
            triggerUnit:clear("abilityCastRevert")
            triggerUnit:clear("abilityChantTimer", true)
            triggerUnit:animateScale(animateScale)
            triggerUnit:superposition("pause", "-=1")
            if (isInterrupt) then
                ability.castStop(whichAbility, triggerUnit, evtData)
            end
        end)
        triggerUnit:attach(whichAbility:castChantEffect(), "origin", cc)
        triggerUnit:prop("abilityChantTimer", time.setTimeout(cc, function()
            local revert = triggerUnit:prop("abilityCastRevert")
            if (type(revert) == "function") then
                revert(false)
            end
            ability.castStart(whichAbility, triggerUnit, evtData)
        end))
        ---@param interruptInData noteOnAbilityEffectiveData
        triggerUnit:onEvent(EVENT.Unit.InterruptIn, "cast_", function(interruptInData)
            event.syncUnregister(triggerUnit, EVENT.Unit.InterruptIn, "cast_")
            local revert = interruptInData.triggerUnit:prop("abilityCastRevert")
            if (type(revert) == "function") then
                revert(true)
            end
        end)
    else
        ability.castStart(whichAbility, triggerUnit, evtData)
    end
end