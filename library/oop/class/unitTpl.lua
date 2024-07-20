---@class UnitTplClass:UnitFuncClass
local class = Class(UnitTplClass):extend(UnitFuncClass)

---@private
function class:construct(options)
    Class(AttributeClass).construct(self)
    self:prop("animateScale", 1)
    self:prop("attackPoint", 0.8)
    self:prop("stature", 50)
    self:prop("properName", "")
    self:prop("material", UNIT_MATERIAL.flesh)
    self:prop("period", -1)
    self:prop("duration", -1)
    self:prop("levelMax", Game():unitLevelMax())
    self:prop("level", 0)
    self:prop("abilityPoint", 0)
    self:prop("elite", false)
    self:prop("building", false)
    self:prop("immovable", false)
    self:prop("alerter", false)
    --叠加态(叠加态可以轻松管理可叠层的状态控制)
    self:superposition("dead", 0) --死亡
    self:superposition("noPath", 0) --无路径控制
    self:superposition("noAttack", 0) --不可攻击
    self:superposition("locust", 0) --蝗虫
    self:superposition("hide", 0) --隐藏态
    self:superposition("invulnerable", 0) --无敌
    self:superposition("invisible", 0) --隐身
    self:superposition("pause", 0) --暂停
    self:superposition("hurt", 0) --受到伤害
    self:superposition("damage", 0) --造成伤害
    self:superposition("stun", 0) --眩晕
    self:superposition("silent", 0) --沉默
    self:superposition("unArm", 0) --缴械
    self:superposition("crackFly", 0) --击飞
    self:superposition("leap", 0) --冲锋
    self:superposition("whirlwind", 0) --剑刃风暴
    self:prop("weaponSoundMode", 1)
    self:prop("weaponLength", 50)
    self:prop("weaponHeight", 30)
    self:prop("moveType", UNIT_MOVE_TYPE.foot)
    self:prop("abilitySlot", true)
    self:prop("itemSlot", true)
    self:prop("hateAI", false)
    self:prop("speechAlias", options.speechAlias)
    self:prop("speechExtra", '')
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

--- 语音模型
---@return self|string
function class:speechAlias()
    return self:prop("speechAlias")
end

--- 单位模型
---@param modify string|nil 支持别称
---@return self|string
function class:modelAlias(modify)
    return self:prop("modelAlias", modify)
end

--- 绑定技能栏TPL
--- 创建单位对象时，此组TPL会转为具体的技能对象，并按顺序push进单位技能栏，是时数量溢出会报错
--- 设置bool则启用或禁用技能栏，同时之前设置的技能数据将丢失
---@param modify boolean|AbilityTpl[]
---@return self|boolean|AbilityTpl[]
function class:abilitySlot(modify)
    if (type(modify) == "boolean") then
        return self:prop("abilitySlot", modify)
    elseif (type(modify) == "table") then
        local ms = {}
        for _, m in ipairs(modify) do
            if (isClass(m, AbilityTplClass)) then
                table.insert(ms, m)
            end
        end
        self:prop("abilitySlot", ms)
        return self
    end
    return self:prop("abilitySlot")
end

--- 绑定物品栏TPL
--- 创建单位对象时，此TPLs会转为具体的物品对象，并按顺序push进单位物品栏，是时数量溢出会报错
--- 设置bool则启用或禁用物品栏，同时之前设置的技能数据将丢失
---@param modify boolean|ItemTpl[]|nil
---@return self|boolean|ItemTpl[]|nil
function class:itemSlot(modify)
    if (type(modify) == "boolean") then
        return self:prop("itemSlot", modify)
    elseif (type(modify) == "table") then
        local ms = {}
        for _, m in ipairs(modify) do
            if (isClass(m, ItemTplClass)) then
                table.insert(ms, m)
            end
        end
        self:prop("itemSlot", ms)
        return self
    end
    return self:prop("itemSlot")
end