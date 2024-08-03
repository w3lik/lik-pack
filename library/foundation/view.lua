---@class
view = view or {}

---@param whichFrame Frame
function view.isGameUI(whichFrame)
    if (FrameGameUI == nil) then
        return whichFrame:handle() == japi.DZ_GetGameUI()
    end
    return whichFrame:id() == FrameGameUI:id()
end

--- 锚指的是一个frame的中心，相对于屏幕左下角的{X,Y,W,H}(RX)
---@param whichFrame Frame
---@return noteAnchorData
function view.setAnchor(whichFrame)
    local relative = whichFrame:relation()
    local size = whichFrame:size()
    if (relative ~= nil and size ~= nil) then
        ---@type noteAnchorData
        local anchorParent = relative[2]:anchor()
        if (anchorParent ~= nil) then
            local point = relative[1]
            local relativePoint = relative[3]
            -- 偏移度
            local aw
            local ah
            local pw
            local ph
            if (point == FRAME_ALIGN_LEFT_TOP or point == FRAME_ALIGN_LEFT or point == FRAME_ALIGN_LEFT_BOTTOM) then
                aw = 1
            elseif (point == FRAME_ALIGN_TOP or point == FRAME_ALIGN_CENTER or point == FRAME_ALIGN_BOTTOM) then
                aw = 0
            elseif (point == FRAME_ALIGN_RIGHT_TOP or point == FRAME_ALIGN_RIGHT or point == FRAME_ALIGN_RIGHT_BOTTOM) then
                aw = -1
            end
            if (point == FRAME_ALIGN_LEFT_TOP or point == FRAME_ALIGN_TOP or point == FRAME_ALIGN_RIGHT_TOP) then
                ah = -1
            elseif (point == FRAME_ALIGN_LEFT or point == FRAME_ALIGN_CENTER or point == FRAME_ALIGN_RIGHT) then
                ah = 0
            elseif (point == FRAME_ALIGN_LEFT_BOTTOM or point == FRAME_ALIGN_BOTTOM or point == FRAME_ALIGN_RIGHT_BOTTOM) then
                ah = 1
            end
            if (relativePoint == FRAME_ALIGN_LEFT_TOP or relativePoint == FRAME_ALIGN_LEFT or relativePoint == FRAME_ALIGN_LEFT_BOTTOM) then
                pw = -1
            elseif (relativePoint == FRAME_ALIGN_TOP or relativePoint == FRAME_ALIGN_CENTER or relativePoint == FRAME_ALIGN_BOTTOM) then
                pw = 0
            elseif (relativePoint == FRAME_ALIGN_RIGHT_TOP or relativePoint == FRAME_ALIGN_RIGHT or relativePoint == FRAME_ALIGN_RIGHT_BOTTOM) then
                pw = 1
            end
            if (relativePoint == FRAME_ALIGN_LEFT_TOP or relativePoint == FRAME_ALIGN_TOP or relativePoint == FRAME_ALIGN_RIGHT_TOP) then
                ph = 1
            elseif (relativePoint == FRAME_ALIGN_LEFT or relativePoint == FRAME_ALIGN_CENTER or relativePoint == FRAME_ALIGN_RIGHT) then
                ph = 0
            elseif (relativePoint == FRAME_ALIGN_LEFT_BOTTOM or relativePoint == FRAME_ALIGN_BOTTOM or relativePoint == FRAME_ALIGN_RIGHT_BOTTOM) then
                ph = -1
            end
            must(aw ~= nil and ah ~= nil and pw ~= nil and ph ~= nil)
            local offsetX = relative[4]
            local offsetY = relative[5]
            local parentX = anchorParent[1]
            local parentY = anchorParent[2]
            local parentW = anchorParent[3]
            local parentH = anchorParent[4]
            local anchorX
            local anchorY
            local anchorW = size[1]
            local anchorH = size[2]
            local pwHalf = parentW / 2
            local phHalf = parentH / 2
            local awHalf = anchorW / 2
            local ahHalf = anchorH / 2
            anchorX = offsetX + parentX + pw * pwHalf + aw * awHalf
            anchorY = offsetY + parentY + ph * phHalf + ah * ahHalf
            anchorX = math.min(anchorX, 0.8 - awHalf)
            anchorX = math.max(anchorX, awHalf)
            anchorY = math.min(anchorY, 0.6 - ahHalf)
            anchorY = math.max(anchorY, ahHalf)
            whichFrame:prop("anchor", { anchorX, anchorY, anchorW, anchorH })
        end
    end
    local lns = whichFrame:lowerNodes()
    if (isClass(lns, ArrayClass)) then
        lns:forEach(function(_, c)
            view.setAnchor(c)
        end)
    end
