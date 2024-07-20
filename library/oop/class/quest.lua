---@class QuestClass:Class
local class = Class(QuestClass)

---@private
function class:construct(options)
    href(self, J.CreateQuest())
    self:prop("key", options.key)
    self:prop("title", "title")
    self:prop("side", "right")
    self:prop("icon", "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp")
    self:prop("content", '')
    self:prop("complete", false)
    self:prop("fail", false)
    self:prop("discover", true)
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

--- 图标
---@param modify string|nil
---@return self|string
function class:icon(modify)
    return self:prop("icon", assets.icon(modify))
end

--- 位置
---@param modify nil|string|"'left'"|"'right'"
---@return self|string
function class:side(modify)
    return self:prop("side", modify)
end

--- 内容
---@param modify string|string[]
---@return self|string
function class:content(modify)
    if (modify and type(modify) == "table") then
        modify = table.concat(modify, "|n")
    end
    return self:prop("content", modify)
end

--- 完成状态
---@param modify boolean|nil
---@return self|boolean
function class:complete(modify)
    return self:prop("complete", modify)
end

--- 失败状态
---@param modify boolean|nil
---@return self|boolean
function class:fail(modify)
    return self:prop("fail", modify)
end

--- 发现状态
---@param modify boolean|nil
---@return self|boolean
function class:discover(modify)
    return self:prop("discover", modify)
end

--- 令任务按钮闪烁
---@return void
function class:flash()
    J.FlashQuestDialogButton()
end
