local expander = ClassExpander(CLASS_EXPANDS_NOR, LightningClass)

---@param value number
expander["position"] = function(_, value)
    value[1] = math.min(value[1], RegionWorld:xMax())
    value[1] = math.max(value[1], RegionWorld:xMin())
    value[2] = math.min(value[2], RegionWorld:yMax())
    value[2] = math.max(value[2], RegionWorld:yMin())
    value[4] = math.min(value[4], RegionWorld:xMax())
    value[4] = math.max(value[4], RegionWorld:xMin())
    value[5] = math.min(value[5], RegionWorld:yMax())
    value[5] = math.max(value[5], RegionWorld:yMin())
    return value
end