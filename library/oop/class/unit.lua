---@class UnitClass:UnitFuncClass
local class = Class(UnitClass):extend(UnitFuncClass)

---@private
---@param options {owner:Player,tpl:UnitTpl,x:number,y:number,facing:number}
function class:construct(options)
    self:propChange("tpl", "std", options.tpl, false)
    self:propChange("owner", "std", options.owner, false)
    options.x = options.x or 0
    options.y = options.y or 0
    if (options.x == 0 and options.y == 0) then
        options.y = 1
    end
    options.facing = options.facing or 270
    href(self, J.CreateUnit(options.owner:handle(), options.tpl:modelId(), options.x, options.y, options.facing))
    self:propChange("restruct", "std", Array(), false)
    self:propChange("speechAlias", "std", options.tpl:prop("speechAlias"), false)
    self:propChange("modelId", "std", options.tpl:modelId(), false)
    self:propChange("exp", "std", 0, false)
    self:propChange("teamColor", "std", options.owner:teamColor(), false)
    self:propChange("movingStatus", "std", 0, false) --移动临时状态
    self:propChange("movingStep", "std", 0, false)
    self:propChange("attackModeList", "std", {}, false)
    options.tpl:cover(self)
    --- TPL事件注册
    local es = self:prop("onEvent")
    if (type(es) == "table") then
        for _, e in ipairs(es) do
            event.syncRegister(self, table.unpack(e))
        end
        self:clear("onEvent")
    end
    Group():insert(self)
end

---@private
function class:destruct()
    enchant.clear(self)
    Group():remove(self)
    self:clear("restruct", true)
    self:clear("abilitySlotObj", true)
    self:clear("itemSlotObj", true)
    ---@type Array
    local es = self:prop(EffectAttachClass)
    if (isClass(es, ArrayClass)) then
        es:forEach(function(_, e)
            destroy(e)
        end)
        self:clear(EffectAttachClass, true)
    end
    ---@type Array
    local ag = self:prop("attackedGather")
    if (type(ag) == "table") then
        for k, v in pairx(ag) do
            ag[k] = nil
            destroy(v)
        end
        self:clear("attackedGather")
    end
    self:clear("periodTimer", true)
    self:clear("distanceTimer", true)
    self:clear("shieldBackTimer", true)
    self:clear("movingTimer", true)
end

---@private onlySync
function class:restruct()
    local re = self:prop("restruct")
    if (isClass(re, ArrayClass)) then
        local eks = re:keys()
        for _, k in ipairs(eks) do
            self:modifier(k, self:propValue(k))
        end
    end
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 单位TPL
---@return UnitTpl
function class:tpl()
    return self:prop("tpl")
end

--- 单位语音
---@param modify string|nil 支持别称
---@return self|string
function class:speechAlias(modify)
    if (modify) then
        if (isDestroy(self) == false and self:isAlive()) then
            self:prop("speechAlias", modify)
        end
        return self
    end
    return self:prop("speechAlias")
end

--- 单位模型
---@param modify string|nil 支持别称
---@return self|string
function class:modelAlias(modify)
    if (modify) then
        if (isDestroy(self) == false and self:isAlive()) then
            self:prop("modelAlias", modify)
        end
        return self
    end
    return self:prop("modelAlias")
end

--- 剩余生命周期
---@return number
function class:periodRemain()
    ---@type Timer
    local t = self:prop("periodTimer")
    if (isClass(t, TimerClass)) then
        return t:remain()
    end
    return -1
end

--- 剩余存在时间
---@return number
function class:durationRemain()
    ---@type Timer
    local t = self:prop("durationTimer")
    if (isClass(t, TimerClass)) then
        return t:remain()
    end
    return -1
end

--- 经验值[当前]
---@param modify number|nil
---@return self|number
function class:exp(modify)
    return self:prop("exp", modify)
end

--- 获取英雄升级到某等级需要的总经验；根据Game的unitExpNeeds
---@param whichLevel number
---@return number
function class:expNeed(whichLevel)
    whichLevel = whichLevel or (1 + self:level())
    whichLevel = math.max(1, whichLevel)
    whichLevel = math.min(Game():unitLevelMax(), whichLevel)
    return Game():unitExpNeeds(math.floor(whichLevel))
end

