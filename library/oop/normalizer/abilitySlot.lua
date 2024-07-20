local expander = ClassExpander(CLASS_EXPANDS_NOR, AbilitySlotClass)

---@param value number
expander["abilityPoint"] = function(_, value)
    return math.floor(value)
end