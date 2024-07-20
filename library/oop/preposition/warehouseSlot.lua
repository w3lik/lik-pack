local expander = ClassExpander(CLASS_EXPANDS_PRE, WarehouseSlotClass)

---@param obj Unit
expander["volume"] = function(obj, value)
    local prev = obj:prop("volume")
    local s = obj:storage()
    if (s ~= nil and prev > value) then
        for i = (value + 1), prev do
            if (isClass(s[i], ItemClass)) then
                s[i]:drop()
            end
        end
    end
end
