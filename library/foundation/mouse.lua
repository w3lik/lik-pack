---@class mouse
mouse = mouse or {}

--- 设置鼠标坐标
---@param x number
---@param y number
---@return void
function mouse.position(x, y)
    japi.DZ_SetMousePos(x, y)
end

--- 当鼠标左键点击
---@param key string
---@param callFunc fun(evtData:evtOnMouseLeftClickData)
---@return void
function mouse.onLeftClick(key, callFunc)
    event.asyncRegister("mouse", EVENT.Mouse.LeftClick, key, callFunc)
end

--- 当鼠标左键释放
---@param key string
---@param callFunc fun(evtData:evtOnMouseLeftReleaseData)
---@return void
function mouse.onLeftRelease(key, callFunc)
    event.asyncRegister("mouse", EVENT.Mouse.LeftRelease, key, callFunc)
end

--- 当鼠标右键点击
---@param key string
---@param callFunc fun(evtData:evtOnMouseRightClickData)
---@return void
function mouse.onRightClick(key, callFunc)
    event.asyncRegister("mouse", EVENT.Mouse.RightClick, key, callFunc)
end

--- 当鼠标右键释放
---@param key string
---@param callFunc fun(evtData:evtOnMouseRightReleaseData)
---@return void
function mouse.onRightRelease(key, callFunc)
    event.asyncRegister("mouse", EVENT.Mouse.RightRelease, key, callFunc)
end

--- 当鼠标滚轮
---@param key string
---@param callFunc fun(evtData:evtOnMouseWheelData)
---@return void
function mouse.onWheel(key, callFunc)
    event.asyncRegister("mouse", EVENT.Mouse.Wheel, key, callFunc)
end

--- 当鼠标移动
---@param key string
---@param callFunc fun(evtData:evtOnMouseMoveData)
---@return void
function mouse.onMove(key, callFunc)
    event.asyncRegister("mouse", EVENT.Mouse.Move, key, callFunc)
end

--- 是否鼠标安全区
--- 只有安全区可以显示指针
--- 自动根据 BlockUI 对象计算
---@param rx number|nil
---@param ry number|nil
---@return boolean
function mouse.isSafety(rx, ry)
    local is = true
    rx = rx or japi.MouseRX()
    ry = ry or japi.MouseRY()
    if (rx < 0.02 or rx > 0.78 or ry < 0.02 or ry > 0.58) then
        return false
    end
    local top, bottom = japi.GetBlackBorders()
    if (ry < bottom or ry > (0.8 - top)) then
        return false
    end
    if (Group():count(FrameTextBlockClass) == 0) then
        return is
    end
    ---@param b FrameTextBlock
    Group():data(FrameTextBlockClass):forEach(function(_, b)
        if (b:isInner(rx, ry)) then
            is = false
            return false
        end
    end)
    return is
end