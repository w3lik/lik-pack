---@class
player = player or {}

player._evtEsc = J.Condition(function()
    local triggerPlayer = h2p(J.GetTriggerPlayer())
    event.syncTrigger(triggerPlayer, EVENT.Player.Esc)
    --- 清空控制技能
    async.call(triggerPlayer, function()
        if (cursor.currentData().ability ~= nil) then
            cursor.quoteOver()
        end
    end)
    ---@type Unit
    local selection = triggerPlayer:selection()
    if (isClass(selection, UnitClass) and selection:owner() == triggerPlayer) then
        if (selection:isAbilityChantCasting()) then
            local reset = selection:prop("abilityCastRevert")
            if (type(reset) == "function") then
                reset(true)
            end
        end
        if (selection:isAbilityKeepCasting()) then
            local reset = selection:prop("abilityCastRevert")
            if (type(reset) == "function") then
                reset(true)
            end
        end
    end
end)

player._evtSelection = J.Condition(function()
    local selector = h2p(J.GetTriggerPlayer())
    local triggerObject = h2u(J.GetTriggerUnit())
    local prevObject = selector:selection()
    local select0 = true
    if (triggerObject == nil) then
        print("_evtSelection", J.GetTriggerUnit(), J.GetUnitName(J.GetTriggerUnit()), triggerObject)
        stack()
        return
    end
    --- 多选记录
    if (isClass(prevObject, UnitClass)) then
        if (prevObject:id() == triggerObject:id()) then
            select0 = false
        end
    end
    if (select0) then
        selector:prop("click", 0)
        selector:prop("selection", triggerObject)
        if (selector:prop("clickTimer") ~= nil) then
            selector:clear("clickTimer", true)
        end
    end
    selector:prop("click", "+=1")
    selector:prop("clickTimer", time.setTimeout(0.3, function()
        selector:prop("click", "-=1")
    end))
    local clickCur = math.floor(selector:prop("click"))
    for qty = 5, 1, -1 do
        if (clickCur >= qty) then
            if (isClass(triggerObject, UnitClass)) then
                event.syncTrigger(selector, EVENT.Player.SelectUnit .. "#" .. qty, {
                    triggerUnit = triggerObject,
                    qty = qty,
                })
            elseif (isClass(triggerObject, ItemClass)) then
                event.syncTrigger(selector, EVENT.Player.SelectItem .. "#" .. qty, {
                    triggerItem = triggerObject,
                    qty = qty,
                })
            end
            break
        end
    end
end)

player._evtDeSelection = J.Condition(function()
    local triggerPlayer = J.GetTriggerPlayer()
    local deSelector = h2p(triggerPlayer)
    local triggerObj = h2u(J.GetTriggerUnit())
    deSelector:prop("click", 0)
    async.call(deSelector, function()
        if (cursor.currentData().ability == nil) then
            deSelector:clear("selection")
        end
    end)
    if (isClass(triggerObj, UnitClass)) then
        event.syncTrigger(deSelector, EVENT.Player.DeSelectUnit, { triggerUnit = triggerObj })
    elseif (isClass(triggerObj, ItemClass)) then
        event.syncTrigger(deSelector, EVENT.Player.DeSelectItem, { triggerItem = triggerObj })
    end
end)

player._evtLeave = J.Condition(function()
    local triggerPlayer = J.GetTriggerPlayer()
    local leavePlayer = h2p(triggerPlayer)
    leavePlayer:status(PLAYER_STATUS.leave)
    async.call(leavePlayer, function()
        cursor.quoteOver()
    end)
    echo(leavePlayer:name() .. "离开了游戏～")
    Game():playingQuantity('-=1')
    event.syncTrigger(leavePlayer, EVENT.Player.Quit)
end)

player._evtChat = J.Condition(function()
    local chatPlayer = h2p(J.GetTriggerPlayer())
    event.syncTrigger(chatPlayer, EVENT.Player.Chat, { chatString = J.GetEventPlayerChatString() })
end)

