---@class AbilitySlotClass:Class
local class = Class(AbilitySlotClass)

---@private
function class:construct(options)
    self:prop("bindUnit", options.bindUnit)
    self:prop("volume", #Game():abilityHotkey())
    self:prop("storage", {})
    self:prop("tail_", 0)
end

---@private
function class:destruct()
    local s = self:storage()
    if (s ~= nil) then
        for i = 1, self:volume() do
            if (isClass(s[i], AbilityClass)) then
                destroy(s[i])
            end
        end
    end
end

---@return Unit
function class:bindUnit()
    return self:prop("bindUnit")
end

--- 容量（缩小时超出范围对象会被直接销毁）
---@param modify number|nil
---@return self|number
function class:volume(modify)
    if (type(modify) == "number") then
        modify = math.round(modify)
        modify = math.min(modify, #Game():abilityHotkey())
        local storage = self:storage()
        if (storage ~= nil) then
            for i = modify, #Game():abilityHotkey() do
                if (isClass(storage[i], AbilityClass)) then
                    destroy(storage[i])
                    storage[i] = nil
                end
            end
        end
        return self:prop("volume", modify)
    end
    return self:prop("volume")
end

--- 存贮数据
---@return Ability[]
function class:storage()
    return self:prop("storage")
end

--- 空位数量
---@return number
function class:empty()
    local number = 0
    local storage = self:storage()
    for i = 1, self:volume(), 1 do
        if (false == isClass(storage[i], AbilityClass)) then
            number = number + 1
        end
    end
    return number
end

--- 单位技能最后位置尾
---@param modify
---@return number
function class:tail(modify)
    if (type(modify) == "number" and modify >= 0) then
        self:prop("tail", math.round(modify))
    end
    local v = self:prop("tail") or 0
    return math.max(v, self:prop("tail_"))
end

--- 找出技能栏某种技能的第一索引
--- 找不到则返回-1
---@param whichTpl AbilityTpl 使用TPL来判别类别
---@return number
function class:index(whichTpl)
    local idx = -1
    if (false == isClass(whichTpl, AbilityTplClass)) then
        return idx
    end
    local s = self:storage()
    for i = 1, self:volume(), 1 do
        if (isClass(s[i], AbilityClass)) then
            if (s[i]:tpl():id() == whichTpl:id()) then
                idx = i
                break
            end
        end
    end
    return idx
end

--- 判断技能栏中是否拥有某种技能
---@param whichTpl AbilityTpl 使用TPL来判别类别
---@return boolean
function class:has(whichTpl)
    return -1 ~= self:index(whichTpl)
end

--- 触发变化
---@return void
function class:triggerChange()
    local tail_
    local s = self:storage()
    for i = self:volume(), 1, -1 do
        if (s[i] ~= nil) then
            tail_ = i
            break
        end
    end
    self:prop("tail_", tail_)
    local bu = self:bindUnit()
    if (isClass(bu, UnitClass)) then
        if (bu:owner():selection() == bu) then
            event.syncTrigger(bu, EVENT.Unit.AbilitySlotChange, { triggerSlot = self })
        end
    end
end

--- 插入一个技能
--- 热键强制与位置顺序【ABILITY_HOTKEY】绑定，如果没有配置位置,从集合中选出一个位置自动赋予
---@param whichAbility AbilityTpl|Ability
---@param index number|nil 配置顺序位置
---@return void
function class:insert(whichAbility, index)
    ---@type Ability
    local ab
    if (isClass(whichAbility, AbilityClass)) then
        ab = whichAbility
    elseif (isClass(whichAbility, AbilityTplClass)) then
        ab = Ability(whichAbility)
    end
    must(isClass(ab, AbilityClass))
    local s = self:storage()
    local bu = self:bindUnit()
    if (index == nil) then
        if (ab:bindUnit() == bu) then
            return
        end
        for i = 1, self:volume() do
            if (s[i] == nil) then
                index = i
                break
            end
        end
    end
    must(type(index) == "number")
    local prev = s[index]
    if (isClass(prev, AbilityClass)) then
        local swap = 0
        for i = 1, self:volume() do
            if (s[i] == ab) then
                swap = i
                break
            end
        end
        if (swap > 0) then
            -- 交换技能的情况
            s[swap] = prev:bindUnit(self:bindUnit()):abilitySlotIndex(swap)
            s[index] = ab:bindUnit(self:bindUnit()):abilitySlotIndex(index)
        else
            local replace = 0
            for i = 1, self:volume() do
                if (s[i] == nil) then
                    replace = i
                    break
                end
            end
            if (replace > 0) then
                -- 挤开技能的情况
                s[replace] = prev:bindUnit(self:bindUnit()):abilitySlotIndex(replace)
            else
                -- 删除技能的情况
                self:remove(index)
            end
            s[index] = ab:bindUnit(self:bindUnit()):abilitySlotIndex(index)
            event.syncTrigger(ab, EVENT.Ability.Get, { triggerUnit = self:bindUnit() })
            if (isClass(ab, AbilityClass)) then
                event.syncTrigger(self:bindUnit(), EVENT.Ability.Get, { triggerAbility = ab })
            end
        end
    else
        if (ab:bindUnit() == self:bindUnit()) then
            for i = 1, self:volume() do
                if (s[i] == ab) then
                    s[i] = nil
                    break
                end
            end
            s[index] = ab:bindUnit(self:bindUnit()):abilitySlotIndex(index)
        else
            s[index] = ab:bindUnit(self:bindUnit()):abilitySlotIndex(index)
            event.syncTrigger(s[index], EVENT.Ability.Get, { triggerUnit = self:bindUnit() })
            if (isClass(s[index], AbilityClass)) then
                event.syncTrigger(self:bindUnit(), EVENT.Ability.Get, { triggerAbility = s[index] })
            end
        end
    end
    self:triggerChange()
end

--- 移除一个技能
---@param index number|nil 技能在技能栏中的索引
---@return void
function class:remove(index)
    local s = self:storage()
    if (type(index) == "number" and index > 0 and index <= self:volume()) then
        ---@type Ability
        if (isClass(s[index], AbilityClass)) then
            event.syncTrigger(s[index], EVENT.Ability.Lose, { triggerUnit = self:bindUnit() })
            if (isClass(s[index], AbilityClass)) then
                event.syncTrigger(self:bindUnit(), EVENT.Ability.Lose, { triggerAbility = s[index] })
            end
            s[index]:clear("abilitySlotIndex")
            s[index]:clear("bindUnit")
            s[index] = nil
            self:triggerChange()
        end
    end
end