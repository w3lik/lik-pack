---@class AbilityTplClass:AbilityFuncClass
local class = Class(AbilityTplClass):extend(AbilityFuncClass)

---@private
function class:construct()
    self:prop("castAnimation", "spell")
    self:prop("keepAnimation", "spell")
    self:prop("levelMax", 1)
    self:prop("level", 1)
    self:prop("levelUpNeedPoint", 0)
    self:prop("castDistanceBase", 600)
    self:prop("castRadiusBase", 0)
    self:prop("castWidthBase", 0)
    self:prop("castHeightBase", 0)
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