### 技能信息

```lua
-- 定义技能描述体
-- [基础信息]
---@param this Ability
---@param options {level:number}
Game():defineDescription("abilityBase", function(this, options)
    local desc = {}
    local lv = math.floor(options.level or this:level())
    local tt = this:targetType()
    if (isClass(this, AbilityClass)) then
        local lvTxt = ''
        if (this:levelMax() > 1) then
            lvTxt = " - 等级 " .. colour.hex(colour.gold, lv)
        end
        if (tt ~= ABILITY_TARGET_TYPE.pas) then
            table.insert(desc, this:name() .. lvTxt .. "（" .. colour.hex(colour.gold, this:hotkey()) .. "）")
        else
            table.insert(desc, this:name() .. lvTxt)
        end
    else
        table.insert(desc, this:name())
    end
    table.insert(desc, colour.hex(colour.gold, "类型: " .. tt.label))
    local chantCast = this:castChant(lv)
    if (chantCast > 0) then
        table.insert(desc, colour.hex(colour.lightskyblue, "吟唱时间: " .. chantCast .. " 秒"))
    elseif (tt ~= ABILITY_TARGET_TYPE.pas) then
        table.insert(desc, colour.hex(colour.lightskyblue, "吟唱时间: 瞬间施法"))
    end
    local keepCast = this:castKeep(lv)
    if (keepCast > 0) then
        table.insert(desc, colour.hex(colour.lightskyblue, "最大施法持续: " .. keepCast .. " 秒"))
    end
    if (tt ~= ABILITY_TARGET_TYPE.tag_nil and tt ~= ABILITY_TARGET_TYPE.pas) then
        table.insert(desc, colour.hex(colour.lightskyblue, "施法距离: " .. this:castDistance(lv)))
    end
    local castRadius = this:castRadius(lv)
    if (castRadius > 0) then
        table.insert(desc, colour.hex(colour.lightskyblue, "圆形半径: " .. this:castRadius(lv)))
    end
    local castWidth = this:castWidth(lv)
    local castHeight = this:castHeight(lv)
    if (castWidth > 0 and castHeight > 0) then
        table.insert(desc, colour.hex(colour.lightskyblue, "方形范围: " .. castWidth .. '*' .. castHeight))
    end
    table.insert(desc, '')
    return desc
end)

-- [技能点信息]
---@param this Ability
Game():defineDescription("abilityLvPoint", function(this, _)
    if (this:levelUpNeedPoint() > 0) then
        return { colour.hex("EFBA16", "升级需要技能点: " .. this:levelUpNeedPoint()) }
    end
end)
```

### 物品信息

```lua
-- 定义物品技能描述体
-- [基础信息]
---@param this Ability
Game():defineDescription("itemAbility", function(this)
    local desc = { '' }
    local lv = math.floor(this:level())
    local tt = this:targetType()
    table.insert(desc, colour.hex(colour.lightskyblue, "技能类型：" .. tt.label))
    if (tt ~= ABILITY_TARGET_TYPE.pas) then
        local chantCast = this:castChant(lv)
        if (chantCast > 0) then
            table.insert(desc, colour.hex(colour.lightskyblue, "吟唱时间：" .. chantCast .. " 秒"))
        else
            table.insert(desc, colour.hex(colour.lightskyblue, "吟唱时间：瞬间施法"))
        end
        local keepCast = this:castKeep(lv)
        if (keepCast > 0) then
            table.insert(desc, colour.hex(colour.lightskyblue, "施法持续：" .. keepCast .. " 秒"))
        end
        if (tt ~= ABILITY_TARGET_TYPE.tag_nil) then
            table.insert(desc, colour.hex(colour.lightskyblue, "施法距离: " .. this:castDistance(lv)))
        end
        if (tt == ABILITY_TARGET_TYPE.tag_circle) then
            table.insert(desc, colour.hex(colour.lightskyblue, "圆形半径: " .. this:castRadius(lv)))
        elseif (tt == ABILITY_TARGET_TYPE.tag_square) then
            local castWidth = this:castWidth(lv)
            local castHeight = this:castHeight(lv)
            table.insert(desc, colour.hex(colour.lightskyblue, "方形范围: " .. castWidth .. '*' .. castHeight))
        end
    end
    return desc
end)

-- 定义物品描述体
-- [基础信息]
---@param this Item
Game():defineDescription("itemBase", function(this, options)
    local desc = {}
    local name
    if (this:level() > 0 and this:levelMax() > 1) then
        name = this:name() .. "[" .. colour.hex(colour.white, this:level()) .. "级]"
    else
        name = this:name()
    end
    table.insert(desc, name)
    if (options.after ~= true) then
        table.insert(desc, '')
        local de = this:description()
        if (type(de) == "string") then
            table.insert(desc, colour.hex(colour.darkgray, de))
        elseif (type(de) == "table") then
            for _, de2 in ipairs(de) do
                table.insert(desc, colour.hex(colour.darkgray, de2))
            end
        end
    end
    local ab = this:ability()
    if (isClass(ab, AbilityClass)) then
        local tt = ab:targetType()
        if (isClass(this, ItemClass)) then
            if (tt ~= ABILITY_TARGET_TYPE.pas and this:hotkey() ~= nil) then
                name = name .. "（" .. colour.hex(colour.gold, "数字" .. this:hotkey()) .. "）"
            end
            desc[1] = name
        else
            desc[1] = name
        end
        desc = table.merge(desc, Game():combineDescription(ab, nil, "itemAbility", SYMBOL_D, "attributes"))
        if (this:charges() > 0) then
            table.insert(desc, colour.hex(colour.white, "|n剩余次数：" .. this:charges()))
        end
    else
        desc[1] = name
    end
    desc = table.merge(desc, Game():combineDescription(this, nil, "attributes"))
    return desc
end)
```

### 游戏随性信息

```lua
-- 游戏信息
Game():onEvent(EVENT.Game.Start, function()

    --- 游戏介绍
    Game():prop("infoIntro", "暂无")

    --- 中央顶部信息
    time.setInterval(1, function()
        local info = {}
        local timeOfDay = time.ofDay()
        local tit = ""
        if (timeOfDay >= 0.00 and timeOfDay < 6.00) then
            tit = "凌晨"
        elseif (timeOfDay >= 6.00 and timeOfDay < 8.00) then
            tit = "清晨"
        elseif (timeOfDay >= 8.00 and timeOfDay < 12.00) then
            tit = "上午"
        elseif (timeOfDay >= 12.00 and timeOfDay < 13.00) then
            tit = "中午"
        elseif (timeOfDay >= 13.00 and timeOfDay < 18.00) then
            tit = "下午"
        elseif (timeOfDay >= 18.00 and timeOfDay < 22.00) then
            tit = "夜晚"
        else
            tit = "深夜"
        end
        local i, f = math.modf(timeOfDay)
        f = math.floor(59 * f)
        Game():infoCenter({
            tit,
            string.fill(i, 2, '0') .. ':' .. string.fill(f, 2, '0')
        })
    end)

end)
```
