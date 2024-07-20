---@class AttackModeClass:Class
local class = Class(AttackModeClass)

---@private
function class:construct(_)
    self:prop("priority", 0) -- 优先级
    self:prop("mode", "common") -- common missile lightning
    self:prop("damageType", DAMAGE_TYPE.common) -- 伤害类型
    self:prop("damageTypeLevel", 1) -- 伤害强度等级，应用于附魔反应判定，强的等级能覆盖弱等级，反之不能，只能造成反应
    self:prop("scale", 1.0) -- 模型大小缩放(missile only)
    self:prop("speed", 600) -- 飞行速度(missile only)
    self:prop("height", 0) -- 飞行高度(missile only)
    self:prop("acceleration", 0) -- 飞行加速度(missile only)
    self:prop("shake", 0) -- 震幅角度(missile only)
    self:prop("shakeOffset", nil) -- 震幅距离偏移(missile only)
    self:prop("homing", false) -- 自动跟踪(missile only)
    self:prop("gatlin", 0) -- 加特林(missile only)
    self:prop("scatter", 0) -- 散射数量
    self:prop("radius", 0) -- 散射捕捉范围
    self:prop("reflex", 0) -- 反射次数
    self:prop("focus", 0) -- 聚焦效果(lightning only)
end

--- 优先级(越大优先级越高)
---@param modify number|nil
---@return self|number
function class:priority(modify)
    return self:prop("priority", modify)
end

--- 攻击模式
--- 一般分为3种：通用(common)、箭矢(missile)、闪电(lightning)
--- 根据模式来调用参数来构造攻击的具体模式
---@param modify nil|string|"missile"|"lightning"
---@return self|number
function class:mode(modify)
    return self:prop("mode", modify)
end

--- 伤害类型
---@see file variable/prop DAMAGE_TYPE
---@param modify table|nil
---@return self|table
function class:damageType(modify)
    return self:prop("damageType", modify)
end

--- 伤害类型等级
---@param modify number|nil
---@return self|number
function class:damageTypeLevel(modify)
    return self:prop("damageTypeLevel", modify)
end

--- 箭矢模型
---@param modify string|nil
---@return self|string
function class:missileModel(modify)
    return self:prop("missileModel", assets.model(modify))
end

--- 闪电模型
---@see file variable/prop LIGHTNING_TYPE
---@param modify table|nil
---@return self|table
function class:lightningType(modify)
    return self:prop("lightningType", modify)
end

--- 模型缩放，默认1.0
---@param modify number|nil
---@return self|number
function class:scale(modify)
    return self:prop("scale", modify)
end

--- 位移速度，默认600
---@param modify number|nil
---@return self|number
function class:speed(modify)
    return self:prop("speed", modify)
end

--- 离地高度，默认0
---@param modify number|nil
---@return self|number
function class:height(modify)
    return self:prop("height", modify)
end

--- 加速度，默认0
---@param modify number|nil
---@return self|number
function class:acceleration(modify)
    return self:prop("acceleration", modify)
end

--- 震幅角度，默认0
--- 范围 0-359
--- 填写 rand 则随机颤动
---@param modify number|nil|"'rand'"
---@return self|number|"'rand'"
function class:shake(modify)
    return self:prop("shake", modify)
end

--- 震幅距离偏移
--- 默认为对目标距离的50%
---@param modify number
---@return self|number
function class:shakeOffset(modify)
    return self:prop("shakeOffset", modify)
end

--- 自动追踪，默认false
---@param modify boolean|nil
---@return self|boolean
function class:homing(modify)
    return self:prop("homing", modify)
end

-- 加特林效果，默认0
---@param modify number|nil
---@return self|number
function class:gatlin(modify)
    return self:prop("gatlin", modify)
end

-- 散射效果，默认0
---@param modify number|nil
---@return self|number
function class:scatter(modify)
    return self:prop("scatter", modify)
end

-- 散射范围，默认0
---@param modify number|nil
---@return self|number
function class:radius(modify)
    return self:prop("radius", modify)
end

-- 反弹效果，默认0
---@param modify number|nil
---@return self|number
function class:reflex(modify)
    return self:prop("reflex", modify)
end

--- 聚焦效果，默认0
---@param modify number|nil
---@return self|number
function class:focus(modify)
    return self:prop("focus", modify)
end