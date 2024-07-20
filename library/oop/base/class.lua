---@type table<string,Class>
Classes = Classes or {}

---@param name string
---@return Class
function Class(name)
    if (name == nil) then
        stack()
    end
    if (Classes[name] == nil) then
        if (name == AbstractClass) then
            Classes[name] = { _type = "Class", _className = name }
        else
            Classes[name] = setmetatable({ _className = name }, { __index = Classes[AbstractClass] })
        end
    end
    return Classes[name]
end