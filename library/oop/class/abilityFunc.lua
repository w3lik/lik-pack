---@class AbilityFuncClass:TplClass
local class = Class(AbilityFuncClass):extend(TplClass)

--- 技能类型（目标类型）
---@param modify string|nil ABILITY_TARGET_TYPE
---@return self|string
function class:targetType(modify)
    return self:prop("targetType", modify)
end

--- 发动施法动作
---@param modify string|nil
---@return self|string
function class:castAnimation(modify)
    return self:prop("castAnimation", modify)
end

--- 持续施法动作
---@param modify string|nil
---@return self|string
function class:keepAnimation(modify)
    return self:prop("keepAnimation", modify)
end

--- 施法目标允许(回调单位函数)
--- 默认为nil，不允许任何目标
---@alias noteCastTargetAllowFunc fun(self:Ability,targetUnit:Unit):boolean
---@param modify noteCastTargetAllowFunc
---@return self|noteCastTargetAllowFunc|nil
function class:castTargetFilter(modify)
    return self:prop("castTargetFilter", modify)
end

--- [成长推导]随耗
---@param key string
---@param base number|table
---@param vary number|table
---@param cond function 条件执行回调
---@param deplete function 实消执行回调
---@param value function 实际数值回调
---@param reason string|nil 原因声明
---@return self
function class:anyCostAdv(key, base, vary, cond, deplete, value, reason)
    self:prop(key .. "CostBase", base)
    self:prop(key .. "CostVary", vary)
    ---@type Array
    local costAdv = self:prop("costAdv")
    if (costAdv == nil) then
        costAdv = Array()
        self:prop("costAdv", costAdv)
    end
    costAdv:set(key, { cond = cond, deplete = deplete, value = value, reason = reason })
    return self
end

--- [成长推导]血耗
---@param base number
---@param vary number
---@return self
function class:hpCostAdv(base, vary)
    return self:anyCostAdv("hp", base, vary, ability.hpCostCond, ability.hpCostDeplete, ability.hpCostValue)
end

--- [成长推导]蓝耗
---@param base number
---@param vary number
---@return self
function class:mpCostAdv(base, vary)
    return self:anyCostAdv("mp", base, vary, ability.mpCostCond, ability.mpCostDeplete, ability.mpCostValue)
end

--- [成长推导]财耗
---@param base table
---@param vary table
---@return self
function class:worthCostAdv(base, vary)
    return self:anyCostAdv("worth", base, vary, ability.worthCostCond, ability.worthCostDeplete, ability.worthCostValue)
end

--- [成长推导]冷却时间
---@param base number
---@param vary number
---@return self
function class:coolDownAdv(base, vary)
    self:prop("coolDownBase", base)
    self:prop("coolDownVary", vary)
    return self
end

--- [成长推导]吟唱等待（秒）
---@param base number
---@param vary number
---@return self
function class:castChantAdv(base, vary)
    self:prop("castChantBase", base)
    self:prop("castChantVary", vary)
    return self
end

--- [成长推导]施法持续（秒）
---@param base number
---@param vary number
---@return self
function class:castKeepAdv(base, vary)
    self:prop("castKeepBase", base)
    self:prop("castKeepVary", vary)
    return self
end

--- [成长推导]施法距离 [默认600]
---@param base number
---@param vary number
---@return self
function class:castDistanceAdv(base, vary)
    self:prop("castDistanceBase", base)
    self:prop("castDistanceVary", vary)
    return self
end

--- [成长推导]施法圆形半径 [默认0]
---@param base number
---@param vary number
---@return self
function class:castRadiusAdv(base, vary)
    self:prop("castRadiusBase", base)
    self:prop("castRadiusVary", vary)
    return self
end

--- [成长推导]施法方形宽度 [默认0]
---@param base number
---@param vary number
---@return self
function class:castWidthAdv(base, vary)
    self:prop("castWidthBase", base)
    self:prop("castWidthVary", vary)
    return self
end