--- 是否自己
---@param Who Unit
---@return boolean
function class:isSelf(Who)
    return self:id() == Who:id()
end

--- 是否别人
---@param Who Unit
---@return boolean
function class:isOther(Who)
    return not self:isSelf(Who)
end

--- 是否敌方玩家
---@param JudgePlayer Player
---@return boolean
function class:isEnemy(JudgePlayer)
    return J.IsUnitEnemy(self:handle(), JudgePlayer:handle())
end

--- 是否友方玩家
---@param JudgePlayer Player
---@return boolean
function class:isAlly(JudgePlayer)
    return J.IsUnitAlly(self:handle(), JudgePlayer:handle())
end

--- 是否地面单位
---@return boolean
function class:isGround()
    return self:prop("moveType") == UNIT_MOVE_TYPE.foot
end

--- 是否空中单位
---@return boolean
function class:isAir()
    return self:prop("moveType") == UNIT_MOVE_TYPE.fly
end

--- 是否水里单位
---@return boolean
function class:isWater()
    local mt = self:prop("moveType")
    return mt == UNIT_MOVE_TYPE.amphibious or mt == UNIT_MOVE_TYPE.float
end

--- 是否近战
---@return boolean
function class:isMelee()
    return isClass(self:attackMode(), AttackModeClass) == false or self:attackMode():mode() == "common"
end

--- 是否远程
---@return boolean
function class:isRanged()
    return false == self:isMelee()
end

--- 是否设定为建筑单位
--- 取决于isbldg是否为1
---@return boolean
function class:isBuilding()
    return self:prop("building") == true
end

--- 是否设定为不动单位
--- 取决于extra设定spd是否为0
---@return boolean
function class:isImmovable()
    return self:prop("immovable") == true
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

--- 判断单位是否暂停
---@return boolean
function class:isPause()
    return self:superposition("pause") > 0
end

--- 判断单位是否隐藏
---@return boolean
function class:isHide()
    return self:superposition("hide") > 0
end

--- 判断单位是否存在路径控制（允许碰撞）
---@return boolean
function class:isPathing()
    return self:superposition("noPath") <= 0
end

--- 判断单位是否允许攻击
---@return boolean
function class:isAttackAble()
    return self:superposition("noAttack") <= 0
end

--- 判断单位是否有蝗虫
---@return boolean
function class:isLocust()
    return self:superposition("locust") > 0
end

--- 判断单位是否无敌
---@return boolean
function class:isInvulnerable()
    return self:superposition("invulnerable") > 0
end

--- 判断单位是否隐身
---@return boolean
function class:isInvisible()
    return self:superposition("invisible") > 0
end

--- 是否正在受伤
---@return boolean
function class:isHurting()
    return self:superposition("hurt") > 0
end

--- 是否正在造成伤害
---@return boolean
function class:isDamaging()
    return self:superposition("damage") > 0
end

--- 是否眩晕中
---@return boolean
function class:isStunning()
    return self:superposition("stun") > 0
end

--- 是否被沉默
---@return boolean
function class:isSilencing()
    return self:superposition("silent") > 0
end

--- 是否被缴械
---@return boolean
function class:isUnArming()
    return self:superposition("unArm") > 0
end

--- 是否被击飞
---@return boolean
function class:isCrackFlying()
    return self:superposition("crackFly") > 0
end

--- 是否冲锋中
---@return boolean
function class:isLeaping()
    return self:superposition("leap") > 0
end

--- 是否剑刃风暴中
---@return boolean
function class:isWhirlwind()
    return self:superposition("whirlwind") > 0
end

--- 判断单位是否处于施法中止态
--- 暂停不属于施法中止态
--- 施法中止态定义：被销毁、死亡、眩晕、击飞、沉默
--- 详情可看 superposition/unit.lua
---@return boolean
function class:isInterrupt()
    return self:superposition("interrupt") > 0
end

--- 吟唱中
---@return boolean
function class:isAbilityChantCasting()
    return isClass(self:prop("abilityChantTimer"), TimerClass)
end

--- 是否持续施法中
---@return self|boolean
function class:isAbilityKeepCasting()
    return isClass(self:prop("abilityKeepTimer"), TimerClass)
end

