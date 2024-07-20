local expander = ClassExpander(CLASS_EXPANDS_MOD, AbilityClass)

---@param obj Ability
expander["attributes"] = function(obj, prev)
    ---@type {string,number}[]
    local data = obj:propData("attributes")
    local eKey = "attributes"
    event.syncUnregister(obj, EVENT.Ability.Get, eKey)
    event.syncUnregister(obj, EVENT.Ability.Lose, eKey)
    event.syncUnregister(obj, EVENT.Ability.LevelChange, eKey)
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
        ---@param getData noteOnAbilityGetData
        obj:onEvent(EVENT.Ability.Get, eKey, function(getData)
            attribute.clever(data, getData.triggerUnit, 0, getData.triggerAbility:level())
        end)
        ---@param loseData noteOnAbilityLoseData
        obj:onEvent(EVENT.Ability.Lose, eKey, function(loseData)
            attribute.clever(data, loseData.triggerUnit, loseData.triggerAbility:level(), -loseData.triggerAbility:level())
        end)
        ---@param lvcData noteOnAbilityLevelChangeData
        obj:onEvent(EVENT.Ability.LevelChange, eKey, function(lvcData)
            attribute.clever(data, lvcData.triggerUnit, lvcData.old, lvcData.new - lvcData.old)
        end)
    end
end

---@param obj Ability
expander["abilitySlotIndex"] = function(obj)
    ---@type number
    local data = obj:propData("abilitySlotIndex")
    obj:propChange("hotkey", "std", Game():abilityHotkey(data), false)
end

---@param obj Ability
expander["exp"] = function(obj)
    ---@type number
    local data = obj:propData("exp")
    local lv = obj:propData("level") or 0
    if (lv >= 1) then
        local lvn = 0
        local left = 1
        local right = Game():abilityLevelMax()
        while left <= right do
            local mid = math.floor((left + right) / 2)
            local expNeed = Game():abilityExpNeeds(mid)
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

---@param obj Ability
---@param prev number
expander["level"] = function(obj, prev)
    ---@type number
    local data = obj:propData("level")
    prev = prev or 0
    local bu = obj:bindUnit()
    event.syncTrigger(obj, EVENT.Ability.LevelChange, { triggerUnit = bu, old = prev, new = data })
    event.syncTrigger(bu, EVENT.Unit.Ability.LevelChange, { triggerAbility = obj, old = prev, new = data })
    if ((obj:exp() or 0) > 0) then
        if ((data > 1 and data > prev) or data < prev) then
            obj:propChange("exp", "std", Game():abilityExpNeeds(data), false)
        end
    end
end