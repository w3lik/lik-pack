---@class FlowClass:Class
local class = Class(FlowClass)

---@private
function class:construct(options)
    self:prop("key", options.key)
    self:prop("actions", Array())
end

---@private
function class:destruct()
    self:clear("actions", true)
end

--- key
---@return number
function class:key()
    return self:prop("key")
end

--- 执行组
---@return Array
function class:actions()
    return self:prop("actions")
end

--- 伤害过程中止条件
---@alias noteFlowAbort fun(data:table):boolean
---@param modify noteFlowAbort|nil
---@return self|noteFlowAbort
function class:abort(modify)
    if (type(modify) == "function") then
        return self:prop("abort", modify)
    end
    return self:prop("abort")
end

--- 伤害过程顺序设定
---@param key string
---@param callFunc fun(data:table):void
function class:set(key, callFunc)
    self:actions():set(key, callFunc)
end

--- 伤害过程执行
function class:run(data)
    local actions = self:actions()
    if (actions:count() > 0) then
        data = data or {}
        local cond = self:abort()
        actions:forEach(function(_, callFunc)
            J.Promise(callFunc, nil, nil, data)
            if (type(cond) == "function") then
                return not cond(data)
            end
        end)
    end
end