---@class ItemClass:ItemFuncClass
local class = Class(ItemClass):extend(ItemFuncClass)

---@private
function class:construct(options)
    self:propChange("facing", "std", 270, false)
    self:propChange("owner", "std", PlayerPassive, false)
    self:propChange("x", "std", 0, false)
    self:propChange("y", "std", 0, false)
    self:propChange("exp", "std", 0, false)
    options.tpl:cover(self)
    self:prop("tpl", options.tpl)
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
    --- 模版TPL转具体技能对象
    if (isClass(self:prop("ability"), AbilityTplClass)) then
        self:prop("ability", Ability(self:prop("ability")))
    end
    --- 拥有次数的物品消减
    ---@param usedData noteOnItemUsedData
    self:onEvent(EVENT.Item.Used, "charges_", function(usedData)
        local it = usedData.triggerItem
        local charges = it:charges()
        if (charges > 0) then
            charges = charges - 1
            if (charges <= 0 and it:consumable()) then
                destroy(it)
            else
                it:charges(charges)
            end
        end
    end)
end

---@private
function class:destruct()
    self:clear("durationTimer", true)
    if (self:instance()) then
        self:instance(false)
    else
        self:cls()
    end
end

---@private
function class:cls()
    -- 清除掉绑定的数据和对象
    ---@type Player
    local bindPlayer = self:bindPlayer()
    if (isClass(bindPlayer, PlayerClass)) then
        bindPlayer:warehouseSlot():remove(self:warehouseSlotIndex())
    end
    ---@type Unit
    local bindUnit = self:bindUnit()
    if (isClass(bindUnit, UnitClass)) then
        local slot = bindUnit:itemSlot()
        if (isClass(slot, ItemSlotClass)) then
            slot:remove(self:itemSlotIndex())
        end
    end
    self:clear("itemSlotIndex")
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 物品TPL
---@return ItemTpl
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
        local eKey = "ioue#" .. key
        if (callFunc == nil) then
            event.syncUnregister(self, EVENT.Item.Get, eKey)
            event.syncUnregister(self, EVENT.Item.Lose, eKey)
        else
            ---@param getData noteOnItemGetData
            self:onEvent(EVENT.Item.Get, eKey, function(getData)
                event.syncRegister(getData.triggerUnit, evt, eKey, function(callData)
                    callData.triggerItem = getData.triggerItem
                    callFunc(callData)
                end)
            end)
            ---@param loseData noteOnItemLoseData
            self:onEvent(EVENT.Item.Lose, eKey, function(loseData)
                event.syncUnregister(loseData.triggerUnit, evt, eKey)
            end)
        end
    end
    return self
end

--- 物品模型
---@param modify string|nil 支持别称
---@return self|string
function class:modelAlias(modify)
    if (modify) then
        if (isDestroy(self) == false) then
            return self:prop("modelAlias", modify)
        end
    end
    return self:prop("modelAlias")
end

--- 判断物品是否有蝗虫
---@return boolean
function class:isLocust()
    return self:superposition("locust") > 0
end

--- 判断单位是否无敌
---@return boolean
function class:isInvulnerable()
    return self:superposition("invulnerable") > 0
end

--- 是否存活
---@return boolean
function class:isAlive()
    return false == isDestroy(self) and self:superposition("dead") <= 0
end

--- 是否死亡
---@return boolean
function class:isDead()
    return isDestroy(self) or self:superposition("dead") > 0
end

--- 是否敌方玩家
---@param JudgePlayer Player
---@return boolean
function class:isEnemy(JudgePlayer)
    return J.IsUnitEnemy(self:handle(), JudgePlayer:handle())
end

--- 面向角度
---@param modify number|nil
---@return self|number
function class:facing(modify)
    return self:prop("facing", modify)
end

--- 物品拥有者
---@param modify Player|nil
---@return self|Player
function class:owner(modify)
    return self:prop("owner", modify)
end

--- 最后受伤来源
---@param modify Unit|nil
---@return self|nil
function class:lastHurtSource(modify)
    return self:prop("lastHurtSource", modify)
end

--- 杀死单位
---@return void
function class:kill()
    self:hpCur(-1)
end

--- 绑定技能
--- 可以设置TPL或技能，使用TPL时会自动新建为具体技能对象
---@param modify Ability|AbilityTpl|nil
---@return Item|Ability|AbilityTpl
function class:ability(modify)
    if (isClass(modify, AbilityTplClass)) then
        self:prop("ability", Ability(modify))
        return self
    end
    return self:prop("ability")
end

--- 当前物品栏位置
---@param modify number|nil
---@return self|number|nil
function class:itemSlotIndex(modify)
    return self:prop("itemSlotIndex", modify)
end

--- 当前仓库栏位置
---@param modify number|nil
---@return self|number|nil
function class:warehouseSlotIndex(modify)
    return self:prop("warehouseSlotIndex", modify)
end

--- 当前热键字符串
---@return string|nil
function class:hotkey()
    return self:prop("hotkey")
end

--- 当前物品在某玩家仓库
---@param modify Player|nil
---@return self|Player
function class:bindPlayer(modify)
    return self:prop("bindPlayer", modify)
end

--- 当前物品被某单位持有
---@param modify Unit|nil
---@return self|Unit
function class:bindUnit(modify)
    if (isClass(modify, UnitClass)) then
        self:prop("bindUnit", modify)
        if (self:ability() ~= nil) then
            self:ability():bindUnit(modify)
        end
        return self
    end
    return self:prop("bindUnit")
end

