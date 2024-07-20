---@class Flow:FlowClass
---@param key string
---@return Flow|nil
function Flow(key)
    must(type(key) == "string")
    return Object(FlowClass, {
        protect = true,
        static = key,
        options = {
            key = key,
        }
    })
end

---@param key string
---@param data table
---@return void
function FlowRun(key, data)
    must(type(key) == "string")
    local fl = Flow(key)
    if (isClass(fl, FlowClass)) then
        fl:run(data)
    end
end
