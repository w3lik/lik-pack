--[[
    模版技能 冻结|时间停止
    options = {
        whichUnit 目标单位
        duration 持续时间
        effect 绑定特效路径
        attach 绑定特效位置
        red 红偏0-255
        green 绿偏0-255
        blue 蓝偏0-255
        alpha 透明度0-255
    }
]]
---@param options {whichUnit:Unit,duration:number,effect:string,attach:string,red:number,green:number,blue:number,alpha:number}|noteAbilityBuff
function ability.freeze(options)
    local whichUnit = options.whichUnit
    if (whichUnit == nil) then
        return
    end
    if (not isClass(whichUnit, UnitClass) or whichUnit:isDead()) then
        return
    end
    local duration = options.duration or 0
    if (duration <= 0) then
        -- 假如没有设置时间，忽略
        return
    end
    local red = options.red or 255
    local green = options.green or 255
    local blue = options.blue or 255
    local alpha = options.alpha or 255
    local attach = options.attach or "origin"
    local b = whichUnit:buff("freeze"):signal(BUFF_SIGNAL.down)
    b:name(options.name)
    b:icon(options.icon)
    b:description(options.description)
    ---@param buffObj Unit
    b:duration(duration)
     :purpose(
        function(buffObj)
            buffObj:attach(options.effect, attach)
            buffObj:rgba(red, green, blue, alpha, duration)
            buffObj:superposition("pause", "+=1")
            buffObj:animateScale("-=1")
        end)
     :rollback(
        function(buffObj)
            buffObj:animateScale("+=1")
            buffObj:superposition("pause", "-=1")
            buffObj:detach(options.effect, attach)
        end)
     :run()
end