local expander = ClassExpander(CLASS_EXPANDS_NOR, VwpClass)

---@param value number
expander["volume"] = function(_, value)
    value = math.max(0, value)
    value = math.min(127, value)
    return math.floor(value)
end