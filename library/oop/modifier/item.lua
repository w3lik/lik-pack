local expander = ClassExpander(CLASS_EXPANDS_MOD, ItemClass)

---@param obj Item
expander["attributes"] = function(obj, prev)
    local data = obj:propData("attributes")
    local eKey = "attributes"
    event.syncUnregister(obj, EVENT.Item.Get, eKey)
    event.syncUnregister(obj, EVENT.Item.Lose, eKey)
    event.syncUnregister(obj, EVENT.Item.LevelChange, eKey)
    if (type(data) == "table") then
        for i = #data, 1, -1 do
            local method = data[i][1]
            local base = data[i][2]
            local vary = data[i][3]
            if (type(method) ~= "string" or (base == nil and vary == nil)) then
                table.remove(data, i)
            end
        end
        if (type(prev) == "table") then
            local u = obj:bindUnit()
            if (isClass(u, UnitClass)) then
                local lv = obj:level()
                attribute.clever(prev, u, lv, -lv)
                attribute.clever(data, u, 0, lv)
            end
        end
        ---@param getData noteOnItemGetData
        obj:onEvent(EVENT.Item.Get, eKey, function(getData)
            attribute.clever(data, getData.triggerUnit, 0, getData.triggerItem:level())
        end)
        ---@param loseData noteOnItemLoseData
        obj:onEvent(EVENT.Item.Lose, eKey, function(loseData)
            attribute.clever(data, loseData.triggerUnit, loseData.triggerItem:level(), -loseData.triggerItem:level())
        end)
        ---@param lvcData noteOnItemLevelChangeData
        obj:onEvent(EVENT.Item.LevelChange, eKey, function(lvcData)
            attribute.clever(data, lvcData.triggerUnit, lvcData.old, lvcData.new - lvcData.old)
        end)
    end
end

---@param obj Item
expander["itemSlotIndex"] = function(obj)
    ---@type string
    local data = obj:propData("itemSlotIndex")
    obj:prop("hotkey", Game():itemHotkey(data))
    local ab = obj:ability()
    if (isClass(ab, AbilityClass)) then
        ab:prop("hotkey", Game():itemHotkey(data))
    end
end

---@param obj Unit
expander["facing"] = function(obj)
    ---@type Player
    local data = obj:propData("facing")
    J.SetUnitFacing(obj:handle(), data)
end

---@param obj Unit
expander["owner"] = function(obj)
    ---@type Player
    local data = obj:propData("owner")
    J.SetUnitOwner(obj:handle(), data:handle(), true)
end

---@param obj Item
expander["ability"] = function(obj)
    ---@type Ability
    local data = obj:propData("ability")
    if (isDestroy(obj) == false and isClass(data, AbilityClass)) then
        data:bindItem(obj)
        local bu = obj:bindUnit()
        if (isClass(bu, UnitClass)) then
            event.syncTrigger(data, EVENT.Ability.Get, { triggerUnit = bu })
            event.syncTrigger(bu, EVENT.Ability.Get, { triggerAbility = data })
        end
    end
end

---@param obj Item
expander["instance"] = function(obj)
    ---@type boolean
    local data = obj:propData("instance")
    local x = obj:x()
    local y = obj:y()
    if (data == true) then
        if (obj:handle() == nil) then
            href(obj, J.CreateUnit(obj:owner():handle(), obj:modelId(), x, y, obj:facing()))
            japi.DZ_SetUnitModel(obj:handle(), assets.model(obj:modelAlias()))
            japi.YD_SetUnitMoveType(obj:handle(), MOVE_TYPE_NONE)
            Group():insert(obj)
        end
    else
        if (obj:handle() ~= nil) then
            Group():remove(obj)
            href(obj, nil)
            datum.freePosition(x, y)
            obj:clear("x")
            obj:clear("y")
        end
    end
    obj:cls()
end

---@param obj Item
expander["modelAlias"] = function(obj)
    if (obj:handle() ~= nil) then
        ---@type string
        local data = obj:propData("modelAlias")
        data = assets.model(data)
        must(type(data) == "string")
        japi.DZ_SetUnitModel(obj:handle(), data)
    end
