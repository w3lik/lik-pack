---@class dialog
dialog = dialog or {}

dialog._evtClick = dialog._evtClick or J.Condition(function()
    ---@type Dialog
    local triggerDialog = h2o(J.GetClickedDialog())
    ---@type Array
    local buttons = triggerDialog:prop("buttons")
    local evtData = buttons:get(tostring(J.GetClickedButton()))
    local action = triggerDialog:prop("action")
    if (type(evtData) == "table" and type(action) == "function") then
        evtData.triggerDialog = triggerDialog
        evtData.triggerPlayer = Player(1 + J.GetPlayerId(J.GetTriggerPlayer()))
        action(evtData)
    end
    triggerDialog:clear("buttons", true)
    triggerDialog:clear("action")
end)

function dialog.hotkey(key)
    if (type(key) == "number") then
        return key
    elseif (type(key) == "string") then
        return string.byte(key, 1)
    end
    return 0
end