---@class WarehouseSlotClass:Class
local class = Class(WarehouseSlotClass)

---@private
function class:construct(options)
    self:prop("bindPlayer", options.bindPlayer)
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

--- 仓库归属玩家
---@return Player
function class:bindPlayer()
    return self:prop("bindPlayer")
end

--- 容量（缩小时超出范围对象会被直接销毁）
---@param modify number|nil
---@return self|number
function class:volume(modify)
    if (type(modify) == "number") then
        return self:prop("volume", math.round(modify))
    end
    return self:prop("volume") or Game():warehouseSlot()
end

--- 存贮数据
---@return Item[]
function class:storage()
    return self:prop("storage")
end

--- 空位数量
---@return number
function class:empty()
    local n = 0
    local s = self:storage()
    for i = 1, self:volume(), 1 do
        if (false == isClass(s[i], ItemClass)) then
            n = n + 1
        end
    end
    return n
end

--- 返回仓库栏某种物品的总数量
---@param whichTpl ItemTpl 使用TPL来判别类别
---@return boolean
function class:quantity(whichTpl)
    local qty = 0
    if (isClass(whichTpl, ItemTplClass)) then
        local s = self:storage()
        for i = 1, self:volume(), 1 do
            if (isClass(s[i], ItemClass)) then
                if (s[i]:tpl():id() == whichTpl:id()) then
                    qty = qty + 1
                end
            end
        end
    end
    return qty
end

--- 找出仓库栏某种物品的第一索引
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

--- 判断仓库栏是否拥有某种物品
---@param whichTpl ItemTpl 使用TPL来判别类别
---@return boolean
function class:has(whichTpl)
    return -1 ~= self:index(whichTpl)
end

--- 触发变化
---@return void
function class:triggerChange()
    event.syncTrigger(self:bindPlayer(), EVENT.Player.WarehouseSlotChange, { triggerSlot = self })
end

--- 插入一个物品
---@param whichItem ItemTpl|Item
---@param index number|nil 对应的仓库栏位置[1-18]
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
    local bp = self:bindPlayer()
    if (index == nil) then
        if (it:bindPlayer() == bp) then
            return
        end
        for i = 1, self:volume(), 1 do
            if (s[i] == nil) then
                index = i
                break
            end
        end
        if (index == nil) then
            alerter.message(bp, true, "仓库已满")
            return
        end
    end
    must(type(index) == "number")
    if (it:instance() == true) then
        it:instance(false)
    end
    if (it:bindUnit() ~= nil) then
        if (it:itemSlotIndex() ~= nil) then
            it:bindUnit():itemSlot():remove(it:itemSlotIndex())
        end
        it:clear("bindUnit")
    end
    if (it:ability() ~= nil) then
        it:ability():clear("bindUnit")
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
            s[swap] = prev:warehouseSlotIndex(swap)
            s[index] = it:bindPlayer(bp):warehouseSlotIndex(index)
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
                s[replace] = prev:bindPlayer(bp):warehouseSlotIndex(replace)
            else
                -- 删除物品的情况
                self:remove(index)
            end
            s[index] = it:bindPlayer(bp):warehouseSlotIndex(index)
        end
    else
        if (it:bindPlayer() == bp) then
            if (it:warehouseSlotIndex() ~= index) then
                s[it:warehouseSlotIndex()] = nil
                s[index] = it:bindPlayer(bp):warehouseSlotIndex(index)
            end
        else
            s[index] = it:bindPlayer(bp):warehouseSlotIndex(index)
        end
    end
    self:triggerChange()
end

--- 删除一个物品
---@param index number|nil 对应的仓库栏位置[1-6]
---@return void
function class:remove(index)
    local s = self:storage()
    if (type(index) == "number" and index > 0 and index <= self:volume() and isClass(s[index], ItemClass)) then
        s[index]:clear("warehouseSlotIndex")
        s[index]:clear("bindPlayer")
        s[index] = nil
        self:triggerChange()
    end
end

--- 删除仓库栏某种物品
---@param whichTpl ItemTpl 使用TPL来判别类别
---@param qty number 删除数量，默认-1：全部删除
---@return void
function class:removeTpl(whichTpl, qty)
    if (isClass(whichTpl, ItemTplClass)) then
        qty = qty or -1
        local qi = 0
        local s = self:storage()
        for i = self:volume(), 1, -1 do
            if (isClass(s[i], ItemClass)) then
                if (s[i]:tpl():id() == whichTpl:id()) then
                    self:remove(i)
                    if (qty > 0) then
                        qi = qi + 1
                        if (qi >= qty) then
                            break
                        end
                    end
                end
            end
        end
        self:triggerChange()
    end
end

--- 删除仓库栏所有物品
---@return void
function class:removeAll()
    local s = self:storage()
    for i = self:volume(), 1, -1 do
        if (isClass(s[i], ItemClass)) then
            self:remove(i)
        end
    end
    self:triggerChange()
end

--- 丢弃一个物品到X,Y
---@param index number|nil 对应的仓库栏位置[1-6]
---@param x number
---@param y number
---@return void
function class:drop(index, x, y)
    local s = self:storage()
    if (isClass(s[index], ItemClass) == false) then
        return
    end
    s[index]:drop(x, y)
    s[index] = nil
    self:triggerChange()
end