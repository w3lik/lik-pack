local expander = ClassExpander(CLASS_EXPANDS_NOR, AbilityClass)

---@param value number
expander["exp"] = function(_, value)
    value = math.max(0, value)
    value = math.min(Game():abilityExpNeeds(Game():abilityLevelMax()), value)
    return math.ceil(value)
end

---@param value number
expander["levelMax"] = function(_, value)
    value = math.min(Game():abilityLevelMax(), value)
    return math.round(value)
end

expander["levelUpNeedPoint"] = function(_, value)
    return math.round(value)
end

---@param obj Ability
---@param value number
expander["level"] = function(obj, value)
    value = math.min(obj:prop("levelMax"), value)
    return math.round(value)
end