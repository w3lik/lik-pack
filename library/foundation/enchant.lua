--- 附魔
enchant = enchant or {}

--- 永久附魔等级数值
enchant._material = -999

local cls = function(data)
    if (type(data) == "table") then
        if (type(data.effect) == "table") then
            for _, eff in ipairs(data.effect) do
                destroy(eff)
            end
            data.effect = nil
        end
        if (isClass(data.timer, TimerClass)) then
            destroy(data.timer)
            data.timer = nil
        end
    end
end

--- 附魔附着
---@alias noteEnchantAppendingData {level:number,effect:EffectAttach[],timer:Timer}
---@param targetUnit Unit
---@param eType table DAMAGE_TYPE
---@param level number <等级负数时，不会被自动泯灭><等级0时，不会附着>
---@param sourceUnit Unit|nil
---@return void
function enchant.append(targetUnit, eType, level, sourceUnit)
    if (isClass(targetUnit, UnitClass) == false or type(eType) ~= "table") then
        return
    end
    if (isDestroy(targetUnit)) then
        return
    end
    level = level or 0
    local appending = targetUnit:enchantAppending()
    if (type(appending) == "table") then
        -- 有过去的附着，检测反应
        for _, v in ipairs(ENCHANT_TYPES) do
            local a = appending[v]
            if (type(a) == "table") then
                -- 反应
                local react = Enchant(v):reaction(eType.value)
                if (type(react) == "function") then
                    if (a.level < 0) then
                        if (level < 0) then
                            a.level = a.level + level
                        end
                    elseif (a.level > 0) then
                        if (level < 0) then
                            -- 新附魔不泯灭，泯灭旧附魔
                            cls(appending[v])
                            appending[v] = nil
                        elseif (level == a.level) then
                            -- 泯灭新旧附魔，都被反应用光了
                            level = 0
                            cls(appending[v])
                            appending[v] = nil
                        elseif (level > a.level) then
                            -- 泯灭旧附魔，被新反应用光了
                            level = level - a.level
                            cls(appending[v])
                            appending[v] = nil
                        else
                            -- 泯灭新附魔，被旧反应用光了
                            -- 0级反应一样要消耗附着元素，消耗完泯灭之
                            a.level = a.level - math.max(1, level)
                            if (a.level == 0) then
                                cls(appending[v])
                                appending[v] = nil
                            end
                            level = 0
                        end
                    end
                    react({
                        targetUnit = targetUnit,
                        sourceUnit = sourceUnit,
                        from = v,
                        to = eType.value,
                    })
                end
            end
        end
    end
    if (level ~= 0) then
        if (appending == nil) then
            appending = {}
        end
        local e = eType.value
        local ec = Enchant(e)
        if (false == isClass(ec, EnchantClass)) then
            return
        end
        if (appending[e] == nil) then
            appending[e] = {}
        else
            cls(appending[e])
        end
        if (level > 0) then
            if (type(appending[e].level) == "number" and appending[e].level > 0) then
                level = math.max(level, appending[e].level)
            end
        else
            if (type(appending[e].level) == "number" and appending[e].level < 0) then
                level = math.min(level, appending[e].level)
            end
        end
        appending[e].level = level
        if (level ~= 0) then
            local dur = targetUnit:enchantAppendDuration() or attribute._enDmgAppDur
            local ae = ec:attachEffect()
            if (isClass(ae, ArrayClass)) then
                if (appending[e].effect == nil) then
                    appending[e].effect = {}
                    ae:forEach(function(attach, modelAlias)
                        local e2 = targetUnit:attach(modelAlias, attach, -1)
                        if (e2 ~= nil) then
                            table.insert(appending[e].effect, e2)
                        end
                    end)
                end
            end
            if (level > 0) then
                appending[e].timer = time.setTimeout(dur, function()
                    enchant.subtract(targetUnit, eType, -level)
                end)
            end
        end
    end
    if (type(appending) == "table") then
        targetUnit:prop("enchantAppending", appending)
    end
end

--- 附魔去着
---@param whichUnit Unit
---@param eType table DAMAGE_TYPE
---@param level number|nil 削去的等级
---@return void
function enchant.subtract(whichUnit, eType, level)
    if (isClass(whichUnit, UnitClass) == false or type(eType) ~= "table") then
        return
    end
    if (eType.value == nil) then
        return
    end
    local appending = whichUnit:enchantAppending()
    if (type(appending) ~= "table") then
        return
    end
    local a = appending[eType.value]
    if (type(a) ~= "table" or type(level) ~= "number") then
        return
    end
    a.level = a.level - level
    if (a.level >= 0) then
        cls(a)
        appending[eType.value] = nil
    end
end

--- 所有附魔去着
---@param whichUnit Unit
---@return void
function enchant.clear(whichUnit)
    if (isClass(whichUnit, UnitClass) == false) then
        return
    end
    local appending = whichUnit:enchantAppending()
    if (type(appending) ~= "table") then
        return
    end
    for _, v in ipairs(ENCHANT_TYPES) do
        local a = appending[v]
        cls(a)
    end
    whichUnit:clear("enchantAppending")
end

--- 获取单位某种附魔等级
---@param whichUnit Unit
---@param key string
---@return number int
function enchant.level(whichUnit, key)
    local appending = whichUnit:prop("enchantAppending")
    if (type(appending) == "table" and type(appending[key]) == "table") then
        return appending[key].level or 0
    end
    return 0
end

--- 获取单位是否拥有某种附魔
---@param whichUnit Unit
---@param key string
---@return boolean
function enchant.has(whichUnit, key)
    return ability.enchantLevel(whichUnit, key) > 0
end