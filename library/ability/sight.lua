---@param whichUnit Unit
---@param value number 目标白天视野值
function ability.sight(whichUnit, value)
    local h = whichUnit:handle()
    local diff = math.floor(value - whichUnit:sightBase())
    for _, v in ipairs(FRAMEWORK_ID["sight_gradient"]) do
        if (J.GetUnitAbilityLevel(h, FRAMEWORK_ID["sight"].add[v]) > 0) then
            J.UnitRemoveAbility(h, FRAMEWORK_ID["sight"].add[v])
        end
        if (J.GetUnitAbilityLevel(h, FRAMEWORK_ID["sight"].sub[v]) > 0) then
            J.UnitRemoveAbility(h, FRAMEWORK_ID["sight"].sub[v])
        end
    end
    local tempVal = math.round(math.abs(diff))
    local sight_gradient = table.clone(FRAMEWORK_ID["sight_gradient"])
    if (tempVal ~= 0) then
        while (true) do
            local flag = false
            for i, v in ipairs(sight_gradient) do
                if (tempVal >= v) then
                    tempVal = math.round(tempVal - v)
                    table.remove(sight_gradient, i)
                    if (diff > 0) then
                        if (J.GetUnitAbilityLevel(h, FRAMEWORK_ID["sight"].add[v]) == 0) then
                            J.UnitAddAbility(h, FRAMEWORK_ID["sight"].add[v])
                        end
                    else
                        if (J.GetUnitAbilityLevel(h, FRAMEWORK_ID["sight"].sub[v]) == 0) then
                            J.UnitAddAbility(h, FRAMEWORK_ID["sight"].sub[v])
                        end
                    end
                    flag = true
                    break
                end
            end
            if (flag == false) then
                break
            end
        end
    end
end