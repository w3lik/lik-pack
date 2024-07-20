local expander = ClassExpander(CLASS_EXPANDS_NOR, FrameCustomClass)

---@param value number
expander["alpha"] = function(_, value)
    value = math.max(0, value)
    value = math.min(255, value)
    return value
end