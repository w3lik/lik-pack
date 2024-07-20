---@class EnchantClass:Class
local class = Class(EnchantClass)

---@private
function class:construct(options)
    self:prop("key", options.key)
    self:prop("name", options.key)
    self:prop("strengthen", 0)
    self:prop("resistance", 0)
    --- key初次设定时，把属性注册到ATTR各类常量内
    table.insert(ENCHANT_TYPES, options.key)
    -- 几率、抵抗
    table.insert(ATTR_ODDS, SYMBOL_E .. options.key)
    table.insert(ATTR_RESISTANCE, SYMBOL_E .. options.key)
    -- 伤害类型
    table.insert(DAMAGE_TYPE_KEYS, options.key)
    DAMAGE_TYPE[options.key] = { value = options.key, label = options.key }
end

---@private
function class:destruct()
    self:clear("appendEffect", true)
    self:clear("reaction", true)
end

--- key
---@return self|number
function class:key()
    return self:prop("key")
end

--- 名称
---@param modify nil|string
---@return self|string
function class:name(modify)
    if (type(modify) == "string") then
        DAMAGE_TYPE[self:key()].label = modify
    end
    return self:prop("name", modify)
end

--- 所有单位初始化时附带的该属性强化(%)，如5，默认0
---@param modify nil|number
---@return self|number
function class:strengthen(modify)
    return self:prop("strengthen", modify)
end

--- 所有单位初始化时附带的该属性抵抗(%)，如-10，默认0
---@param modify nil|number
---@return self|number
function class:resistance(modify)
    return self:prop("resistance", modify)
end

--- 附身特效设置
---@param attach string 绑定位置
---@param modelAlias string 特效串
---@return self|Array
function class:attachEffect(attach, modelAlias)
    ---@type Array
    local ae = self:prop("appendEffect")
    if (ae == nil) then
        ae = Array()
        self:prop("appendEffect", ae)
    end
    if (attach and modelAlias) then
        ae:set(attach, modelAlias)
        return self
    end
    return ae
end

--- 附身特效设置
---@alias noteEnchantReactionData {targetUnit:Unit,sourceUnit:Unit,from:"触发附魔元素",to:"条件附魔元素"}
---@param reactKey string 反应对应的附魔类型，例如和水反应则填water
---@param reactFunc fun(evtData:noteEnchantReactionData):void
---@return nil|self|Array
function class:reaction(reactKey, reactFunc)
    ---@type Array
    local reacts = self:prop("reaction")
    if (reacts == nil) then
        reacts = Array()
        self:prop("reaction", reacts)
    end
    if (reactKey == nil) then
        return
    end
    if (reactKey) then
        if (reactFunc == nil) then
            return reacts:get(reactKey)
        end
        if (type(reactFunc) == "function") then
            reacts:set(reactKey, reactFunc)
        else
            reacts:set(reactKey, nil)
        end
        return self
    end
    return reacts
end