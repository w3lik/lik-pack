local expander = ClassExpander(CLASS_EXPANDS_MOD, DialogClass)

---@param obj Dialog
expander["title"] = function(obj)
    J.DialogSetMessage(obj:handle(), obj:propData("title"))
end