end

---@protected
---@return function
function view.frameEvtFunc(whichFrame, evt, ignoreStatus, actions)
    return function(evtData)
        if (cursor.isQuoting() and false == cursor.isDragging()) then
            return
        end
        local rx, ry = evtData.x, evtData.y
        local status = whichFrame:isInner(rx, ry, true) and whichFrame:checkTooltips(rx, ry)
        if (true == ignoreStatus or status) then
            local evd = { triggerPlayer = evtData.triggerPlayer, status = status }
            if (type(actions) == "function") then
                actions(evd)
            end
            event.asyncTrigger(whichFrame, evt, evd)
            return false
        end
    end
end

---@protected
---@param whichFrame Frame
---@param evt string|nil
---@return void
function view.frame2Mouse(whichFrame, evt, show, ...)
    local key, callFunc = datum.keyFunc(...)
    if (whichFrame == nil or evt == nil) then
        return
    end
    local id = whichFrame:id()
    local mk = id .. key
    local ban = (type(callFunc) ~= "function") or (false == show)
    if (ban) then
        if (evt == EVENT.Frame.LeftClick) then
            mouse.onLeftClick(mk, nil)
        elseif (evt == EVENT.Frame.LeftRelease) then
            mouse.onLeftRelease(mk, nil)
        elseif (evt == EVENT.Frame.RightClick) then
            mouse.onRightClick(mk, nil)
        elseif (evt == EVENT.Frame.RightRelease) then
            mouse.onRightRelease(mk, nil)
        elseif (evt == EVENT.Frame.Wheel) then
            mouse.onWheel(mk, nil)
        elseif (evt == EVENT.Frame.Move) then
            mouse.onMove(mk, nil)
        elseif (evt == EVENT.Frame.Enter) then
            mouse.onMove(mk .. '_in', nil)
        end
    else
        if (evt == EVENT.Frame.LeftClick) then
            if (nil ~= event.asyncHas(whichFrame, EVENT.Frame.Enter) or whichFrame:isInner()) then
                mouse.onLeftClick(mk, view.frameEvtFunc(whichFrame, EVENT.Frame.LeftClick))
            end
        elseif (evt == EVENT.Frame.RightClick) then
            if (false == event.asyncHas(whichFrame, EVENT.Frame.Enter) or whichFrame:isInner()) then
                mouse.onRightClick(mk, view.frameEvtFunc(whichFrame, EVENT.Frame.RightClick))
            end
        elseif (evt == EVENT.Frame.LeftRelease) then
            mouse.onLeftRelease(mk, view.frameEvtFunc(whichFrame, EVENT.Frame.LeftRelease, true))
        elseif (evt == EVENT.Frame.RightRelease) then
            mouse.onRightRelease(mk, view.frameEvtFunc(whichFrame, EVENT.Frame.RightRelease, true))
        elseif (evt == EVENT.Frame.Wheel) then
            mouse.onWheel(mk, view.frameEvtFunc(whichFrame, EVENT.Frame.Wheel, false, function(triggerData)
                triggerData.delta = evtData.delta
            end))
        elseif (evt == EVENT.Frame.Move) then
            mouse.onMove(mk, view.frameEvtFunc(whichFrame, EVENT.Frame.Move))
        elseif (evt == EVENT.Frame.Enter) then
            local ek = mk .. '_in'
            local dataEnter = event.get(event._async, whichFrame, EVENT.Frame.Enter)
            local firstKey
            if (isClass(dataEnter, ArrayClass)) then
                local count = dataEnter:count()
                if (count <= 0) then
                    firstKey = ek
                else
                    firstKey = id .. dataEnter:keys()[1] .. '_in'
                end
            end
            if (firstKey == ek) then
                local dlc = event.get(event._async, whichFrame, EVENT.Frame.LeftClick)
                if (isClass(dlc, ArrayClass)) then
                    dlc:backEach(function(k, _)
                        mouse.onLeftClick(id .. k, nil)
                    end)
                end
                local drc = event.get(event._async, whichFrame, EVENT.Frame.RightClick)
                if (isClass(drc, ArrayClass)) then
                    drc:backEach(function(k, _)
                        mouse.onRightClick(id .. k, nil)
                    end)
                end
            end
            local act
            act = function()
                mouse.onMove(ek, nil)
                local callback = event.get(event._async, "mouse", EVENT.Mouse.Move, "frameLeave_")
                if (type(callback) == "function") then
                    callback({ triggerPlayer = PlayerLocal() })
                    mouse.onMove("frameLeave_", nil)
                end
                if (firstKey == ek) then
                    ---@param evtData evtOnMouseMoveData
                    mouse.onMove("frameLeave_", function(evtData)
                        if (whichFrame:isBorder()) then
                            mouse.onMove("frameLeave_", nil)
                            event.asyncTrigger(whichFrame, EVENT.Frame.Leave, { triggerPlayer = evtData.triggerPlayer })
                            local dlc2 = event.get(event._async, whichFrame, EVENT.Frame.LeftClick)
                            if (isClass(dlc2, ArrayClass)) then
                                dlc2:backEach(function(k, _)
                                    mouse.onLeftClick(id .. k, nil)
                                end)
                            end
                            local drc2 = event.get(event._async, whichFrame, EVENT.Frame.RightClick)
                            if (isClass(drc2, ArrayClass)) then
                                drc2:backEach(function(k, _)
                                    mouse.onRightClick(id .. k, nil)
                                end)
                            end
                            mouse.onMove(ek, view.frameEvtFunc(whichFrame, EVENT.Frame.Enter, false, act))
                        end
                    end)
                    local dlc = event.get(event._async, whichFrame, EVENT.Frame.LeftClick)
                    if (isClass(dlc, ArrayClass)) then
                        dlc:backEach(function(k, _)
                            mouse.onLeftClick(id .. k, view.frameEvtFunc(whichFrame, EVENT.Frame.LeftClick))
                        end)
                    end
                    local drc = event.get(event._async, whichFrame, EVENT.Frame.RightClick)
                    if (isClass(drc, ArrayClass)) then
                        drc:backEach(function(k, _)
                            mouse.onRightClick(id .. k, view.frameEvtFunc(whichFrame, EVENT.Frame.RightClick))
                        end)
                    end
                end
            end
            if (whichFrame:isInner() and whichFrame:checkTooltips()) then
                act()
            else
                mouse.onMove(ek, view.frameEvtFunc(whichFrame, EVENT.Frame.Enter, false, act))
            end
        end
    end
end

---@param frame Frame
---@param enable boolean
---@return void
function view.esc(frame, enable)
    must(instanceof(frame, FrameClass))
    if (enable == true) then
        japi.FrameSetEsc(frame:id(), frame)
    else
        japi.FrameSetEsc(frame:id(), nil)
    end
end

--- 当游戏窗口大小异步改变
---@alias noteOnWindowResizeData fun(evtData:{triggerPlayer:Player):void
---@param key string
---@param callFunc noteOnWindowResizeData
---@return void
function view.onResize(key, callFunc)
    japi.FrameSetEventResize(key, callFunc)
end