end

---@param obj Item
expander["modelScale"] = function(obj)
    if (obj:handle() ~= nil) then
        ---@type number
        local data = obj:propData("modelScale")
        J.SetUnitScale(obj:handle(), data, data, data)
    end
end

---@param obj Item
expander["animateScale"] = function(obj)
    if (obj:handle() ~= nil) then
        ---@type number
        local data = obj:propData("animateScale")
        J.SetUnitTimeScale(obj:handle(), data)
    end
end

---@param obj Item
expander["duration"] = function(obj)
    if (isClass(obj:prop("durationTimer"), TimerClass)) then
        obj:clear("durationTimer", true)
    end
    ---@type number
    local data = obj:propData("duration")
    if (data > 0) then
        obj:prop("durationTimer", time.setTimeout(data, function()
            destroy(obj)
        end))
    end
end

---@param obj Item
expander["period"] = function(obj)
    if (isClass(obj:prop("periodTimer"), TimerClass)) then
        destroy(obj:prop("periodTimer"))
        obj:clear("periodTimer")
    end
    ---@type number
    local data = obj:propData("period")
    if (data > 0) then
        obj:prop("periodTimer", time.setTimeout(data, function()
            obj:clear("periodTimer")
            destroy(obj)
        end))
    end
end

---@param obj Item
expander["autoUse"] = function(obj)
    ---@type boolean
    local data = obj:propData("autoUse")
    if (data == true) then
        ---@param pickData noteOnItemPickData
        obj:onEvent(EVENT.Item.Pick, "autoUse_", function(pickData)
            local it = pickData.triggerItem
            it:effective({ triggerItem = it, triggerUnit = pickData.triggerUnit })
            destroy(it)
        end)
    else
        obj:onEvent(EVENT.Item.Pick, "autoUse_", nil)
    end
end

---@param obj Item
expander["exp"] = function(obj)
    ---@type number
    local data = obj:propData("exp")
    local lv = obj:propData("level") or 0
    if (lv >= 1) then
        local lvn = 0
        local left = 1
        local right = Game():itemLevelMax()
        while left <= right do
            local mid = math.floor((left + right) / 2)
            local expNeed = Game():itemExpNeeds(mid)
            if data >= expNeed then
                lvn = mid
                left = mid + 1
            else
                right = mid - 1
            end
        end
        if (lvn ~= lv) then
            obj:level(lvn)
        end
    end
end

---@param obj Item
---@param prev number
expander["level"] = function(obj, prev)
    ---@type number
    local data = obj:propData("level")
    prev = prev or 0
    local bu = obj:bindUnit()
    local ab = obj:ability()
    if isClass(ab, AbilityClass) then
        if (ab:levelMax() < data) then
            ab:levelMax(data)
        end
        if (ab:level() ~= data) then
            ab:level(data)
        end
    end
    event.syncTrigger(obj, EVENT.Item.LevelChange, { triggerUnit = bu, old = prev, new = data })
    event.syncTrigger(bu, EVENT.Unit.Item.LevelChange, { triggerItem = obj, old = prev, new = data })
    if ((obj:exp() or 0) > 0) then
        if ((data > 1 and data > prev) or data < prev) then
            obj:propChange("exp", "std", Game():itemExpNeeds(data), false)
        end
    end
end

---@param obj Unit
expander["hp"] = function(obj, prev)
    local data = obj:propData("hp")
    if (type(prev) == "number" and prev > 0) then
        local cur = obj:propValue("hpCur") or data
        local percent = math.trunc(cur / prev)
        obj:prop("hpCur", math.max(1, math.min(1, percent) * data))
    end
end

---@param obj Unit
expander["hpCur"] = function(obj)
    local data = obj:propData("hpCur")
    local hp = obj:propData("hp")
    if (hp ~= nil) then
        local v = data / hp * 1e4
        if v > 1 then
            J.SetUnitState(obj:handle(), UNIT_STATE_LIFE, v)
        else
            J.SetUnitState(obj:handle(), UNIT_STATE_LIFE, 1)
        end
        if (data <= 0) then
            injury.killItem(obj)
            return
        end
    end
end