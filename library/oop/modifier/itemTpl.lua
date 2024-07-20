local expander = ClassExpander(CLASS_EXPANDS_MOD, ItemTplClass)

---@param obj UnitTpl
expander["hp"] = function(obj)
    obj:prop("hpCur", obj:propData("hp"))
end