player._evtAttacked = J.Condition(function()
    local attacker = h2u(J.GetAttacker())
    if (attacker == nil) then
        return
    end
    ---@type Unit|Item
    local target = h2o(J.GetTriggerUnit())
    if (target == nil) then
        return
    end
    local attackRangeMin = attacker:attackRangeMin()
    if (attackRangeMin > 0) then
        local ax, ay, tx, ty = attacker:x(), attacker:y(), target:x(), target:y()
        if (attackRangeMin > vector2.distance(ax, ay, tx, ty)) then
            local px, py = vector2.polar(tx, ty, attackRangeMin + 20, vector2.angle(tx, ty, ax, ay))
            time.setTimeout(0, function()
                player._unitDistanceAction(attacker, { px, py }, 10, function()
                    attacker:orderAttackTargetUnit(target)
                end)
            end)
            return
        end
    end
    local v = slk.i2v(attacker:modelId())
    if (v == nil) then
        print("attackerError")
        return
    end
    if (isClass(target, UnitClass)) then
        event.syncTrigger(attacker, EVENT.Unit.BeforeAttack, { targetUnit = target })
        event.syncTrigger(target, EVENT.Unit.Be.BeforeAttack, { sourceUnit = attacker })
    end
    local slk = v.slk
    local dmgpt = math.trunc(slk.dmgpt1, 3)
    local attackSpeed = math.min(math.max(attacker:attackSpeed(), -80), 400)
    local delay = 0.25 + attacker:attackPoint() * dmgpt / (1 + attackSpeed * 0.01)
    local ag = attacker:prop("attackedGather")
    local t = time.setTimeout(delay, function(curTimer)
        ag[curTimer:id()] = nil
        destroy(curTimer)
        if (attacker:weaponSoundMode() == 2) then
            audio(Vwp(attacker, target))
        end
        if (isClass(target, UnitClass)) then
            injury.attackUnit(attacker, target)
        elseif (isClass(target, ItemClass)) then
            injury.attackItem(attacker, target)
        end
    end)
    if (ag == nil) then
        ag = {}
        attacker:prop("attackedGather", ag)
    end
    ag[t:id()] = t
end)

player._evtOrderMoveEnd = function(triggerUnit)
    local t = triggerUnit:prop("movingTimer")
    if (isClass(t, TimerClass)) then
        triggerUnit:clear("movingTimer", true)
        triggerUnit:prop("movingStatus", 0)
        triggerUnit:prop("movingStep", 0)
        event.syncTrigger(triggerUnit, EVENT.Unit.MoveStop)
    end
end

player._evtOrderMoveTurn = function(triggerUnit)
    local t = triggerUnit:prop("movingTimer")
    if (isClass(t, TimerClass)) then
        triggerUnit:clear("movingTimer", true)
        event.syncTrigger(triggerUnit, EVENT.Unit.MoveTurn)
        triggerUnit:prop("movingStatus", 2)
    else
        triggerUnit:prop("movingStatus", 1)
    end
end

