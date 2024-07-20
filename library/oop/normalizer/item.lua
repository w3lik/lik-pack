local expander = ClassExpander(CLASS_EXPANDS_NOR, ItemClass)

---@param value number
expander["levelMax"] = function(_, value)
    value = math.min(Game():itemLevelMax(), value)
    return math.round(value)
end

---@param obj Item
---@param value number
expander["level"] = function(obj, value)
    value = math.min(obj:levelMax(), value)
    return math.round(value)
end

---@param value number
expander["charges"] = function(_, value)
    value = math.max(0, value)
    return math.round(value)
end

---@param value number
expander["hp"] = function(_, value)
    return math.max(1, value)
end

---@param obj Unit
---@param value number
expander["hpCur"] = function(obj, value)
    if (obj:hp() ~= nil) then
        value = math.min(obj:hp(), value)
    end
    value = math.max(0, value)
    return value
end