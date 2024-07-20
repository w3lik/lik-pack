local expander = ClassExpander(CLASS_EXPANDS_NOR, BgmClass)

---@param value number
expander["volume"] = function(_, value)
    value = math.max(0, value)
    value = math.min(100, value)
    return value
end