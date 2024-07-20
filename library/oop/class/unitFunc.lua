---@class UnitFuncClass:AttributeFuncClass
local class = Class(UnitFuncClass):extend(AttributeFuncClass)

--- 模型ID
---@return number
function class:modelId()
    return self:prop("modelId")
end

--- 单位碰撞体积
---@return number
function class:collision()
    return self:prop("collision")
end

--- 单位语音Extra配置
---@param modify string|nil 配置KEY
---@return self|string
function class:speechExtra(modify)
    return self:prop("speechExtra", modify)
end

--- 单位模型缩放[0.2f]
---@param modify number|nil
---@return self|number
function class:modelScale(modify)
    return self:prop("modelScale", modify)
end

--- 单位选择圈缩放[0.2f]
---@param modify number|nil
---@return self|number
function class:scale(modify)
    return self:prop("scale", modify)
end

--- 单位动画速度[0.2f]
---@param modify number|nil
---@return self|number
function class:animateScale(modify)
    return self:prop("animateScale", modify)
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

--- 单位攻击动作击出比率点[%]
--- 默认0.8，范围[0-1.5]
---@param modify number|nil
---@return self|number
function class:attackPoint(modify)
    return self:prop("attackPoint", modify)
end

--- 单位转身速度[0.2f]
---@param modify number|nil
---@return self|number
function class:turnSpeed(modify)
    return self:prop("turnSpeed", modify)
end

--- 单位身材高度
---@param modify number|nil
---@return self|number
function class:stature(modify)
    return self:prop("stature", modify)
end

--- 称谓
---@param modify string|nil
---@return self|string
function class:properName(modify)
    return self:prop("properName", modify)
end

--- 设置单位动画颜色
---@param red number 红0-255
---@param green number 绿0-255
---@param blue number 蓝0-255
---@param alpha number 透明度0-255
---@param duration number 持续时间 -1无限
---@return self|Array
function class:rgba(red, green, blue, alpha, duration)
    if (type(red) == "number" or type(green) == "number" or type(blue) == "number" or type(alpha) == "number") then
        return self:prop("rgba", { red, green, blue, alpha }, duration)
    end
    return self:prop("rgba")
end

--- 单位身体材质
---@see file variable/prop UNIT_MATERIAL
---@param modify table|nil
---@return self|table
function class:material(modify)
    return self:prop("material", modify)
end

--- 单位武器声音模式
--- 默认1，可选2
--- 1为击中时发声，2为攻击点动作时发声
---@param modify number|nil
---@return self|number
function class:weaponSoundMode(modify)
    return self:prop("weaponSoundMode", modify)
end

--- 单位武器声音
---@param modify string|nil
---@return self|string
function class:weaponSound(modify)
    return self:prop("weaponSound", modify)
end

--- 武器长度
--- 默认50，箭矢将从伸长的位置开始生成
---@param modify number|nil
---@return self|number
function class:weaponLength(modify)
    return self:prop("weaponLength", modify)
end

--- 武器高度
--- 默认30，箭矢将从对应高度的位置开始生成
---@param modify number|nil
---@return self|number
function class:weaponHeight(modify)
    return self:prop("weaponHeight", modify)
end

--- 单位移动类型
---@see file variable/prop UNIT_MOVE_TYPE
---@param modify table|nil
---@return self|table
function class:moveType(modify)
    return self:prop("moveType", modify)
end

--- 生命周期
---@param modify number|nil
---@return self|number|-1
function class:period(modify)
    return self:prop("period", modify)
end

--- 持续时间（不会触发死亡）
---@param modify number|nil
---@return self|number|-1
function class:duration(modify)
    return self:prop("duration", modify)
end

--- 主属性（虚假的）
---@see file variable/prop UNIT_PRIMARY
---@param modify table|nil
---@return self|table
function class:primary(modify)
    return self:prop("primary", modify)
end

--- 单位飞行高度
---@param modify number|nil
---@return self|number
function class:flyHeight(modify)
    return self:prop("flyHeight", modify)
end

--- 单位最大级
---@param modify number|nil
---@return self|number
function class:levelMax(modify)
    return self:prop("levelMax", modify)
end

--- 单位当前等级
---@param modify number|nil
---@return self|number
function class:level(modify)
    return self:prop("level", modify)
end

--- 单位技能点数量
---@param modify number|nil
---@return self|number
function class:abilityPoint(modify)
    return self:prop("abilityPoint", modify)
end

--- 精英单位设定
---@param modify boolean|nil
---@return self|boolean
function class:elite(modify)
    return self:prop("elite", modify)
end

--- 警示单位设定，令它释放技能时有范围提示
--- 一般用于boss
---@param modify nil|boolean
---@return self|boolean
function class:alerter(modify)
    return self:prop("alerter", modify)
end

--- 尸体持续时间
--- 默认[slk.death]秒，小于等于0则无尸体
---@param modify number|nil
---@return self|number
function class:corpse(modify)
    return self:prop("corpse", modify)
end