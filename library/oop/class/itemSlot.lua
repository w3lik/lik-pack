---@class ItemSlotClass:Class
local class = Class(ItemSlotClass)

---@private
function class:construct(options)
    self:prop("bindUnit", options.bindUnit)
    self:prop("volume", #Game():itemHotkey())
    self:prop("storage", {})
end

---@private
function class:destruct()
    local s = self:storage()
    if (s ~= nil) then
        for i = 1, self:volume() do
            if (isClass(s[i], ItemClass)) then
                destroy(s[i])
            end
        end
    end
end

--- 绑定单位
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
        modify = math.min(modify, #Game():itemHotkey())
        local s = self:storage()
        if (s ~= nil) then
            for i = modify, #Game():itemHotkey() do
                if (isClass(s[i], ItemClass)) then
                    destroy(s[i])
                    s[i] = nil
                end
            end
        end
        return self:prop("volume", modify)
    end
    return self:prop("volume")
end

--- 存贮数据
---@return Item[]
function class:storage()
    return self:prop("storage")
end

--- 空位数量
---@return number
function class:empty()
    local number = 0
    local s = self:storage()
    for i = 1, self:volume(), 1 do
        if (false == isClass(s[i], ItemClass)) then
            number = number + 1
        end
    end
    return number
end

--- 找出物品栏某种物品的第一索引
--- 找不到则返回-1
---@param whichTpl ItemTpl 使用TPL来判别类别
---@return number
function class:index(whichTpl)
    local idx = -1
    if (false == isClass(whichTpl, ItemTplClass)) then
        return idx
    end
    local s = self:storage()
    for i = 1, self:volume(), 1 do
        if (isClass(s[i], ItemClass)) then
            if (s[i]:tpl():id() == whichTpl:id()) then
                idx = i
                break
            end
        end
    end
    return idx
end

--- 判断物品栏是否拥有某种物品
---@param whichTpl ItemTpl 使用TPL来判别类别
---@return boolean
function class:has(whichTpl)
    return -1 ~= self:index(whichTpl)
end

--- 触发变化
---@return void
function class:triggerChange()
    local bu = self:bindUnit()
    if (isClass(bu, UnitClass)) then
        if (bu:owner():selection() == bu) then
            event.syncTrigger(bu, EVENT.Unit.ItemSlotChange, { triggerSlot = self })
        end
    end
end

--- 插入一个物品
---@param whichItem ItemTpl|Item
---@param index number|nil 对应的物品栏位置[如1-6]
---@return void
function class:insert(whichItem, index)
    ---@type Item
    local it
    if (isClass(whichItem, ItemClass)) then
        it = whichItem
    elseif (isClass(whichItem, ItemTplClass)) then
        it = Item(whichItem)
    end
    must(isClass(it, ItemClass))
    local s = self:storage()
    local bu = self:bindUnit()
    if (index == nil) then
        if (it:bindUnit() == bu) then
            return
        end
        for i = 1, self:volume(), 1 do
            if (s[i] == nil) then
                index = i
                break
            end
        end
        if (index == nil) then
            if (Game():itemPickMode() == ITEM_PICK_MODE.itemWarehouse) then
                alerter.message(bu:owner(), false, "物品栏已满已移至仓库")
                bu:owner():warehouseSlot():insert(whichItem)
            elseif (Game():itemPickMode() == ITEM_PICK_MODE.itemOnly) then
                alerter.message(bu:owner(), false, "物品栏已满")
            end
            return
        end
    end
    must(type(index) == "number")
    if (it:instance() == true) then
        it:instance(false)
    end
    local prev = s[index]
    if (isClass(prev, ItemClass)) then
        local swap = 0
        for i = 1, self:volume(), 1 do
            if (s[i] == it) then
                swap = i
                break
            end
        end
        if (swap > 0) then
            -- 交换物品的情况
            s[swap] = prev:bindUnit(bu):itemSlotIndex(swap)
            s[index] = it:bindUnit(bu):itemSlotIndex(index)
        else
            local replace = 0
            for i = 1, self:volume(), 1 do
                if (s[i] == nil) then
                    replace = i
                    break
                end
            end
            if (replace > 0) then
                -- 挤开物品的情况
                s[replace] = prev:bindUnit(bu):itemSlotIndex(replace)
            else
                -- 删除物品的情况
                self:remove(index)
            end
            s[index] = it:bindUnit(bu):itemSlotIndex(index)
            event.syncTrigger(it, EVENT.Item.Get, { triggerUnit = bu })
            if (isClass(it, ItemClass)) then
                event.syncTrigger(bu, EVENT.Unit.Item.Get, { triggerItem = it })
            end
            if (isClass(it, ItemClass)) then
                local ab = it:ability()
                if (isClass(ab, AbilityClass)) then
                    event.syncTrigger(ab, EVENT.Ability.Get, { triggerUnit = bu })
                    event.syncTrigger(bu, EVENT.Unit.Ability.Get, { triggerAbility = ab })
                end
            end
        end
    else
        if (it:bindUnit() == bu) then
            if (it:itemSlotIndex() ~= index) then
                s[it:itemSlotIndex()] = nil
                s[index] = it:bindUnit(bu):itemSlotIndex(index)
            end
        else
            s[index] = it:bindUnit(bu):itemSlotIndex(index)
            event.syncTrigger(s[index], EVENT.Item.Get, { triggerUnit = bu })
            if (isClass(s[index], ItemClass)) then
                event.syncTrigger(bu, EVENT.Unit.Item.Get, { triggerItem = s[index] })
            end
            if (isClass(s[index], ItemClass)) then
                local ab = s[index]:ability()
                if (isClass(ab, AbilityClass)) then
                    event.syncTrigger(ab, EVENT.Ability.Get, { triggerUnit = bu })
                    event.syncTrigger(bu, EVENT.Ability.Get, { triggerAbility = ab })
                end
            end
        end
    end
    self:triggerChange()
end

--- 移除一个物品
---@param index number|nil 对应的物品栏位置[如1-6]
---@return void
function class:remove(index)
    local s = self:storage()
    if (type(index) == "number" and index > 0 and index <= self:volume() and isClass(s[index], ItemClass)) then
        local bu = self:bindUnit()
        local ab = s[index]:ability()
        if (isClass(ab, AbilityClass)) then
            event.syncTrigger(ab, EVENT.Ability.Lose, { triggerUnit = bu })
            event.syncTrigger(bu, EVENT.Unit.Ability.Lose, { triggerAbility = ab })
        end
        event.syncTrigger(s[index], EVENT.Item.Lose, { triggerUnit = bu })
        event.syncTrigger(bu, EVENT.Unit.Item.Lose, { triggerItem = s[index] })
        s[index]:clear("itemSlotIndex")
        s[index]:clear("bindUnit")
        s[index] = nil
        self:triggerChange()
    end
end

--- 丢弃一个物品到X,Y
---@param index number|nil 对应的物品栏位置[如1-6]
---@param x number
---@param y number
---@return void
function class:drop(index, x, y)
    local s = self:storage()
    if (isClass(s[index], ItemClass) == false) then
        return
    end
    if (x == nil or y == nil) then
        if (isClass(self:bindUnit(), UnitClass)) then
            x = self:bindUnit():x()
            y = self:bindUnit():y()
        else
            x = 0
            y = 0
        end
    end
    s[index]:drop(x, y)
end