local expander = ClassExpander(CLASS_EXPANDS_SUP, UnitClass)

---@param obj Unit
expander["dead"] = function(obj)
    obj:superpositionCale("dead",
        function()
            obj:superposition("interrupt", "+=1")
        end, function()
            obj:superposition("interrupt", "-=1")
        end)
end

---@param obj Unit
expander["stun"] = function(obj)
    obj:superpositionCale("stun",
        function()
            obj:superposition("interrupt", "+=1")
        end, function()
            obj:superposition("interrupt", "-=1")
        end)
end

---@param obj Unit
expander["crackFly"] = function(obj)
    obj:superpositionCale("crackFly",
        function()
            obj:superposition("interrupt", "+=1")
        end, function()
            obj:superposition("interrupt", "-=1")
        end)
end

---@param obj Unit
expander["silent"] = function(obj)
    obj:superpositionCale("silent",
        function()
            obj:superposition("interrupt", "+=1")
        end, function()
            obj:superposition("interrupt", "-=1")
        end)
end

---@param obj Unit
expander["whirlwind"] = function(obj)
    obj:superpositionCale("whirlwind",
        function()
            obj:superposition("interrupt", "+=1")
        end, function()
            obj:superposition("interrupt", "-=1")
        end)
end

---@param obj Unit
expander["interrupt"] = function(obj)
    obj:superpositionCale("interrupt",
        function()
            event.syncTrigger(obj, EVENT.Unit.InterruptIn)
        end, function()
            event.syncTrigger(obj, EVENT.Unit.InterruptOut)
        end)
end

---@param obj Unit
expander["noPath"] = function(obj)
    obj:superpositionCale("noPath",
        function()
            J.SetUnitPathing(obj:handle(), false)
        end, function()
            J.SetUnitPathing(obj:handle(), true)
        end)
end

---@param obj Unit
expander["locust"] = function(obj)
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

---@param obj Unit
expander["noAttack"] = function(obj)
    obj:superpositionCale("noAttack",
        function()
            japi.DZ_UnitDisableAttack(obj:handle(), true)
        end, function()
            japi.DZ_UnitDisableAttack(obj:handle(), false)
        end)
end

---@param obj Unit
expander["invulnerable"] = function(obj)
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

---@param obj Unit
expander["invisible"] = function(obj)
    obj:superpositionCale("invisible",
        function()
            if (J.GetUnitAbilityLevel(obj:handle(), FRAMEWORK_ID["ability_invisible"]) < 1) then
                J.UnitAddAbility(obj:handle(), FRAMEWORK_ID["ability_invisible"])
            end
        end, function()
            if (J.GetUnitAbilityLevel(obj:handle(), FRAMEWORK_ID["ability_invisible"]) >= 1) then
                J.UnitRemoveAbility(obj:handle(), FRAMEWORK_ID["ability_invisible"])
            end
        end)
end

---@param obj Unit
expander["pause"] = function(obj)
    obj:superpositionCale("pause",
        function()
            J.PauseUnit(obj:handle(), true)
        end, function()
            J.PauseUnit(obj:handle(), false)
        end)
end

---@param obj Unit
expander["hide"] = function(obj)
    obj:superpositionCale("hide",
        function()
            J.ShowUnit(obj:handle(), false)
        end, function()
            J.ShowUnit(obj:handle(), true)
        end)
end