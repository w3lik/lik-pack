---@class ItemTplClass:ItemFuncClass
local class = Class(ItemTplClass):extend(ItemFuncClass)

---@private
function class:construct()
    self:prop("instance", false)
    self:prop("duration", -1)
    self:prop("period", -1)
    self:prop("hp", 1e2)
    self:prop("hpCur", 1e2)
    self:prop("consumable", false)
    self:prop("pawnable", true)
    self:prop("dropable", true)
    self:prop("autoUse", false)
    self:prop("charges", 0)
    self:prop("levelMax", 1)
    self:prop("level", 1)
    local iSlk = slk.i2v(FRAMEWORK_ID["item_token"])
    self:prop("modelAlias", iSlk.slk.file)
    self:prop("modelScale", math.trunc(iSlk.slk.modelScale or 1, 2))
    self:prop("scale", 1.00)
    self:prop("modelId", FRAMEWORK_ID["item_token"])
    self:prop("animateScale", 1)
    self:prop("material", UNIT_MATERIAL.wood)
    if (iSlk.slk.Art) then
        self:prop("icon", iSlk.slk.Art)
    end
    --叠加态(叠加态可以轻松管理可叠层的状态控制)
    self:superposition("dead", 0) --死亡
    self:superposition("locust", 0) --蝗虫
    self:superposition("invulnerable", 0) --无敌
end

--- 本对象事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onEvent(evt, ...)
    ---@type Array
    local onEvent = self:prop("onEvent")
    if (onEvent == nil) then
        onEvent = {}
        self:prop("onEvent", onEvent)
    end
    table.insert(onEvent, { evt, ... })
    return self
end

--- 通用型单位事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onUnitEvent(evt, ...)
    ---@type Array
    local onUnitEvent = self:prop("onUnitEvent")
    if (onUnitEvent == nil) then
        onUnitEvent = {}
        self:prop("onUnitEvent", onUnitEvent)
    end
    table.insert(onUnitEvent, { evt, ... })
    return self
end

--- 物品模型
---@param modify string|nil 支持别称
---@return self|string
function class:modelAlias(modify)
    return self:prop("modelAlias", modify)
end