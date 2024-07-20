--[[
    剑刃风暴
    使用 Unit:isWhirlwind() 判断是否释放风暴中
    options = {
        sourceUnit [必须]中心单位，同时也是伤害来源
        animateAppend = "Spin", --附加动作
        radius [必须]半径范围
        frequency [必须]伤害频率
        duration [必须]持续时间
        filter [可选]作用范围内的单位筛选器,nil则自动选择单位的敌对势力
        centerModel [可选]中心单位特效
        centerAttach 中心单位特效串附加位
        enumModel 选取单位特效串[瞬间0]
        damage 伤害
        damageSrc 伤害来源
        damageType 伤害类型
        damageTypeLevel 伤害等级
        breakArmor 破防类型
    }
]]
---@param options {sourceUnit:Unit,animateAppend:string,radius:number,frequency:number,duration:number,filter:fun(enumUnit:Unit),damage:number,damageSrc:table,damageType:table,damageTypeLevel:number,breakArmor:table}
function ability.whirlwind(options)
    
    must(isClass(options.sourceUnit, UnitClass))
    
    local frequency = options.frequency or 0
    local duration = options.duration or 0
    
    must(frequency > 0)
    must(duration > 0)
    must(duration >= frequency)
    
    if (options.sourceUnit:isWhirlwind()) then
        return
    end
    local animateAppend = options.animateAppend or "Spin"
    options.centerAttach = options.centerAttach or "origin"
    options.sourceUnit:superposition("whirlwind", "+=1")
    options.sourceUnit:attach(options.centerModel, options.centerAttach, duration)
    options.sourceUnit:animateProperties(animateAppend, true)
    local ti = 0
    local filter = options.filter or function(enumUnit)
        return enumUnit:isAlive() and enumUnit:isEnemy(options.sourceUnit:owner())
    end
    local radius = options.radius or 0
    local damage = options.damage or 0
    if (radius <= 0 or damage > 0) then
        time.setInterval(frequency, function(curTimer)
            ti = ti + frequency
            if (ti >= duration) then
                destroy(curTimer)
                options.sourceUnit:animateProperties(animateAppend, false)
                options.sourceUnit:superposition("whirlwind", "-=1")
                return
            end
            local enumUnits = Group():catch(UnitClass, {
                circle = {
                    x = options.sourceUnit:x(),
                    y = options.sourceUnit:y(),
                    radius = radius,
                },
                filter = filter
            })
            for _, eu in ipairs(enumUnits) do
                eu:effect(options.enumModel)
                ability.damage({
                    sourceUnit = options.sourceUnit,
                    targetUnit = eu,
                    damage = damage,
                    damageSrc = options.damageSrc or DAMAGE_SRC.ability,
                    damageType = options.damageType or { DAMAGE_TYPE.common },
                    damageTypeLevel = options.damageTypeLevel,
                    breakArmor = options.breakArmor or { BREAK_ARMOR.avoid },
                })
            end
        end)
    end
end