--- 判断单位是否拥有某种技能
---@param whichTpl AbilityTpl 使用TPL来判别类别
---@return boolean
function class:hasAbility(whichTpl)
    local slot = self:abilitySlot()
    return isClass(slot, AbilitySlotClass) and slot:has(whichTpl)
end

--- 判断单位是否拥有某种物品
---@param whichTpl ItemTpl 使用TPL来判别类别
---@return boolean
function class:hasItem(whichTpl)
    local slot = self:itemSlot()
    return isClass(slot, ItemSlotClass) and slot:has(whichTpl)
end

--- X坐标
---@return number
function class:x()
    return J.GetUnitX(self:handle())
end

--- Y坐标
---@return number
function class:y()
    return J.GetUnitY(self:handle())
end

--- Z坐标
---@return number
function class:z()
    return japi.Z(self:x(), self:y())
end

--- H坐标[凌空]
---@return number
function class:h()
    return self:z() + self:flyHeight() + self:collision() / 2
end

--- 面向角度
---@param modify number|nil
---@return self|number
function class:facing(modify)
    if (modify ~= nil) then
        J.SetUnitFacing(self:handle(), modify)
        return self
    end
    return J.GetUnitFacing(self:handle())
end

--- 单位拥有者
---@param modify Player|nil
---@return self|Player
function class:owner(modify)
    return self:prop("owner", modify)
end

--- 单位队伍颜色
--- 使用玩家索引1-12决定颜色值
---@param modify number|nil
---@return self|number
function class:teamColor(modify)
    return self:prop("teamColor", modify)
end

--- 最后受伤来源
---@param modify Unit|nil
---@return self|nil
function class:lastHurtSource(modify)
    return self:prop("lastHurtSource", modify)
end

--- 最后伤害目标
---@param modify Unit|nil
---@return self|nil
function class:lastDamageTarget(modify)
    return self:prop("lastDamageTarget", modify)
end

--- 移动单位到X,Y坐标
---@param x number
---@param y number
---@return void
function class:position(x, y)
    if (type(x) == "number" and type(y) == "number") then
        J.SetUnitPosition(self:handle(), x, y)
    end
end

--- 命令单位做动画动作，如 "attack"
--- 当动作为整型序号时，自动播放对应的序号行为(每种模型的序号并不一致)
---@param animate number|string
---@return void
function class:animate(animate)
    if (type(animate) == "string") then
        J.SetUnitAnimation(self:handle(), animate)
    elseif (type(animate) == "number") then
        J.SetUnitAnimationByIndex(self:handle(), math.floor(animate))
    end
end

--- 单位添删动画动作
---@param animate string
---@param enable boolean
---@return void
function class:animateProperties(animate, enable)
    J.AddUnitAnimationProperties(self:handle(), animate, enable)
end

--- 杀死单位
---@return void
function class:kill()
    self:hpCur(-1)
end

--- 单位发布停止命令
---@return void
function class:orderStop()
    J.IssueImmediateOrder(self:handle(), "stop")
end

--- 单位发布伫立命令
---@return void
function class:orderHold()
    J.IssueImmediateOrder(self:handle(), "holdposition")
end

--- 单位发布攻击命令
---@param x:number
---@param y:number
---@return void
function class:orderAttack(x, y)
    J.IssuePointOrder(self:handle(), "attack", x, y)
end

--- 单位发布命令跟随某目标单位
---@param targetUnit Unit
---@return void
function class:orderFollowTargetUnit(targetUnit)
    J.IssueTargetOrder(self:handle(), "move", targetUnit:handle())
end

--- 单位发布命令攻击某目标单位
---@param targetUnit Unit
---@return void
function class:orderAttackTargetUnit(targetUnit)
    J.IssueTargetOrder(self:handle(), "attack", targetUnit:handle())
end

--- 单位发布移动命令
---@param x number
---@param y number
---@return void
function class:orderMove(x, y)
    J.IssuePointOrder(self:handle(), "move", x, y)
end

--- 单位发布AI移动命令
---@param x number
---@param y number
---@return void
function class:orderAIMove(x, y)
    J.IssuePointOrderById(self:handle(), 851988, x, y)
end

--- 单位发布巡逻移动命令
---@param x number
---@param y number
---@return void
function class:orderPatrol(x, y)
    J.IssuePointOrderById(self:handle(), 851990, x, y)
end

