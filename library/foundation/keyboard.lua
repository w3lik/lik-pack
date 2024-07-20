---@class keyboard
keyboard = keyboard or {}

--- 按下键盘
---@param ketString string
---@return void
function keyboard.press(ketString)
    J.ForceUIKey(ketString)
end

--- 键盘正在按下
---@param ketString string
---@return boolean
function keyboard.isPressing(ketString)
    return japi.DZ_IsKeyDown(ketString)
end

--- 当键盘异步点击
---@param keyboardCode number
---@param key string
---@param callFunc fun(evtData:evtOnKeyboardPressData)
---@return void
function keyboard.onPress(keyboardCode, key, callFunc)
    event.asyncRegister("keyboard" .. keyboardCode, EVENT.Keyboard.Press, key, callFunc)
end

--- 当键盘异步释放
---@param key string
---@param callFunc fun(evtData:evtOnKeyboardReleaseData)
---@return void
function keyboard.onRelease(keyboardCode, key, callFunc)
    event.asyncRegister("keyboard" .. keyboardCode, EVENT.Keyboard.Release, key, callFunc)
end