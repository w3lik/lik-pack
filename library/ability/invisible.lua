--[[
    模版技能 隐身
    使用 Unit:isInvisible() 判断是否隐身
    options = {
        whichUnit 目标单位
        duration 持续时间
        effect 点特效路径
    }
]]
---@param options {whichUnit:Unit,duration:number,effect:string}|noteAbilityBuff
function ability.invisible(options)
    local whichUnit = options.whichUnit
    if (isClass(whichUnit, UnitClass) == false or whichUnit:isDead()) then
        return
    end
    local duration = options.duration or 0
    whichUnit:effect(options.effect)
    local b = whichUnit:buff("invisible"):signal(BUFF_SIGNAL.up)
    b:name(options.name)
    b:icon(options.icon)
    b:description(options.description)
    b:duration(duration)
     :purpose(function(buffObj)
        buffObj:superposition("invisible", "+=1")
    end)
     :rollback(function(buffObj)
        buffObj:superposition("invisible", "-=1")
    end)
     :run()
end

--[[
    模版技能 取消隐身
    options = {
        whichUnit 目标单位
        effect 点特效路径
    }
]]
---@param options {whichUnit:Unit,effect:string}
function ability.unInvisible(options)
    local whichUnit = options.whichUnit
    if (isClass(whichUnit, UnitClass) == false or whichUnit:isDead()) then
        return
    end
    whichUnit:effect(options.effect)
    whichUnit:buffClear({ key = "invisible" })
end