---@class DialogClass:Class
local class = Class(DialogClass)

---@private
function class:construct(options)
    href(self, J.DialogCreate())
    local buttons = Array()
    for i = 1, #options.buttons do
        local label, value, hotkey
        if (type(options.buttons[i]) == "table") then
            label = options.buttons[i].label
            value = options.buttons[i].value
            hotkey = options.buttons[i].hotkey or options.buttons[i].value
        else
            label = options.buttons[i]
            value = options.buttons[i]
            hotkey = options.buttons[i]
        end
        local hk = dialog.hotkey(hotkey)
        local b = J.DialogAddButton(self:handle(), label, hk)
        J.HandleRef(b)
        buttons:set(tostring(b), { label = label, value = value })
    end
    self:prop("action", options.action)
    self:prop("title", options.title or "标题")
    self:prop("buttons", buttons)
    event.condition(dialog._evtClick, function(tgr)
        J.TriggerRegisterDialogEvent(tgr, self:handle())
    end)
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 标题
---@param modify string|nil
---@return self|string
function class:title(modify)
    return self:prop("title", modify)
end

--- 展示，可指定给某玩家
---@param whichPlayer Player|nil
---@return self
function class:show(whichPlayer)
    if (isClass(whichPlayer, PlayerClass)) then
        J.DialogDisplay(whichPlayer:handle(), self:handle(), true)
    else
        J.DialogDisplay(Player1st():handle(), self:handle(), true)
    end
end

--- 隐藏，可指定给某玩家
---@param whichPlayer Player|nil
---@return self
function class:hide(whichPlayer)
    if (isClass(whichPlayer, PlayerClass)) then
        J.DialogDisplay(whichPlayer:handle(), self:handle(), false)
    else
        J.DialogDisplay(Player1st():handle(), self:handle(), false)
    end
end