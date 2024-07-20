local expander = ClassExpander(CLASS_EXPANDS_MOD, UnitClass)

---@param obj Unit
local _modelId = function(obj)
    local speech = assets.speech(obj:propValue("speechAlias"))
    must(type(speech) == "string")
    local extra = obj:propValue("speechExtra")
    local id
    if (type(extra) == "string" and extra ~= '') then
        id = slk.n2i(speech .. "|EX|" .. extra)
    end
    if (id == nil) then
        id = slk.n2i(speech .. "|D")
    end
    obj:prop("modelId", J.C2I(id))
end

---@param obj Unit
expander[EffectAttachClass] = function(obj)
    ---@type Array
    local data = obj:propData(EffectAttachClass)
    local at = {}
    if (isClass(data, ArrayClass)) then
        ---@param e EffectAttach
        data:forEach(function(_, e)
            at[#at + 1] = { e:model(), e:attachPosition(), e:duration() }
        end)
    end
    if (#at > 0) then
        for _, a in ipairs(at) do
            obj:attach(a[1], a[2], a[3])
        end
    end
end

---@param obj Unit
expander["building"] = function(obj)
    local data = obj:propData("building")
    if (data == true) then
        J.UnitAddAbility(obj:handle(), FRAMEWORK_ID["ability_zg"])
        J.UnitRemoveAbility(obj:handle(), FRAMEWORK_ID["ability_zg"])
    end
end

---@param obj Unit
expander["enchantMaterial"] = function(obj)
    enchant.append(obj, obj:propData("enchantMaterial"), enchant._material)
end

---@param obj Unit
expander["abilitySlot"] = function(obj)
    ---@type table
    local data = obj:propData("abilitySlot")
    if (data ~= false) then
        local slot = obj:abilitySlot()
        if (false == isClass(slot, AbilitySlotClass)) then
            --- 模版TPL转具体技能对象，并写入技能栏
            slot = AbilitySlot(obj)
            if (type(data) == "table") then
                for _, v in ipairs(data) do
                    if (isClass(v, AbilityTplClass)) then
                        slot:insert(Ability(v))
                    end
                end
            end
        end
        obj:prop("abilitySlotObj", slot)
    else
        destroy(obj:abilitySlot())
        obj:clear("abilitySlotObj")
    end
end

---@param obj Unit
expander["itemSlot"] = function(obj)
    ---@type table
    local data = obj:propData("itemSlot")
    if (data ~= false) then
        local slot = obj:itemSlot()
        if (false == isClass(slot, ItemSlotClass)) then
            --- 模版TPL转具体物品对象，并写入物品栏
            slot = ItemSlot(obj)
            if (type(data) == "table") then
                for _, v in ipairs(data) do
                    if (isClass(v, ItemTplClass)) then
                        slot:insert(Item(v))
                    end
                end
            end
        end
        obj:prop("itemSlotObj", slot)
    else
        destroy(obj:itemSlot())
        obj:clear("itemSlotObj")
    end
end

---@param obj Unit
expander["attributes"] = function(obj, prev)
    local data = obj:propData("attributes")
    local eKey = "attributes"
    event.syncUnregister(obj, EVENT.Unit.Born, eKey)
    event.syncUnregister(obj, EVENT.Unit.LevelChange, eKey)
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
            local lv = obj:level()
            attribute.clever(prev, obj, lv, -lv)
            attribute.clever(data, obj, 0, lv)
        end
        ---@param getData noteOnUnitBornData
        obj:onEvent(EVENT.Unit.Born, eKey, function(getData)
            attribute.clever(data, getData.triggerUnit, 0, getData.triggerUnit:level())
        end)
        ---@param lvcData noteOnUnitLevelChangeData
        obj:onEvent(EVENT.Unit.LevelChange, eKey, function(lvcData)
            attribute.clever(data, lvcData.triggerUnit, lvcData.old, lvcData.new - lvcData.old)
        end)
    end
end

---@param obj Unit
expander["sight"] = function(obj)
    local data = obj:propData("sight")
    obj:propChange("nsight", "std", data - obj:sightDiff(), false)
    ability.sight(obj, data)
end

---@param obj Unit
expander["nsight"] = function(obj)
    local data = obj:propData("nsight")
    if (obj:propData("sight") ~= nil) then
        local s = data + obj:propData("sightDiff")
        obj:propChange("sight", "std", s, false)
        ability.sight(obj, s)
    end
end

---@param obj Unit
expander["attackSpace"] = function(obj)
    local data = obj:propData("attackSpace")
    japi.YD_SetUnitState(obj:handle(), UNIT_STATE_ATTACK_SPACE, data)
end

---@param obj Unit
expander["attackSpaceBase"] = function(obj)
    local data = obj:propData("attackSpaceBase")
    local atkSpd = obj:propData("attackSpeed") or 0
    if (atkSpd ~= 0) then
        atkSpd = math.max(-80, atkSpd)
        atkSpd = math.min(400, atkSpd)
        data = math.trunc(data / (1 + atkSpd * 0.01))
    end
    obj:prop("attackSpace", data)
end

---@param obj Unit
expander["attackSpeed"] = function(obj)
    local data = obj:propData("attackSpeed")
    if (data ~= 0) then
        data = math.max(-80, data)
        data = math.min(400, data)
    end
    obj:prop("attackSpace", math.trunc(obj:propData("attackSpaceBase") / (1 + data * 0.01)))
end

---@param obj Unit
expander["attackRangeAcquire"] = function(obj)
    local data = obj:propData("attackRangeAcquire")
    data = math.max(100 + (obj:propData("attackRange") or 0), data)
    data = math.min(9999, data)
    data = math.floor(data)
    J.SetUnitAcquireRange(obj:handle(), data)
end

---@param obj Unit
expander["attackRange"] = function(obj)
    local data = obj:propData("attackRange")
    data = math.max(0, data)
    data = math.min(9999, data)
    data = math.floor(data)
    japi.YD_SetUnitState(obj:handle(), UNIT_STATE_ATTACK_RANGE, data)
    local ara = obj:propData("attackRangeAcquire")
    local ard = data + 100
    if (ara == nil or ara < ard) then
        obj:prop("attackRangeAcquire", ard)
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
        J.SetUnitState(obj:handle(), UNIT_STATE_LIFE, v)
        if (data <= 0) then
            Monitor("hp_regen"):ignore(obj)
            return
        end
        local regen = obj:propData("hpRegen")
        if (data < hp) then
            if (regen ~= 0) then
                Monitor("hp_regen"):listen(obj)
            else
                Monitor("hp_regen"):ignore(obj)
            end
        else
            if (regen >= 0) then
                Monitor("hp_regen"):ignore(obj)
            else
                Monitor("hp_regen"):listen(obj)
            end
        end
    end
end

---@param obj Unit
expander["hpRegen"] = function(obj)
    local data = obj:propData("hpRegen")
    if (data ~= nil and data ~= 0) then
        Monitor("hp_regen"):listen(obj)
    else
        Monitor("hp_regen"):ignore(obj)
    end
end

---@param obj Unit
expander["mp"] = function(obj, prev)
    local data = obj:propData("mp")
    if (data == 0) then
        obj:prop("mpCur", 0)
    else
        if (type(prev) == "number" and prev > 0) then
            local cur = obj:propValue("mpCur") or data
            local percent = math.trunc(cur / prev)
            obj:mpCur(math.max(1, math.min(1, percent) * data))
        end
    end
end

---@param obj Unit
expander["mpCur"] = function(obj)
    local data = obj:propData("mpCur")
    local mp = obj:propData("mp")
    if (mp ~= nil and mp > 0) then
        local v = data / mp * 1e4
        if v > 1 then
            J.SetUnitState(obj:handle(), UNIT_STATE_MANA, v)
        else
            J.SetUnitState(obj:handle(), UNIT_STATE_MANA, 1)
        end
        local regen = obj:propData("mpRegen")
        if (data < mp) then
            if (regen ~= 0) then
                Monitor("mp_regen"):listen(obj)
            else
                Monitor("mp_regen"):ignore(obj)
            end
        else
            if (regen >= 0) then
                Monitor("mp_regen"):ignore(obj)
            else
                Monitor("mp_regen"):listen(obj)
            end
        end
    end
end

---@param obj Unit
expander["mpRegen"] = function(obj)
    local data = obj:propData("mpRegen")
    if (data ~= nil and data ~= 0) then
        Monitor("mp_regen"):listen(obj)
    else
        Monitor("mp_regen"):ignore(obj)
    end
end

---@param obj Unit
expander["shield"] = function(obj, prev)
    local data = obj:propData("shield")
    if (type(prev) == "number" and prev > 0) then
        local cur = obj:propValue("shieldCur") or data
        local percent = math.trunc(cur / prev)
        percent = math.min(1, math.max(0, percent))
        obj:prop("shieldCur", percent * data)
    end
    local shieldBack = obj:prop("shieldBack")
    if (data > 0 and type(shieldBack) == "number" and shieldBack > 0) then
        ---@param beBreakShieldData noteOnUnitBeBreakShieldData
        obj:onEvent(EVENT.Unit.Be.BreakShield, "shieldBack_", function(beBreakShieldData)
            local u = beBreakShieldData.triggerUnit
            local t = u:prop("shieldBackTimer")
            if (isClass(t, TimerClass)) then
                destroy(t)
                obj:clear("shieldBackTimer")
            end
            t = time.setTimeout(shieldBack, function()
                u:shieldCur(u:shield())
            end)
            u:prop("shieldBackTimer", t)
        end)
        local t = obj:prop("shieldBackTimer")
        if (isClass(t, TimerClass) ~= true) then
            t = time.setTimeout(shieldBack, function()
                obj:shieldCur(obj:shield())
            end)
            obj:prop("shieldBackTimer", t)
        end
    else
        obj:onEvent(EVENT.Unit.Be.Shield, "shieldBack_", nil)
        destroy(obj:prop("shieldBackTimer"))
        obj:clear("shieldBackTimer")
        obj:prop("shieldCur", 0)
    end
end

---@param obj Unit
expander["shieldCur"] = function(obj, prev)
    local shield = obj:propData("shield")
    if (shield > 0) then
        local data = obj:propData("shieldCur")
        if (data <= 0) then
            if (type(prev) == "number" and prev > 0) then
                --- 触发破盾|被破盾事件
                local lhs = obj:lastHurtSource()
                event.syncTrigger(lhs, EVENT.Unit.BreakShield, { targetUnit = obj })
                event.syncTrigger(obj, EVENT.Unit.Be.BreakShield, { sourceUnit = lhs })
            end
        end
    end
end

---@param obj Unit
expander["shieldBack"] = function(obj)
    ---@type Timer
    local t = obj:prop("shieldBackTimer")
    if (isClass(t, TimerClass)) then
        local remain = t:remain()
        destroy(t)
        obj:clear("shieldBackTimer")
        local data = obj:propData("shieldBack")
        if (data > 0) then
            ---@param beBreakShieldData noteOnUnitBeBreakShieldData
            obj:onEvent(EVENT.Unit.Be.BreakShield, "shieldBack_", function(beBreakShieldData)
                local u = beBreakShieldData.triggerUnit
                local t2 = u:prop("shieldBackTimer")
                if (isClass(t2, TimerClass)) then
                    destroy(t2)
                    obj:clear("shieldBackTimer")
                end
                t2 = time.setTimeout(data, function()
                    u:prop("shieldCur", u:shield())
                end)
                u:prop("shieldBackTimer", t2)
            end)
            if (type(remain) == "number") then
                data = math.min(remain, data)
            end
            t = time.setTimeout(data, function()
                obj:shieldCur(obj:shield())
            end)
            obj:prop("shieldBackTimer", t)
        end
    end
end

---@param obj Unit
expander["visible"] = function(obj)
    ability.visible(obj, obj:prop("visible"))
end

---@param obj Unit
expander["move"] = function(obj)
    local data = math.floor(obj:propData("move"))
    data = math.min(522, math.max(0, data))
    if (obj:isImmovable()) then
        data = 0
    end
    J.SetUnitMoveSpeed(obj:handle(), data)
end

---@param obj Unit
expander["modelId"] = function(obj, prev)
    local data = obj:propData("modelId")
    if (prev ~= data) then
        local uSlk = slk.i2v(data)
        must(type(uSlk) == "table")
        local building = math.round(uSlk.slk.isbldg or 0)
        local spd = math.round(uSlk.slk.spd or 0)
        local sightBase = math.round(uSlk.slk.sight)
        local sightDiff = math.round(uSlk.slk.sight) - math.round(uSlk.slk.nsight)
        obj:propChange("collision", "std", math.round(uSlk.slk.collision), false)
        obj:propChange("building", "std", building == 1, false)
        obj:propChange("immovable", "std", spd <= 0, false)
        obj:propChange("sightBase", "std", sightBase, false)
        obj:propChange("sightDiff", "std", sightDiff, false)
        local pSlk = slk.i2v(prev)
        local keys = {
            { "attackSpaceBase", "cool1" },
            { "attackRangeAcquire", "acquire" },
            { "attackRange", "rangeN1" },
            { "move", "spd" },
            { "modelScale", "modelScale" },
            { "scale", "scale" },
            { "sight", "sight" },
            { "flyHeight", "moveHeight" },
            { "turnSpeed", "turnRate" },
        }
        for _, v in ipairs(keys) do
            local val = math.round(uSlk.slk[v[2]] or 0) - math.round(pSlk.slk[v[2]] or 0)
            if (val ~= 0) then
                obj:propChange(v[1], "std", obj:propValue(v[1]) + val)
            end
        end
        japi.DZ_SetUnitID(obj:handle(), data)
        obj:restruct()
    end
end

---@param obj Unit
---@param prev string
expander["speechAlias"] = function(obj, prev)
    local data = obj:propData("speechAlias")
    if (prev ~= data) then
        _modelId(obj)
    end
end

---@param obj Unit
---@param prev string
expander["speechExtra"] = function(obj, prev)
    local data = obj:propData("speechExtra")
    if (prev ~= data) then
        _modelId(obj)
    end
end

---@param obj Unit
expander["modelAlias"] = function(obj)
    local data = obj:propData("modelAlias")
    local m = assets.model(data)
    must(type(m) == "string")
    japi.DZ_SetUnitModel(obj:handle(), m)
end

---@param obj Unit
expander["modelScale"] = function(obj)
    local data = obj:propData("modelScale")
    J.SetUnitScale(obj:handle(), data, data, data)
end

---@param obj Unit
expander["animateScale"] = function(obj)
    J.SetUnitTimeScale(obj:handle(), obj:propData("animateScale"))
end

---@param obj Unit
expander["turnSpeed"] = function(obj)
    J.SetUnitTurnSpeed(obj:handle(), obj:propData("turnSpeed"))
end

---@param obj Unit
---@param prev number[4]
expander["rgba"] = function(obj, prev)
    ---@type number[]
    local data = obj:propData("rgba")
    if (prev) then
        data[1] = data[1] or prev[1]
        data[2] = data[2] or prev[2]
        data[3] = data[3] or prev[3]
        data[4] = data[4] or prev[4]
    end
    J.SetUnitVertexColor(obj:handle(), table.unpack(data))
end

---@param obj Unit
expander["moveType"] = function(obj)
    local data = obj:propData("moveType")
    if (data ~= UNIT_MOVE_TYPE.fly) then
        obj:prop("moveTypePrev", data)
    end
    time.setTimeout(0, function()
        if (obj:isAlive()) then
            if (data == UNIT_MOVE_TYPE.foot) then
                japi.YD_SetUnitMoveType(obj:handle(), MOVE_TYPE_FOOT)
            elseif (data == UNIT_MOVE_TYPE.fly) then
                japi.YD_SetUnitMoveType(obj:handle(), MOVE_TYPE_FLY)
            elseif (data == UNIT_MOVE_TYPE.amphibious) then
                japi.YD_SetUnitMoveType(obj:handle(), MOVE_TYPE_AMPH)
            elseif (data == UNIT_MOVE_TYPE.float) then
                japi.YD_SetUnitMoveType(obj:handle(), MOVE_TYPE_FLOAT)
            end
        end
    end)
end

---@param obj Unit
expander["period"] = function(obj)
    local periodTimer = obj:prop("periodTimer")
    if (isClass(periodTimer, TimerClass)) then
        destroy(periodTimer)
        obj:clear("periodTimer")
    end
    local data = obj:propData("period")
    if (data > 0) then
        obj:prop("periodTimer", time.setTimeout(data, function()
            obj:clear("periodTimer")
            obj:kill()
        end))
    end
end

---@param obj Unit
expander["duration"] = function(obj)
    local durationTimer = obj:prop("durationTimer")
    if (isClass(durationTimer, TimerClass)) then
        obj:clear("durationTimer", true)
    end
    local data = obj:propData("duration")
    if (data > 0) then
        obj:prop("durationTimer", time.setTimeout(data, function()
            obj:clear("durationTimer")
            destroy(obj)
        end))
    end
end

---@param obj Unit
expander["flyHeight"] = function(obj)
    local data = obj:propData("flyHeight")
    local h = obj:handle()
    J.UnitAddAbility(h, FRAMEWORK_ID["ability_fly"])
    J.UnitRemoveAbility(h, FRAMEWORK_ID["ability_fly"])
    J.SetUnitFlyHeight(h, data, 9999)
    J.SetUnitFacing(h, J.GetUnitFacing(h))
    if (data > 0) then
        obj:prop("moveType", UNIT_MOVE_TYPE.fly)
    else
        obj:prop("moveType", obj:prop("moveTypePrev") or UNIT_MOVE_TYPE.foot)
    end
end

---@param obj Unit
expander["exp"] = function(obj)
    ---@type number
    local data = obj:propData("exp")
    local lv = obj:propData("level") or 0
    if (lv >= 1) then
        local lvn = 0
        local left = 1
        local right = Game():unitLevelMax()
        while left <= right do
            local mid = math.floor((left + right) / 2)
            local expNeed = Game():unitExpNeeds(mid)
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

---@param obj Unit
---@param prev number
expander["level"] = function(obj, prev)
    local data = obj:propData("level")
    if (type(prev) == "number") then
        if (data > 1 and data > prev) then
            obj:effect("AIemTarget")
            obj:propChange("exp", "std", Game():unitExpNeeds(data), false)
        elseif (data < prev) then
            obj:effect("DispelMagicTarget")
            obj:propChange("exp", "std", Game():unitExpNeeds(data), false)
        end
        event.syncTrigger(obj, EVENT.Unit.LevelChange, { old = prev, new = data })
    else
        if (data > 1) then
            obj:propChange("exp", "std", Game():unitExpNeeds(data), false)
        end
    end
end

---@param obj Unit
expander["owner"] = function(obj)
    ---@type Player
    local data = obj:propData("owner")
    J.SetUnitOwner(obj:handle(), data:handle(), true)
end

---@param obj Unit
expander["teamColor"] = function(obj)
    ---@type number
    local data = obj:propData("teamColor")
    J.SetUnitColor(obj:handle(), PLAYER_COLOR[data])
end

---@param obj Unit
expander["orderRoute"] = function(obj, prev)
    ---@type table
    local data = obj:propData("orderRoute")
    if (false == datum.equal(prev, data)) then
        obj:prop("orderRouteIdx", 1)
    end
    event.syncRegister(obj, EVENT.Unit.MoveRoute, "RalOrderRoute", function(evtData)
        local u = evtData.triggerUnit
        local r = u:prop("orderRoute")
        local i = u:prop("orderRouteIdx")
        if (i > 0) then
            local call
            if (r[i]) then
                call = r[i][3]
            end
            i = i + 1
            if (i > #r and u:prop("orderRouteLoop")) then
                i = 1
            end
            u:prop("orderRouteIdx", i)
            if (type(call) == "function") then
                u:orderRoutePause()
                call(u)
            else
                if (i > 0 and i <= #r) then
                    u:orderMove(r[i][1], r[i][2])
                else
                    u:orderRouteDestroy()
                end
            end
        else
            u:orderRouteDestroy()
        end
    end)
    obj:orderRouteResume()
end

---@param obj Unit
expander["alerter"] = function(obj)
    ---@type boolean
    local data = obj:propData("alerter")
    if (data == true) then
        ---@param spellData noteOnAbilitySpellData
        obj:onEvent(EVENT.Unit.Ability.Spell, "alerter_", function(spellData)
            local ab = spellData.triggerAbility
            local tt = ab:targetType()
            if (tt == ABILITY_TARGET_TYPE.pas) then
                return
            end
            local name = colour.hex(colour.red, '[' .. spellData.triggerUnit:name() .. ']')
            local abName = colour.hex(colour.violet, '[' .. ab:name() .. ']')
            echo(name .. "准备施放" .. abName)
            local dur = ab:castChant()
            if (dur <= 0) then
                dur = 1
            end
            if (tt == ABILITY_TARGET_TYPE.tag_loc) then
                local x, y = spellData.triggerUnit:x(), spellData.triggerUnit:y()
                local angle = vector2.angle(x, y, spellData.targetX, spellData.targetY)
                alerter.line(x, y, ab:castDistance(), angle, dur)
            elseif (tt == ABILITY_TARGET_TYPE.tag_nil) then
                local castRadius = ab:castRadius()
                if (castRadius > 0) then
                    local x, y = spellData.triggerUnit:x(), spellData.triggerUnit:y()
                    alerter.circle(x, y, ab:castRadius(), dur)
                end
            elseif (tt == ABILITY_TARGET_TYPE.tag_unit) then
                local castRadius = ab:castRadius()
                if (castRadius > 0) then
                    alerter.follow(spellData.targetUnit, ab:castRadius(), dur)
                end
            elseif (tt == ABILITY_TARGET_TYPE.tag_circle) then
                local x, y = spellData.targetX, spellData.targetY
                alerter.circle(x, y, ab:castRadius(), dur)
            elseif (tt == ABILITY_TARGET_TYPE.tag_square) then
                local x, y = spellData.targetX, spellData.targetY
                alerter.square(x, y, ab:castWidth(), ab:castHeight(), dur)
            end
        end)
    else
        obj:onEvent(EVENT.Unit.Ability.Spell, "alerter_", nil)
    end
end