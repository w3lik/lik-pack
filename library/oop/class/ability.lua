---@class AbilityClass:AbilityFuncClass
local class = Class(AbilityClass):extend(AbilityFuncClass)

---@private
function class:construct(options)
    options.tpl:cover(self)
    self:prop("tpl", options.tpl)
    self:prop("prohibit", Array())
    self:prop("exp", 0)
    --- TPL事件注册
    if (type(self:prop("onEvent")) == "table") then
        for _, e in ipairs(self:prop("onEvent")) do
            event.syncRegister(self, table.unpack(e))
        end
        self:clear("onEvent")
    end
    --- TPL单位事件注册
    if (type(self:prop("onUnitEvent")) == "table") then
        for _, e in ipairs(self:prop("onUnitEvent")) do
            self:onUnitEvent(table.unpack(e))
        end
        self:clear("onUnitEvent")
    end
end

---@private
function class:destruct()
    ---@type Unit
    local bindUnit = self:bindUnit()
    if (isClass(bindUnit, UnitClass)) then
        local slot = bindUnit:abilitySlot()
        if (isClass(slot, AbilitySlotClass)) then
            slot:remove(self:abilitySlotIndex())
        end
    end
    self:clear("prohibit", true)
    self:clear("abilitySlotIndex")
    self:clear("bindUnit")
    self:clear("bindItem")
end

--- 技能TPL
---@return AbilityTpl
function class:tpl()
    return self:prop("tpl")
end

--- 通用型单位事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onUnitEvent(evt, ...)
    local opt = { ... }
    local key
    local callFunc
    if (type(opt[1]) == "function") then
        key = self:id() .. evt
        callFunc = opt[1]
    elseif (type(opt[1]) == "string" and type(opt[2]) == "function") then
        key = self:id() .. evt .. opt[1]
        callFunc = opt[2]
    end
    if (key ~= nil) then
        local eKey = "aoue#" .. key
        if (callFunc == nil) then
            event.syncUnregister(self, EVENT.Ability.Get, eKey)
            event.syncUnregister(self, EVENT.Ability.Lose, eKey)
        else
            ---@param getData noteOnAbilityGetData
            self:onEvent(EVENT.Ability.Get, eKey, function(getData)
                event.syncRegister(getData.triggerUnit, evt, eKey, function(callData)
                    callData.triggerAbility = getData.triggerAbility
                    callFunc(callData)
                end)
            end)
            ---@param loseData noteOnAbilityLoseData
            self:onEvent(EVENT.Ability.Lose, eKey, function(loseData)
                event.syncUnregister(loseData.triggerUnit, evt, eKey)
            end)
        end
    end
    return self
end

--- 当前技能栏位置
---@param modify number|nil
---@return self|number|nil
function class:abilitySlotIndex(modify)
    return self:prop("abilitySlotIndex", modify)
end

--- 当前热键字符串
---@return string|nil
function class:hotkey()
    return self:prop("hotkey")
end

--- 当前绑定单位
---@param modify Unit|nil
---@return self|Unit
function class:bindUnit(modify)
    return self:prop("bindUnit", modify)
end

--- 当前绑定物品
---@param modify Item|nil
---@return self|Item
function class:bindItem(modify)
    return self:prop("bindItem", modify)
end

--- 冷却时间计时器对象
---@return Timer|nil
function class:coolDownTimer()
    return self:prop("coolDownTimer")
end

--- 冷却时间剩余时间
---@return number
function class:coolDownRemain()
    ---@type Timer
    local t = self:prop("coolDownTimer")
    if (isClass(t, TimerClass)) then
        return t:remain()
    end
    return 0
end

--- 技能不能使用的原因
---@return string|nil
function class:prohibitReason()
    local bu = self:bindUnit()
    if (isClass(bu, UnitClass)) then
        if (bu:isAbilityChantCasting()) then
            return "吟唱中"
        end
        if (bu:isAbilityKeepCasting()) then
            return "施法中"
        end
    end
    if (self:isCooling()) then
        return "冷却中"
    end
    local advRe
    local costAdv = self:prop("costAdv")
    if (isClass(costAdv, ArrayClass)) then
        costAdv:forEach(function(k, v)
            if (true ~= v.cond(self)) then
                advRe = v.reason or (string.upper(k) .. "不足")
                return false
            end
        end)
    end
    if (advRe ~= nil) then
        return advRe
    end
    if (isClass(bu, UnitClass)) then
        if (bu:isStunning()) then
            return "被眩晕"
        end
        if (bu:isSilencing()) then
            return "被沉默"
        end
    end
end

