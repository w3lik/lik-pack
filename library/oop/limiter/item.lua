local expander = ClassExpander(CLASS_EXPANDS_LMT, ItemClass)

---@param obj Item
expander["hpCur"] = function(obj, value)
    local v = obj:propData("hp")
    if (type(v) == "number") then
        value = math.min(value, v)
        value = math.max(value, 0)
    end
    return value
end
