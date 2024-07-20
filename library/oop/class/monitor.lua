--- 监听器是一种工具，用于管理周期性操作
---@class MonitorClass:Class
local class = Class(MonitorClass)

---@private
function class:construct(options)
    self:prop("key", options.key)
    self:prop("objects", Array())
end

---@private
function class:destruct()
    self:clear("refreshTimer", true)
    self:clear("objects", true)
end

---@return string
function class:key()
    return self:prop("key")
end

--- 运转
---@private
function class:setup()
    local refreshTimer = self:prop("refreshTimer")
    if (isClass(refreshTimer, TimerClass)) then
        self:clear("refreshTimer", true)
        refreshTimer = nil
    end
    local frequency = self:prop("frequency")
    local actionFunc = self:prop("actionFunc")
    local objects = self:prop("objects")
    if (type(frequency) == "number" and type(actionFunc) == "function" and objects:count() > 0) then
        self:prop("refreshTimer", time.setInterval(frequency, function(curTimer)
            ---@type Array
            if (objects == nil or objects:count() <= 0) then
                destroy(curTimer)
                self:clear("refreshTimer")
                return
            end
            local ignoreFilter = self:prop("ignoreFilter")
            objects:forEach(function(id, o)
                if (o == nil or (type(ignoreFilter) == "function" and ignoreFilter(o) == true)) then
                    objects:set(id, nil)
                    return
                end
                J.Promise(actionFunc, nil, nil, o)
            end)
        end))
    end
end

--- 监听器的运转周期
---@param modify number 周期间隔(秒)，每个周期会把受监听对象回调
---@return self|number
function class:frequency(modify)
    if (modify ~= nil) then
        self:prop("frequency", modify)
        self:setup()
        return self
    end
    return self:prop("frequency")
end

--- 监听器的运转函数
---@alias noteMonAction fun(object: any):void
---@param modify noteMonAction | "function(object) end" 监听操作
---@return self|number
function class:actionFunc(modify)
    if (modify) then
        if (type(modify) == "function") then
            self:prop("actionFunc", modify)
        else
            self:clear("actionFunc")
        end
        self:setup()
        return self
    end
    return self:prop("actionFunc")
end

--- 监听器的跳出函数
---@alias noteMonRemoveFilter fun(object: any):boolean
---@param modify noteMonRemoveFilter | "function(object) end" 移除监听对象的适配条件
---@return self|number
function class:ignoreFilter(modify)
    if (modify) then
        if (type(modify) == "function") then
            self:prop("ignoreFilter", modify)
        else
            self:clear("ignoreFilter")
        end
        self:setup()
        return self
    end
    return self:prop("ignoreFilter")
end

--- 检查一个对象是否正在受到监听
---@param obj Object 监听对象
---@return boolean
function class:isListening(obj)
    if (obj == nil) then
        return false
    end
    ---@type Array
    local objects = self:prop("objects")
    if (isClass(objects, ArrayClass)) then
        return objects:keyExists(obj:id())
    end
    return false
end

--- 监听对象
---@param obj Object 监听对象
---@return void
function class:listen(obj)
    must(type(obj) == "table")
    ---@type Array
    local objects = self:prop("objects")
    if (isClass(objects, ArrayClass)) then
        objects:set(obj:id(), obj)
    end
    local refreshTimer = self:prop("refreshTimer")
    if (isClass(refreshTimer, TimerClass) == false) then
        self:setup()
    end
end

--- 忽略对象
--- 由于监听器的特殊性和长效性
--- 不建议手动忽略，推荐在 create 时严谨地编写 ignoreFilter 中返回true从而自动忽略
---@protected
---@param obj Object 监听对象
---@return void
function class:ignore(obj)
    must(type(obj) == "table")
    ---@type Array
    local objects = self:prop("objects")
    if (isClass(objects, ArrayClass)) then
        objects:set(obj:id(), nil)
    end
end