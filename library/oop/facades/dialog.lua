--[[
    对话框
    buttons = {
        "第1个",
        "第2个",
        "第3个",
    }
    或
    buttons = {
        { value = "Q", label = "第1个" },
        { value = "W", label = "第2个" },
        { value = "D", label = "第3个" },
    }
]]

---@class Dialog:DialogClass
---@alias noteDialogAction fun(evtData:{triggerPlayer:Player,triggerDialog:Dialog,label:"标签",value:"值"}):void
---@param title string
---@param buttons string[]|table<number,{value:string,label:string,hotkey:string|number}>
---@param action noteDialogAction | "function(evtData) end"
---@return Dialog
function Dialog(title, buttons, action)
    must(#buttons > 0)
    must(type(action) == "function")
    return Object(DialogClass, {
        options = {
            title = title,
            buttons = buttons,
            action = action,
        }
    })
end
