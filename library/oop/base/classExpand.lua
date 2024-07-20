---@type table<string,table>
ClassExpands = ClassExpands or {}

---@type string[]
ClassExpands.kinds = ClassExpands.kinds or {
    CLASS_EXPANDS_PRE,
    CLASS_EXPANDS_LMT,
    CLASS_EXPANDS_MOD,
    CLASS_EXPANDS_NOR,
    CLASS_EXPANDS_SUP,
}

for _, e in ipairs(ClassExpands.kinds) do
    if (ClassExpands['_' .. e] == nil) then
        ClassExpands['_' .. e] = {}
    end
end

function ClassExpander(k, n)
    local ce = ClassExpands['_' .. k]
    if (ce[n] == nil) then
        ce[n] = {}
    end
    return ce[n]
end