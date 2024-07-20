---@class ArrayClass:Class
local class = Class(ArrayClass)

---@private
function class:construct()
    self._c = nil
    self._d = {
        key = {},
        k2v = {},
    }
end

--- 返回数组中元素的数目
---@return number integer
function class:count()
    return #self._d.key
end

--- 返回数组中key索引的顺序；没有该key则返回-1
---@param key string
---@return number
function class:index(key)
    local idx = -1
    for ki, k in ipairs(self._d.key) do
        if (k == key) then
            idx = ki
            break
        end
    end
    return idx
end

--- 设置数组元素
---@param key string|number
---@param val any
---@return void
function class:set(key, val)
    if (type(key) == "number") then
        if (self._d.key[key] == nil) then
            error("Set_NumberIndex_MustAlreadyExist")
        else
            key = self._d.key[key]
        end
    end
    if (type(key) ~= "string") then
        return
    end
    if (val == nil) then
        local i = self:index(key)
        if (i ~= -1) then
            table.remove(self._d.key, i)
        end
    else
        if (self._d.k2v[key] == nil) then
            self._d.key[#self._d.key + 1] = key
        end
    end
    self._d.k2v[key] = val
end

--- 根据key获取数据
---@param key string
---@return any
function class:get(key)
    if (type(key) == "number") then
        if (self._d.key[key] == nil) then
            error("GetIndexMustAlreadyExist")
        else
            key = self._d.key[key]
        end
    end
    if (type(key) ~= "string") then
        return
    end
    return self._d.k2v[key]
end

--- 返回数组中所有的键名
---@return string[]
function class:keys()
    return self._d.key
end

--- 返回数组中所有的值
---@return any[]
function class:values()
    local values = {}
    for _, key in ipairs(self._d.key) do
        values[#values + 1] = self._d.k2v[key]
    end
    return values
end

--- 检查指定的键名是否存在于数组中
function class:keyExists(key)
    return key ~= nil and self._d.k2v[key] ~= nil
end

--- 遍历
---@param callFunc fun(key:string,val:any):void
function class:forEach(callFunc)
    if (type(callFunc) == "function") then
        local keys = self._d.key
        local i = 1
        while i <= #keys do
            local k = keys[i]
            local v = self._d.k2v[k]
            if v == nil then
                table.remove(self._d.key, i)
                self._d.k2v[k] = nil
            else
                if (false == callFunc(k, v)) then
                    break
                end
                i = i + 1
            end
        end
    end
end

--- 反向遍历
---@param callFunc fun(key:string,val:any):void
function class:backEach(callFunc)
    if (type(callFunc) == "function") then
        local keys = self._d.key
        local i = #keys
        while i >= 1 do
            local k = keys[i]
            if (k ~= nil) then
                local v = self._d.k2v[k]
                if v == nil then
                    table.remove(self._d.key, i)
                    self._d.k2v[k] = nil
                else
                    if (false == callFunc(k, v)) then
                        break
                    end
                end
            end
            i = i - 1
        end
    end
end

--- 克隆一个副本
---@return Array
function class:clone()
    local copy = Array()
    self:forEach(function(key, val)
        if (isClass(val, ArrayClass)) then
            copy:set(key, val:clone())
        else
            copy:set(key, val)
        end
    end)
    return copy
end

--- 合并Array
---@vararg Array
---@return void
function class:merge(...)
    for _, arr in ipairs(...) do
        if (isClass(arr, ArrayClass)) then
            arr:forEach(function(key, val)
                if (isClass(val, ArrayClass)) then
                    self:set(key, self:clone())
                else
                    self:set(key, val)
                end
            end)
        end
    end
end

--- 键排序
---@return Array
function class:sort()
    local sa = self:clone()
    table.sort(sa._d.key)
    return sa
end