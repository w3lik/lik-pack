local expander = ClassExpander(CLASS_EXPANDS_SUP, ItemClass)

---@param obj Unit
expander["locust"] = function(obj)
    if (obj:handle() ~= nil) then
        obj:superpositionCale("locust",
            function()
                if (J.GetUnitAbilityLevel(obj:handle(), FRAMEWORK_ID["ability_locust"]) < 1) then
                    J.UnitAddAbility(obj:handle(), FRAMEWORK_ID["ability_locust"])
                end
            end, function()
                if (J.GetUnitAbilityLevel(obj:handle(), FRAMEWORK_ID["ability_locust"]) >= 1) then
                    J.UnitRemoveAbility(obj:handle(), FRAMEWORK_ID["ability_locust"])
                end
            end)
    end
end

---@param obj Unit
expander["invulnerable"] = function(obj)
    if (obj:handle() ~= nil) then
        obj:superpositionCale("invulnerable",
            function()
                if (J.GetUnitAbilityLevel(obj:handle(), FRAMEWORK_ID["ability_invulnerable"]) < 1) then
                    J.UnitAddAbility(obj:handle(), FRAMEWORK_ID["ability_invulnerable"])
                end
            end, function()
                if (J.GetUnitAbilityLevel(obj:handle(), FRAMEWORK_ID["ability_invulnerable"]) >= 1) then
                    J.UnitRemoveAbility(obj:handle(), FRAMEWORK_ID["ability_invulnerable"])
                end
            end)
    end
end