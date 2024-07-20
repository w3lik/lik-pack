local expander = ClassExpander(CLASS_EXPANDS_MOD, FrameModelClass)

---@param obj FrameModel
expander["model"] = function(obj)
    japi.DZ_FrameSetModel(obj:handle(), obj:propData("model"), 0, 0)
end

---@param obj FrameModel
expander["animate"] = function(obj)
    japi.DZ_FrameSetAnimate(obj:handle(), table.unpack(obj:propData("animate")))
end