---@class ItemFuncClass:TplClass
local class = Class(ItemFuncClass):extend(TplClass)

--- 绑定技能TPL
--- 创建物品对象时，此TPL会转为具体的技能对象
---@param modify AbilityTpl|nil
---@return self|AbilityTpl
function class:ability(modify)
    if (isClass(modify, AbilityTplClass)) then
        self:prop("ability", modify)
        return self
    end
    return self:prop("ability")
end

--- 物品具现化，没有具现化的物品不会出现在大地图
--- 物品处于单位身上时自动失去具现化意义
---@param modify boolean|nil
---@return boolean
function class:instance(modify)
    return self:prop("instance", modify)
end

--- 模型ID
---@return number
function class:modelId()
    return self:prop("modelId")
end

--- 模型缩放
---@param modify number|nil
---@return self|number
function class:modelScale(modify)
    return self:prop("modelScale", modify)
end

--- 选择圈缩放[0.2f]
---@param modify number|nil
---@return self|number
function class:scale(modify)
    return self:prop("scale", modify)
end

--- 动画时长缩放
---@param modify number|nil
---@return self|number
function class:animateScale(modify)
    return self:prop("animateScale", modify)
end

--- HP
---@param modify number
---@return self|number
function class:hp(modify)
    return self:prop("hp", modify)
end

--- HP[当前]
---@param modify number
---@return self|number
function class:hpCur(modify)
    return self:prop("hpCur", modify)
end

--- 捡取自动使用
---@param modify nil|boolean
---@return self|boolean
function class:autoUse(modify)
    return self:prop("autoUse", modify)
end

--- 持续时间
---@param modify number|nil
---@return self|number|-1
function class:duration(modify)
    return self:prop("duration", modify)
end

--- 存活周期
---@param modify number|nil
---@return self|number|-1
function class:period(modify)
    return self:prop("period", modify)
end

--- 物品制造材质
---@see file variable/prop UNIT_MATERIAL
---@param modify table|nil
---@return self|table
function class:material(modify)
    return self:prop("material", modify)
end

--- 是否消耗品
--- 默认false
--- 消耗品的数目小于1时，物品会自动销毁
---@param modify boolean|nil
---@return self|boolean
function class:consumable(modify)
    return self:prop("consumable", modify)
end

--- 是否可抵押
--- 不可抵押则没法出售
---@param modify boolean|nil
---@return self|boolean
function class:pawnable(modify)
    return self:prop("pawnable", modify)
end

--- 是否可丢弃
---@param modify boolean|nil
---@return self|boolean
function class:dropable(modify)
    return self:prop("dropable", modify)
end

--- 使用次数
---@param modify number|nil
---@return self|number|0
function class:charges(modify)
    return self:prop("charges", modify)
end

--- 物品最大级
---@param modify number|nil
---@return self|number
function class:levelMax(modify)
    return self:prop("levelMax", modify)
end

--- 物品当前等级
---@param modify number|nil
---@return self|number
function class:level(modify)
    return self:prop("level", modify)
end