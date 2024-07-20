local expander = ClassExpander(CLASS_EXPANDS_MOD, FrameCustomClass)

---@param obj FrameCustom
expander["alpha"] = function(obj)
    japi.DZ_FrameSetAlpha(obj:handle(), obj:propData("alpha"))
end