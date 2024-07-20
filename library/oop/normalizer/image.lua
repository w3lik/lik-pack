local expander = ClassExpander(CLASS_EXPANDS_NOR, ImageClass)

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