--- X坐标
---@return number
function class:x()
    if (self:instance() == false) then
        return 0
    end
    return self:prop("x")
end

--- Y坐标
---@return number
function class:y()
    if (self:instance() == false) then
        return 0
    end
    return self:prop("y")
end

--- Z坐标
---@return number
function class:z()
    if (self:instance() == false) then
        return 0
    end
    return japi.Z(self:x(), self:y())
end

--- 移动物品到X,Y坐标
--- 如果物品在单位身上，会自动失去
---@param x number
---@param y number
---@return void
function class:position(x, y)
    if (type(x) == "number" and type(y) == "number") then
        if (false == self:instance()) then
            self:instance(true)
        end
        x, y = datum.findPosition(x, y)
        self:prop("x", x)
        self:prop("y", y)
        J.SetUnitPosition(self:handle(), x, y)
    end
end

--- 剩余持续时间
---@return number
function class:durationRemain()
    ---@type Timer
    local durationTimer = self:prop("durationTimer")
    if (isClass(durationTimer, TimerClass)) then
        return durationTimer:remain()
    end
    return -1
end

--- 剩余存活周期
---@return number
function class:periodRemain()
    ---@type Timer
    local periodTimer = self:prop("periodTimer")
    if (isClass(periodTimer, TimerClass)) then
        return periodTimer:remain()
    end
    return -1
end

--- 物品当前经验
---@param modify number|nil
---@return self|number
function class:exp(modify)
    return self:prop("exp", modify)
end

--- 获取物品升级到某等级需要的总经验
--- 根据Game的itemExpNeeds
---@param whichLevel number
---@return number
function class:expNeed(whichLevel)
    whichLevel = whichLevel or (1 + self:level())
    whichLevel = math.max(1, whichLevel)
    whichLevel = math.min(Game():itemLevelMax(), whichLevel)
    return Game():itemExpNeeds(math.floor(whichLevel))
end

--- 回收价
--- 与Player数据有关连
---@return table,Player
function class:recoveryPrice()
    ---@type Player
    local bp = self:bindPlayer()
    if (isClass(bp, PlayerClass) == false) then
        local bu = self:bindUnit()
        if (isClass(bu, UnitClass)) then
            bp = bu:owner()
        else
            return nil, nil
        end
    end
    return Game():worthCale(self:worth(), "*", bp:sellRatio() * 0.01), bp
end

--- 出售价
--- 与Store数据有关连
---@return table,Store
function class:sellingPrice()
    ---@type Player
    local bs = self:bindStore()
    return Game():worthCale(self:worth(), "*", 1), bs
end

--- 杀死物品
---@return void
function class:kill()
    self:hpCur(-1)
end

--- 丢弃物品
---@param x number
---@param y number
---@return void
function class:drop(x, y)
    local u = self:bindUnit()
    if (isClass(u, UnitClass) == false) then
        local bp = self:bindPlayer()
        if (isClass(bp, PlayerClass)) then
            u = bp:selection()
            if (u:owner() ~= bp) then
                return
            end
        else
            return
        end
    end
    x = x or u:x()
    y = y or u:y()
    player._unitDistanceAction(u, { x, y }, Game():itemActionDistance(), function()
        audio(Vcm("war3_HeroDropItem1"), u:owner())
        time.setTimeout(0.1, function()
            if (false == isDestroy(self)) then
                self:position(x, y)
                event.syncTrigger(u, EVENT.Unit.Item.Drop, { triggerItem = self, targetX = x, targetY = y })
                event.syncTrigger(self, EVENT.Item.Drop, { triggerUnit = u, targetX = x, targetY = y })
            end
        end)
    end)
end

--- 传递物品
---@param targetUnit Unit
---@return void
function class:deliver(targetUnit)
    local u = self:bindUnit()
    if (isClass(u, UnitClass) == false) then
        local bp = self:bindPlayer()
        if (isClass(bp, PlayerClass)) then
            u = bp:selection()
            if (false == table.equal(u:owner(), bp)) then
                return
            end
        else
            return
        end
    end
    if (isClass(targetUnit, UnitClass) and targetUnit:isAlive()) then
        local slot = targetUnit:itemSlot()
        if (slot) then
            local x = targetUnit:x()
            local y = targetUnit:y()
            player._unitDistanceAction(u, { x, y }, Game():itemActionDistance(), function()
                audio(Vcm("war3_HeroDropItem1"), u:owner())
                time.setTimeout(0.15, function()
                    if (false == isDestroy(self)) then
                        slot:insert(self)
                        event.syncTrigger(u, EVENT.Unit.Item.Deliver, { triggerItem = self, targetUnit = targetUnit })
                        event.syncTrigger(self, EVENT.Item.Deliver, { triggerUnit = u, targetUnit = targetUnit })
                    end
                end)
            end)
        end
    end
end

--- 抵押物品
---@return void
function class:pawn()
    local rp, bp = self:recoveryPrice()
    if (isClass(bp, PlayerClass)) then
        rp = Game():worthFloor(rp)
        bp:worth("+", rp)
        local bu = self:bindUnit()
        event.syncTrigger(bu, EVENT.Unit.Item.Pawn, { triggerItem = self })
        event.syncTrigger(self, EVENT.Item.Pawn, { triggerUnit = bu })
    end
    destroy(self)
end

--- 物品使用起效
---@param evtData noteAbilitySpellEvt
---@return void
function class:effective(evtData)
    ---@type Ability
    local ab = self:ability()
    if (isClass(ab, AbilityClass)) then
        ab:effective(evtData)
    end
end