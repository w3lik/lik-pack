local expander = ClassExpander(CLASS_EXPANDS_MOD, PlayerClass)

---@param obj Player
expander["name"] = function(obj)
    J.SetPlayerName(obj:handle(), obj:propData("name"))
end

---@param obj Player
expander["race"] = function(obj)
    obj:skin(obj:propData("race"))
end

---@param obj Player
expander["teamColor"] = function(obj)
    local data = obj:propData("teamColor")
    J.SetPlayerColor(obj:handle(), PLAYER_COLOR[data])
    Group():forEach(UnitClass, {
        func = function(enumUnit)
            return enumUnit:isAlive() and obj:id() == enumUnit:owner():id()
        end
    }, function(enumUnit)
        enumUnit:teamColor(data)
    end)
end

---@param obj Player
expander["worth"] = function(obj, prev)
    if (prev ~= nil) then
        event.syncTrigger(obj, EVENT.Player.WorthChange)
    end
end