--- 技能当前经验
---@param modify number|nil
---@return self|number
function class:exp(modify)
    if (modify ~= nil) then
        if (self:level() > 1 and self:prop("exp") <= 0) then
            -- 技能等级提前提升过，则补回之前的升级经验，当作是早已获取
            self:prop("exp", Game():abilityExpNeeds(self:level()))
        end
    end
    return self:prop("exp", modify)
end

--- 获取技能升级到某等级需要的总经验；根据Game的abilityExpNeeds
---@param whichLevel number
---@return number
function class:expNeed(whichLevel)
    whichLevel = whichLevel or (1 + self:level())
    whichLevel = math.max(1, whichLevel)
    whichLevel = math.min(Game():abilityLevelMax(), whichLevel)
    return Game():abilityExpNeeds(math.floor(whichLevel))
end

--- 进入冷却
---@return void
function class:coolingEnter()
    local cd = self:coolDown()
    if (cd > 0) then
        local coolDownTimer = self:prop("coolDownTimer")
        if (isClass(coolDownTimer, TimerClass)) then
            self:clear("coolDownTimer", true)
        end
        self:prop("coolDownTimer", time.setTimeout(cd, function()
            self:clear("coolDownTimer")
        end))
    end
end

--- 瞬间冷却
---@return void
function class:coolingInstant()
    local t = self:coolDownTimer()
    if (isClass(t, TimerClass) and t:remain() > 0) then
        t:remain(0)
    end
end

--- 是否冷却中
---@return boolean
function class:isCooling()
    local t = self:coolDownTimer()
    return isClass(t, TimerClass) and t:remain() > 0
end

--- 技能是否处于禁用状态
---@return boolean
function class:isProhibiting()
    local br = self:prohibitReason()
    return type(br) == "string"
end

--- 是否施法目标允许
---@param targetObj nil|Unit
---@return boolean
function class:isCastTarget(targetObj)
    local tt = self:targetType()
    if (tt == ABILITY_TARGET_TYPE.tag_unit and isClass(targetObj, UnitClass) == false) then
        return false
    end
    local cta = self:prop("castTargetFilter")
    if (cta == nil or type(cta) ~= "function") then
        return false
    end
    return cta(self, targetObj)
end

--- 技能起效
---@see targetUnit 对单位时存在
---@see targetX 对单位、点、范围时存在
---@see targetY 对单位、点、范围时存在
---@see targetZ 对单位、点、范围时存在
---@alias noteAbilitySpellEvt {triggerUnit:Unit,targetUnit:Unit,targetX:number,targetY:number,targetZ:number}
---@param evtData noteAbilitySpellEvt
---@return void
function class:effective(evtData)
    sync.must()
    evtData = evtData or {}
    local triggerUnit = evtData.triggerUnit or self:bindUnit()
    if (isClass(triggerUnit, UnitClass) == false) then
        return
    end
    local tt = self:targetType()
    if (tt == ABILITY_TARGET_TYPE.tag_unit and isClass(evtData.targetUnit, UnitClass)) then
        if (self:isCastTarget(evtData.targetUnit) == false) then
            return
        end
    end
    if (self:isProhibiting() == true or triggerUnit:isInterrupt() or triggerUnit:isPause()) then
        return
    end
    local triggerOwner = triggerUnit:owner()
    if (tt ~= ABILITY_TARGET_TYPE.pas) then
        async.call(triggerOwner, function()
            cursor.quoteOver()
        end)
    end
    evtData.triggerAbility = self
    evtData.triggerUnit = triggerUnit
    if (evtData.targetX == nil or evtData.targetY == nil or evtData.targetZ == nil) then
        if (isClass(evtData.targetUnit, UnitClass)) then
            evtData.targetX = evtData.targetUnit:x()
            evtData.targetY = evtData.targetUnit:y()
            evtData.targetZ = evtData.targetUnit:z()
        end
    end
    if (type(evtData.targetX) == "number" and type(evtData.targetY) == "number" and evtData.targetZ == nil) then
        evtData.targetZ = japi.Z(evtData.targetX, evtData.targetY)
    end
    if (tt == ABILITY_TARGET_TYPE.pas or tt == ABILITY_TARGET_TYPE.tag_nil) then
        ability.effective(self, evtData)
    else
        --- 非无视距离类型需要进行距离判断
        local castDistance = self:castDistance()
        local distTarget
        if (isClass(evtData.targetUnit, UnitClass)) then
            distTarget = evtData.targetUnit
        elseif (evtData.targetX and evtData.targetY) then
            distTarget = { evtData.targetX, evtData.targetY }
        else
            distTarget = triggerUnit
        end
        player._unitDistanceAction(triggerUnit, distTarget, castDistance, function()
            ability.effective(self, evtData)
        end)
    end
end
