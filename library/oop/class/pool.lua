---@alias PoolEnum any
---@class PoolClass:Class
local class = Class(PoolClass)

---@private
function class:construct(options)
    self:prop("name", options.name)
    self:prop("data", Array())
end

---@private
function class:destruct()
    self:clear("data", true)
end

--- 组名词
---@return string
function class:name()
    return self:prop("name")
end

--- 组数据
---@return Array
function class:data()
    return self:prop("data")
end

--- 组统计
---@return Array
function class:count()
    return self:data():count()
end

--- 插入对象
---@param obj PoolEnum
---@return void
function class:insert(obj)
    if (isDestroy(obj)) then
        return
    end
    local d = self:data()
    if (d ~= nil and false == d:keyExists(obj:id())) then
        d:set(obj:id(), obj)
    end
end

--- 删除对象
---@param obj PoolEnum
---@return void
function class:remove(obj)
    if (isDestroy(obj)) then
        return
    end
    local d = self:data()
    if (d ~= nil and d:keyExists(obj:id())) then
        d:set(obj:id(), nil)
    end
end

--- 删除所有对象
---@return void
function class:removeAll()
    self:prop("data"):construct()
end

--- 获取组内随机1|N个对象
--- 此方法不能超出符合捕获条件的数量极限
---@return PoolEnum|PoolEnum[]
function class:rand(n)
    local data = self:data()
    n = n or 1
    if (#data >= 1) then
        local m = math.min(#data, n)
        local r = table.rand(data, m)
        if (n == 1) then
            return r
        elseif (m == 1) then
            return { r }
        else
            return r
        end
    else
        if (n == 1) then
            return nil
        else
            return {}
        end
    end
end

--- 正向遍历对象组
---@param action fun(enumObj:PoolEnum):void
---@return void
function class:forEach(action)
    if (type(action) == "function") then
        local data = self:data()
        data:forEach(function(_, enumObj)
            return action(enumObj)
        end)
    end
end

--- 反向遍历对象组
---@param action fun(enumObj:PoolEnum):void
---@return void
function class:backEach(action)
    if (type(action) == "function") then
        local data = self:data()
        data:backEach(function(_, enumObj)
            return action(enumObj)
        end)
    end
end

--- 乱序遍历对象组
---@param action fun(enumObj:PoolEnum):void
---@return void
function class:randEach(action)
    if (type(action) == "function") then
        local data = self:data()
        local count = data:count()
        if (count > 0) then
            local ks = table.rand(data:keys(), count)
            for _, k in ipairs(ks) do
                return action(data:get(k))
            end
        end
    end
end