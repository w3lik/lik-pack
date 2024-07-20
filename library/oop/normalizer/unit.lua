local expander = ClassExpander(CLASS_EXPANDS_NOR, UnitClass)

---@param value number
expander["attackSpace"] = function(_, value)
    value = math.max(0.1, value)
    value = math.min(5, value)
    return value
end

---@param value number
expander["attackSpaceBase"] = function(_, value)
    value = math.max(0, value)
    return value
end

---@param obj Unit
---@param value number
expander["attackRangeMin"] = function(obj, value)
    local v = obj:attackRange()
    if (v ~= nil) then
        value = math.min(v, value)
    end
    value = math.max(0, value)
    return value
end

---@param value number
expander["attackPoint"] = function(_, value)
    value = math.max(0, value)
    value = math.min(1.5, value)
    return value
end

---@param value number[]
expander["rgba"] = function(_, value)
    for i = 1, 4 do
        if (type(value[i]) == "number") then
            value[i] = math.floor(value[i])
            value[i] = math.max(0, value[i])
            value[i] = math.min(255, value[i])
        end
    end
    return value
end

---@param value number
expander["flyHeight"] = function(_, value)
    value = math.floor(value)
    value = math.min(1500, math.max(0, value))
    return value
end

---@param obj Unit
---@param value number
expander["exp"] = function(obj, value)
    if ((obj:level() or 0) < 1) then
        return 0
    else
        value = math.max(0, value)
        value = math.min(Game():unitExpNeeds(Game():unitLevelMax()), value)
        return value
    end
end

---@param value number
expander["levelMax"] = function(_, value)
    value = math.min(Game():unitLevelMax(), value)
    return math.round(value)
end

---@param obj Unit
---@param value number
expander["level"] = function(obj, value)
    value = math.min(obj:levelMax(), value)
    return math.round(value)
end

---@param value number
expander["hp"] = function(_, value)
    return math.max(1, value)
end

---@param obj Unit
---@param value number
expander["hpCur"] = function(obj, value)
    local v = obj:hp()
    if (v ~= nil) then
        value = math.min(v, value)
    end
    value = math.max(0, value)
    return value
end

---@param value number
expander["mp"] = function(_, value)
    return math.max(0, value)
end

---@param obj Unit
---@param value number
expander["mpCur"] = function(obj, value)
    local v = obj:mp()
    if (v ~= nil) then
        value = math.min(v, value)
    end
    value = math.max(0, value)
    return value
end

---@param value number
expander["shield"] = function(_, value)
    return math.max(0, value)
end

---@param obj Unit
---@param value number
expander["shieldCur"] = function(obj, value)
    local v = obj:propData("shield") or 0
    value = math.min(v, value)
    value = math.max(0, value)
    return value
end