player._evtOrderMoveRoute = function(triggerUnit, x, y, flag)
    local res = false
    local pause = triggerUnit:prop("orderRoutePause")
    local route = triggerUnit:prop("orderRoute")
    if (pause == nil and type(route) == "table") then
        if (type(x) ~= "number") then
            x = triggerUnit:x()
        end
        if (type(y) ~= "number") then
            y = triggerUnit:y()
        end
        if (flag == "stop") then
            event.syncTrigger(triggerUnit, EVENT.Unit.MoveRoute, { x = x, y = y })
            res = true
        elseif (flag == "moving") then
            local idx = triggerUnit:prop("orderRouteIdx")
            local move = math.max(75, triggerUnit:move() / 4)
            if (type(idx) == "number") then
                if (idx > #route) then
                    idx = 1
                end
                if (vector2.distance(x, y, route[idx][1], route[idx][2]) < move) then
                    event.syncTrigger(triggerUnit, EVENT.Unit.MoveRoute, { x = x, y = y })
                    res = true
                end
            end
        end
    end
    return res
end

player._evtOrderMoveCatch = function(triggerUnit, tx, ty)
    if (event.syncHas(triggerUnit, EVENT.Unit.MoveStart) or
        event.syncHas(triggerUnit, EVENT.Unit.Moving) or
        event.syncHas(triggerUnit, EVENT.Unit.MoveStop) or
        event.syncHas(triggerUnit, EVENT.Unit.MoveTurn) or
        event.syncHas(triggerUnit, EVENT.Unit.MoveRoute)) then
        local xl = math.floor(triggerUnit:x())
        local yl = math.floor(triggerUnit:y())
        local xc = xl
        local yc = yl
        triggerUnit:prop("movingTimer", time.setInterval(0.1, function()
            local ms = triggerUnit:prop("movingStatus")
            if (ms == 0) then
                triggerUnit:clear("movingTimer", true)
                triggerUnit:prop("movingStep", 0)
                return
            end
            local xt = math.floor(triggerUnit:x())
            local yt = math.floor(triggerUnit:y())
            if (ms == 1) then
                if (xt ~= xc or yt ~= yc) then
                    triggerUnit:prop("movingStatus", 2)
                    event.syncTrigger(triggerUnit, EVENT.Unit.MoveStart, { x = tx, y = ty })
                else
                    local rRes = player._evtOrderMoveRoute(triggerUnit, xt, yt, "stop")
                    if (rRes == false) then
                        player._evtOrderMoveEnd(triggerUnit)
                    end
                end
            elseif (ms == 2) then
                local d = vector2.distance(xl, yl, xt, yt)
                if (d >= 99) then
                    xl = xt
                    yl = yt
                    local step = 1 + triggerUnit:prop("movingStep")
                    event.syncTrigger(triggerUnit, EVENT.Unit.Moving, { x = xt, y = yt, step = step })
                    triggerUnit:prop("movingStep", step)
                end
                local rRes = player._evtOrderMoveRoute(triggerUnit, xt, yt, "moving")
                if (rRes == false and math.abs(xt - xc) < 3 and math.abs(yt - yc) < 3) then
                    player._evtOrderMoveEnd(triggerUnit)
                    player._evtOrderMoveRoute(triggerUnit, xt, yt, "stop")
                end
            end
            xc = xt
            yc = yt
        end))
    end
end

player._evtOrder = J.Condition(function()
    local triggerUnit = h2u(J.GetTriggerUnit())
    if (isClass(triggerUnit, UnitClass) == false) then
        return
    end
    local orderId = J.GetIssuedOrderId()
    local orderTargetUnit = J.GetOrderTargetUnit()
    local tx, ty, tz
    if (orderTargetUnit ~= 0) then
        tx = J.GetUnitX(orderTargetUnit)
        ty = J.GetUnitY(orderTargetUnit)
        tz = japi.Z(tx, ty)
    else
        local loc = J.GetOrderPointLoc()
        if (loc ~= 0) then
            J.HandleRef(loc)
            tx = J.GetLocationX(loc)
            ty = J.GetLocationY(loc)
            tz = J.GetLocationZ(loc)
            J.RemoveLocation(loc)
            J.HandleUnRef(loc)
            loc = nil
        end
    end
    local owner = triggerUnit:owner()
    if (owner:isPlaying() and owner:isUser() and false == owner:isComputer()) then
        owner:prop("operand", "+=1")
        owner:prop("apm", owner:prop("operand") / (time._min + 1))
    end
    async.call(owner, function()
        if (cursor._key ~= nil and cursor._key ~= cursor._default) then
            cursor.quoteOver()
        end
    end)
    local distanceTimer = triggerUnit:prop("distanceTimer")
    if (isClass(distanceTimer, TimerClass)) then
        triggerUnit:clear("distanceTimer", true)
    end
    --[[
       851983:ATTACK 攻击
       851971:SMART
       851986:MOVE 移动
       851993:HOLD 保持原位
       851972:STOP 停止
    ]]
    if (orderId ~= 851983) then
        ---@type Array
        local ag = triggerUnit:prop("attackedGather")
        if (type(ag) == "table") then
            for k, v in pairx(ag) do
                ag[k] = nil
                destroy(v)
            end
            triggerUnit:clear("attackedGather")
        end
    end
    if (orderId == 851993) then
        event.syncTrigger(triggerUnit, EVENT.Unit.OrderHold)
        player._evtOrderMoveEnd(triggerUnit)
        player._evtOrderMoveRoute(triggerUnit, nil, nil, "stop")
    elseif (orderId == 851972) then
        event.syncTrigger(triggerUnit, EVENT.Unit.OrderStop)
        player._evtOrderMoveEnd(triggerUnit)
        player._evtOrderMoveRoute(triggerUnit, nil, nil, "stop")
    else
        if (tx ~= nil and ty ~= nil and tz ~= nil) then
            if (orderId == 851971) then
                local ci = Group():closest(ItemClass, {
                    circle = {
                        x = tx,
                        y = ty,
                        radius = 1
                    }
                })
                if (ci) then
                    triggerUnit:pickItem(ci)
                else
                    event.syncTrigger(triggerUnit, EVENT.Unit.OrderMove, { targetX = tx, targetY = ty })
                    player._evtOrderMoveTurn(triggerUnit)
                    player._evtOrderMoveCatch(triggerUnit, tx, ty)
                end
            elseif (orderId == 851983) then
                event.syncTrigger(triggerUnit, EVENT.Unit.OrderAttack, { targetX = tx, targetY = ty })
                player._evtOrderMoveTurn(triggerUnit)
                player._evtOrderMoveCatch(triggerUnit, tx, ty)
            elseif (orderId == 851986) then
                event.syncTrigger(triggerUnit, EVENT.Unit.OrderMove, { targetX = tx, targetY = ty })
                player._evtOrderMoveTurn(triggerUnit)
                player._evtOrderMoveCatch(triggerUnit, tx, ty)
            end
        end
    end
end)

player._evtDead = J.Condition(function()
    local deadUnit = h2u(J.GetTriggerUnit())
    if (deadUnit == nil) then
        return
    end
    injury.killUnit(deadUnit)
end)

--- 自带滤镜
--- 效果特别差，只建议用于纯色迷雾
player._cinematicFilter = function(duration, bMode, tex, red0, green0, blue0, trans0, red1, green1, blue1, trans1)
    J.SetCineFilterTexture(tex)
    J.SetCineFilterBlendMode(bMode)
    J.SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    J.SetCineFilterStartUV(0, 0, 1, 1)
    J.SetCineFilterEndUV(0, 0, 1, 1)
    J.SetCineFilterStartColor(red0, green0, blue0, 255 - trans0)
    J.SetCineFilterEndColor(red1, green1, blue1, 255 - trans1)
    J.SetCineFilterDuration(duration)
    J.DisplayCineFilter(true)
end

--- 单位距离过程
---@param whichUnit Unit
---@param target Unit|Item|{number,number}
---@param judgeDistance number
---@param callFunc fun():void
---@return void
player._unitDistanceAction = function(whichUnit, target, judgeDistance, callFunc)
    local distanceTimer = whichUnit:prop("distanceTimer")
    if (isClass(distanceTimer, TimerClass)) then
        whichUnit:clear("distanceTimer", true)
        distanceTimer = nil
    end
    --- 距离判断
    local _target = function(tar)
        if (isClass(tar, UnitClass) or isClass(tar, ItemClass)) then
            return tar:x(), tar:y()
        elseif (type(tar) == "table") then
            return tar[1], tar[2]
        end
    end
    local ux, uy = whichUnit:x(), whichUnit:y()
    local tx, ty = _target(target)
    local d1 = vector2.distance(tx, ty, ux, uy)
    if (d1 > judgeDistance) then
        local angle = vector2.angle(tx, ty, ux, uy)
        local px, py = vector2.polar(tx, ty, judgeDistance - 75, angle)
        J.IssuePointOrder(whichUnit:handle(), "move", px, py)
        whichUnit:prop("distanceTimer", time.setInterval(0.05, function()
            if (whichUnit:isInterrupt() or target == nil) then
                whichUnit:clear("distanceTimer", true)
                return
            end
            if (isObject(target) and isDestroy(target)) then
                whichUnit:clear("distanceTimer", true)
                return
            end
            tx, ty = _target(target)
            local d2 = vector2.distance(tx, ty, whichUnit:x(), whichUnit:y())
            if (d2 <= judgeDistance) then
                whichUnit:clear("distanceTimer", true)
                callFunc()
            end
        end))
    else
        callFunc()
    end
end