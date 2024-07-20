local expander = ClassExpander(CLASS_EXPANDS_NOR, FrameTextClass)

---@param value number
expander["textColor"] = function(_, value)
    value = math.max(0, value)
    value = math.min(255, value)
    return value
end

---@param value number
expander["fontSize"] = function(_, value)
    value = math.max(6, value)
    value = math.min(16, value)
    return value
end