--- 单位发布路线移动
--- 可以被中途阻扰，但依然会非常坚持的一直遵循后续路线坐标移动下去
--- 可以在每一段停顿点加入一个自定义函数来做出额外的动作（路线会被强行暂停，动作中需要手动恢复）
--- 使用 orderRoute 来执行路线行为
--- 使用 orderRouteSet 来修改路线
--- 使用 orderRoutePause 来暂停路线行为（但会继续走完以出发的路段）
--- 使用 orderRouteResume 来恢复路线行为（在暂停10秒后如还未恢复，路线会自动废除）
--- 使用 orderRoute 来消除路线行为
---@alias noteUnitRoute {number,number,fun(orderUnit:Unit)}
---@param isLoop boolean 是否循环
---@param routes noteUnitRoute[]
---@return void
function class:orderRoute(isLoop, routes)
    if (type(routes) == "table" and #routes > 0) then
        self:prop("orderRoute", routes)
        self:prop("orderRouteLoop", isLoop or false)
    else
        self:orderRouteDestroy()
    end
end

--- 设计单位已发布的路线某一段
--- index范围为(1,inf)，如果超出范围时，自动定义为尾部添加一个
--- 也就是可以可以替换删除原有的
---@param index number integer
---@param route noteUnitRoute|nil 当route为nil时，则为去掉该段区间路径
---@return void
function class:orderRouteSet(index, route)
    local r = self:prop("orderRoute")
    if (type(r) == "table") then
        if (index <= 0 or index > (#r + 1)) then
            index = #r + 1
            r[index] = route
        else
            if (route == nil) then
                table.remove(r, index)
            else
                r[index] = route
            end
        end
    end
end

--- 废弃单位发布的路线移动
---@return void
function class:orderRouteDestroy()
    event.syncRegister(self, EVENT.Unit.MoveRoute, "RalOrderRoute", nil)
    self:clear("orderRoute")
    self:clear("orderRouteLoop")
    self:clear("orderRouteIdx")
    self:clear("orderRoutePause")
    local t = self:prop("orderRoutePauseTimer")
    if (isClass(t, "Timer")) then
        self:clear("orderRoutePauseTimer", true)
    end
end

--- 暂停单位发布的路线移动
---@return void
function class:orderRoutePause()
    local i = self:prop("orderRouteIdx")
    if (i >= 1) then
        self:prop("orderRoutePause", i)
        self:prop("orderRoutePauseTimer", time.setTimeout(10, function()
            self:orderRouteDestroy()
        end))
    end
end

--- 恢复单位发布的路线移动
---@return void
function class:orderRouteResume()
    local r = self:prop("orderRoute")
    local i = self:prop("orderRouteIdx")
    self:clear("orderRoutePause")
    local t = self:prop("orderRoutePauseTimer")
    if (isClass(t, TimerClass)) then
        self:clear("orderRoutePauseTimer", true)
    end
    if (type(r) == "table" and type(i) == "number") then
        self:orderMove(r[i][1], r[i][2])
    end
end

--- 获取优先级最高的攻击模式对象
--- 攻击模式对象按优先级，从高到低获取
---@return AttackMode|nil
function class:attackMode()
    ---@type AttackMode[]
    local am = self:prop("attackModeList")
    local am0 = self:prop("attackMode")
    local len = #am
    if (len == 0) then
        return am0
    end
    local mc = am[len]
    for i = len - 1, 1, -1 do
        local m = am[i]
        if (m:priority() > mc:priority()) then
            mc = m
        end
    end
    if (am0 and am0:priority() > mc:priority()) then
        mc = am0
    end
    return mc
end

--- 增加可选攻击模式对象
---@param mode AttackMode
---@return self
function class:attackModePush(mode)
    if (isClass(mode, AttackModeClass)) then
        ---@type AttackMode[]
        local am = self:prop("attackModeList")
        table.insert(am, mode)
    end
    return self
end

--- 删除可选攻击模式对象
--- 根据攻击模式对象ID删除(注意，相同ID会被全部删除)
---@param objId string
---@return self
function class:attackModeRemove(objId)
    if (type(objId) == "string") then
        ---@type AttackMode[]
        local am = self:prop("attackModeList")
        if (#am > 0) then
            for i = #am, 1, -1 do
                if (am[i]:id() == objId) then
                    table.remove(am, i)
                end
            end
        end
    end
    return self
end

--- 在单位位置创建特效
---@param effect string
---@param duration number
---@return Effect|nil
function class:effect(effect, duration)
    return Effect(effect, self:x(), self:y(), self:h(), duration)
end

--- 绑定特效
---@param effect string
---@param attach string
---@param duration number
---@return EffectAttach|nil
function class:attach(effect, attach, duration)
    return EffectAttach(self, effect, attach, duration)
end

--- 解绑特效
---@param effect string
---@param attach string
---@return void
function class:detach(effect, attach)
    EffectDetach(self, effect, attach)
end

--- 单位技能栏
---@return AbilitySlot|nil
function class:abilitySlot()
    return self:prop("abilitySlotObj")
end

--- 吟唱设定时间
---@return number
function class:abilityChantPeriod()
    ---@type Timer
    local t = self:prop("abilityChantTimer")
    if (isClass(t, TimerClass)) then
        return t:period()
    end
    return 0
end

--- 吟唱剩余时间
---@return number
function class:abilityChantRemain()
    ---@type Timer
    local t = self:prop("abilityChantTimer")
    if (isClass(t, TimerClass)) then
        return t:remain()
    end
    return 0
end

--- 持续施法设定时间
---@return number
function class:abilityKeepPeriod()
    ---@type Timer
    local t = self:prop("abilityKeepTimer")
    if (isClass(t, TimerClass)) then
        return t:period() * self:prop("abilityKeepTimerEnd")
    end
    return 0
end

--- 持续施法剩余时间
---@return number
function class:abilityKeepRemain()
    ---@type Timer
    local t = self:prop("abilityKeepTimer")
    if (isClass(t, TimerClass)) then
        return t:period() * (self:prop("abilityKeepTimerEnd") - self:prop("abilityKeepTimerInc"))
    end
    return 0
end

--- 单位物品栏
---@return ItemSlot
function class:itemSlot()
    return self:prop("itemSlotObj")
end

--- 单位捡物品（存在捡取过程）
---@param targetItem Item
---@return void
function class:pickItem(targetItem)
    if (isClass(targetItem, ItemClass) and targetItem:instance() == true) then
        player._unitDistanceAction(self, targetItem, Game():itemActionDistance(), function()
            if (targetItem:instance() == true) then
                audio(Vcm("war3_PickUpItem"), self:owner())
                event.syncTrigger(targetItem, EVENT.Item.Pick, { triggerUnit = self })
                if (isClass(targetItem, ItemClass)) then
                    event.syncTrigger(self, EVENT.Unit.Item.Pick, { triggerItem = targetItem })
                    if (isClass(targetItem, ItemClass)) then
                        local itemSlot = self:itemSlot()
                        if (itemSlot == nil or Game():itemPickMode() == ITEM_PICK_MODE.warehouseOnly) then
                            self:owner():warehouseSlot():insert(targetItem)
                        else
                            itemSlot:insert(targetItem)
                        end
                    end
                end
            end
        end)
    end
end

--- 伤型附着
---@return nil|table<string,noteEnchantAppendingData>
function class:enchantAppending()
    return self:prop("enchantAppending")
end

--- 伤型附着等级
---@param key string|table 附魔类型|DAMAGE_TYPE
---@return number
function class:enchantAppendingLevel(key)
    return enchant.level(self, key)
end

--- 强制修改伤型附着等级
---@param key string|table 附魔类型|DAMAGE_TYPE
---@param forceLevel number 目标等级
---@return void
function class:enchantAppendingForceLevel(key, forceLevel)
    local ea = self:enchantAppending()
    if (type(key) == "table") then
        key = key.value
    end
    if (type(ea) == "table" and type(ea[key]) == "table") then
        ea[key].level = forceLevel
    end
end

--- 是否正附着某伤型
---@param key string|table 附魔类型|DAMAGE_TYPE
---@return boolean
function class:isEnchantAppending(key)
    return 0 ~= self:enchantAppendingLevel(key)
end

--- 伤型附着持续设定时间（秒）
--- 默认为nil，取全局设置时间
---@param modify number|nil
---@return self|number
function class:enchantAppendDuration(modify)
    return self:prop("enchantAppendDuration", modify)
end