--- [成长推导]施法方形高度 [默认0]
---@param base number
---@param vary number
---@return self
function class:castHeightAdv(base, vary)
    self:prop("castHeightBase", base)
    self:prop("castHeightVary", vary)
    return self
end

--- [实际]随耗
---@param key string
---@param whichLevel number|nil
---@param default any
---@return number|table
function class:anyCost(key, whichLevel, default)
    local costAdv = self:prop("costAdv")
    if (isClass(costAdv, ArrayClass)) then
        local any = costAdv:get(key)
        if (type(any) == "table") then
            local f = any.value
            if (type(f) == "function") then
                return f(self, whichLevel)
            end
        end
    end
    return default
end

--- [实际]血耗
---@param whichLevel number|nil
---@return number
function class:hpCost(whichLevel)
    return self:anyCost("hp", whichLevel, 0)
end

--- [实际]蓝耗
---@param whichLevel number|nil
---@return number
function class:mpCost(whichLevel)
    return self:anyCost("mp", whichLevel, 0)
end

--- [实际]财耗
---@param whichLevel number|nil
---@return table|nil
function class:worthCost(whichLevel)
    return self:anyCost("worth", whichLevel, nil)
end

--- [实际]冷却时间（秒）
---@param whichLevel number|nil
---@return number
function class:coolDown(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "coolDown", "coolDownPercent", "coolDown")
    return math.max(0, math.trunc(val))
end

--- [实际]吟唱等待（秒）
--- 被动技能没有吟唱时间
---@param whichLevel number|nil
---@return number
function class:castChant(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "castChant", "castChantPercent", "castChant")
    return math.max(0, math.trunc(val, 2))
end

--- [实际]吟唱特效
--- 没有吟唱时间则没有吟唱特效
---@param modify nil|string
---@return self|string
function class:castChantEffect(modify)
    return self:prop("castChantEffect", modify)
end

--- [实际]施法持续（秒）
---@param whichLevel number|nil
---@return number
function class:castKeep(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "castKeep", "castKeepPercent", "castKeep")
    return math.max(0, math.trunc(val, 2))
end

--- [实际]施法距离
---@param whichLevel number|nil
---@return number
function class:castDistance(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "castDistance", "castDistancePercent", "castDistance")
    return math.max(0, math.round(val))
end

--- [实际]施法圆形半径
---@param whichLevel number|nil
---@return number
function class:castRadius(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "castRadius", "castRangePercent", "castRange")
    return math.max(0, math.round(val))
end

--- [实际]施法方形宽度
---@param whichLevel number|nil
---@return number
function class:castWidth(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "castWidth", "castRangePercent", "castRange")
    return math.max(0, math.round(val))
end

--- [实际]施法方形高度
---@param whichLevel number|nil
---@return number
function class:castHeight(whichLevel)
    local val = ability.caleValueNumber(self, whichLevel, "castHeight", "castRangePercent", "castRange")
    return math.max(0, math.round(val))
end

--- 技能最大级
---@param modify number|nil
---@return self|number
function class:levelMax(modify)
    return self:prop("levelMax", modify)
end

--- 技能当前等级
---@param modify number|nil
---@return self|number
function class:level(modify)
    return self:prop("level", modify)
end

--- 技能升级所需技能点,小于1则无法升级
---@param modify number|nil
---@return self|number
function class:levelUpNeedPoint(modify)
    return self:prop("levelUpNeedPoint", modify)
end

--- 禁用指针条件 [圆/方范围]
---@alias noteAbilityBanCursor {x:number,y:number,radius:number,width:number,height:number}
---@alias noteAbilityBanCursorFunc fun(options:noteAbilityBanCursor)
---@param modify noteAbilityBanCursorFunc|nil
---@return self|noteAbilityBanCursorFunc
function class:banCursor(modify)
    return self:prop("banCursor", modify)
end

--- 禁用指针条件 [圆/方范围]判断
---@protected
---@param options noteAbilityBanCursor
---@return boolean
function class:isBanCursor(options)
    local cond = self:banCursor()
    if (type(cond) ~= "function") then
        return false
    end
    return cond(options)
end