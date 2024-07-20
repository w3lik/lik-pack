-- 对象事件，管理事件的注册及触发
event = event or {}

---@private
event._condition = event._condition or {}
---@private
event._react = event._react or {}
---@private
event._sync = event._sync or {}
---@private
event._async = event._async or {}
---@private
event._propChange = event._propChange or nil

--- 设置事件数据
---@param symbol string|Object 标识物
---@param evtKind string 事件类型
---@param key string|nil 特定键值判断
---@param callFunc function|nil 特定键值判断，为空时清除数据
---@return void
function event.set(source, symbol, evtKind, key, callFunc)
    local src
    if (source == event._react) then
        -- 反应事件时
        src = event._react
    elseif (type(symbol) == "string") then
        -- 字符串事件时
        if (source[symbol] == nil) then
            source[symbol] = {}
        end
        src = source[symbol]
    elseif (type(symbol) == "table") then
        -- 对象事件时
        if (symbol._event == nil) then
            symbol._event = {}
        end
        src = symbol._event
    end
    if (nil == src) then
        return
    end
    if (type(evtKind) ~= "string" and type(key) ~= "string") then
        return
    end
    if (src[evtKind] == nil) then
        src[evtKind] = Array()
    end
    src[evtKind]:set(key, callFunc)
end

--- 获取事件数据
---@param source table
---@param symbol string|Object 标识物
---@param evtKind string|nil 事件类型，可为空
---@param key string|nil 特定键值判断，可为空
---@return table<string,Array>|Array|function|nil
function event.get(source, symbol, evtKind, key)
    local src
    if (source == event._react) then
        -- 反应事件时
        src = event._react
    elseif (type(symbol) == "string") then
        -- 字符标识事件时
        src = source[symbol]
    elseif (type(symbol) == "table") then
        -- 对象事件时
        src = symbol._event
    end
    if (nil == src) then
        return
    end
    if (type(evtKind) == "string") then
        src = src[evtKind] -- Array
    end
    if (type(key) == "string") then
        src = src:get(key) -- function
    end
    return src
end

-------------------------------- 原生 --------------------------------

--- 触发原生条件注入
--- 使用一个handle，以不同的conditionAction累计计数
--- 分配触发到回调注册
--- 注入的action是不会被同一个handle注册两次的，与on事件并不相同
---@param conditionFunc number
---@param regEvent function
---@return void
function event.condition(conditionFunc, regEvent)
    if (type(regEvent) ~= "function") then
        return
    end
    local id = J.GetHandleId(conditionFunc)
    -- 如果这个handle已经注册过此动作，则不重复注册
    local tgr = event._condition[id]
    if (nil == tgr) then
        tgr = J.CreateTrigger()
        J.HandleRef(tgr)
        J.TriggerAddCondition(tgr, conditionFunc)
        event._condition[id] = tgr
    end
    regEvent(event._condition[id])
end

-------------------------------- 反应 --------------------------------

--- 注销反应事件
---@param evtKind string 事件类型
---@param key string|nil
---@return void
function event.reactUnregister(evtKind, key)
    event.set(event._react, nil, evtKind, key, nil)
end

--- 注册反应事件
---@param evtKind string 事件类型
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return void
function event.reactRegister(evtKind, ...)
    local key, func = datum.keyFunc(...)
    event.set(event._react, nil, evtKind, key, func)
end

--- 拥有反应事件
---@param evtKind string 事件类型
---@param key string|nil 特定键值判断
---@return boolean
function event.reactHas(evtKind, key)
    return type(evtKind) == "string" and nil ~= event.get(event._react, nil, evtKind, key)
end

--- 触发反应事件
---@param evtKind string 事件类型
---@param triggerData table
---@return void
function event.reactTrigger(evtKind, triggerData)
    if (isClass(event._react[evtKind], ArrayClass)) then
        event._react[evtKind]:forEach(function(_, val)
            if (type(val) == "function") then
                J.Promise(val, nil, nil, triggerData)
            end
        end)
    end
end

-------------------------------- 同步 --------------------------------

--- 是否拥有同步事件
---@param symbol string|Object
---@param evtKind string 事件类型
---@param key string|nil 特定键值判断
---@return boolean
function event.syncHas(symbol, evtKind, key)
    return type(evtKind) == "string" and nil ~= event.get(event._sync, symbol, evtKind, key)
end

--- 注销同步事件|同步事件集
---@param symbol string|Object
---@param evtKind string 事件类型
---@param key string|nil
---@return void
function event.syncUnregister(symbol, evtKind, key)
    sync.must()
    event.set(event._sync, symbol, evtKind, key, nil)
end

--- 注册同步事件
--- 这是根据 key 值决定的，key 默认就是default，需要的时候可以自定义
---@param symbol string|Object
---@param evtKind string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return void
function event.syncRegister(symbol, evtKind, ...)
    sync.must()
    local key, func = datum.keyFunc(...)
    event.set(event._sync, symbol, evtKind, key, func)
end

--- 触发同步事件
--- 同步事件会尝试触发事件反应
---@param symbol string|Object
---@param evtKind string 事件类型
---@param triggerData table
---@return void
function event.syncTrigger(symbol, evtKind, triggerData)
    sync.must()
    if (symbol == nil or evtKind == nil) then
        return
    end
    -- 数据
    triggerData = triggerData or {}
    if (type(symbol) == "table") then
        triggerData["trigger" .. symbol._className] = symbol
    end
    -- 反应
    event.reactTrigger(evtKind, triggerData)
    -- 判断事件注册执行与否
    local reg = event.get(event._sync, symbol, evtKind)
    if (isClass(reg, ArrayClass)) then
        if (reg:count() > 0) then
            reg:forEach(function(_, callFunc)
                J.Promise(callFunc, nil, nil, triggerData)
            end)
        end
    end
end

-------------------------------- 异步 --------------------------------

--- 是否拥有异步事件
---@param symbol string|Object
---@param evtKind string 事件类型
---@param key string|nil 特定键值判断
---@return boolean
function event.asyncHas(symbol, evtKind, key)
    return type(evtKind) == "string" and nil ~= event.get(event._async, symbol, evtKind, key)
end

--- 注销异步事件|异步事件集
---@param symbol string|Object
---@param evtKind string 事件类型
---@param key string|nil
---@return void
function event.asyncUnregister(symbol, evtKind, key)
    event.set(event._async, symbol, evtKind, key, nil)
end

--- 注册异步事件
--- 这是根据 key 值决定的，key 默认就是default，需要的时候可以自定义
---@param symbol string|Object
---@param evtKind string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return void
function event.asyncRegister(symbol, evtKind, ...)
    local key, func = datum.keyFunc(...)
    event.set(event._async, symbol, evtKind, key, func)
end

--- 触发异步事件
--- 异步事件不会触发事件反应
---@param symbol string|Object
---@param evtKind string 事件类型
---@param triggerData table
---@return void
function event.asyncTrigger(symbol, evtKind, triggerData)
    if (symbol == nil or evtKind == nil) then
        return
    end
    -- 数据
    triggerData = triggerData or {}
    if (type(symbol) == "table") then
        local cn = symbol._className
        if (string.sub(cn, 1, 5) == "Frame") then
            triggerData.triggerFrame = symbol
        else
            triggerData["trigger" .. cn] = symbol
        end
    end
    -- 判断事件注册执行与否
    local reg = event.get(event._async, symbol, evtKind)
    if (isClass(reg, ArrayClass)) then
        if (reg:count() > 0) then
            reg:forEach(function(_, callFunc)
                J.Promise(callFunc, nil, nil, triggerData)
            end)
        end
    end
end

-------------------------------- 保留 --------------------------------

--- 参变判定配置
--- 可配置nil、any或字符串表[string]boolean
---@deprecated
---@alias notePropConfigs nil|"any"|table<string,boolean>
---@param configs nil|"any"|table<string,notePropConfigs>
---@return void
function event.confPropChange(configs)
    if (configs ~= nil and configs ~= "any" and type(configs) ~= "table") then
        configs = nil
    end
    event._propChange = configs
end

--- 参变判定检查
---@deprecated
---@param className string
---@param key string
---@return boolean
function event.checkPropChange(className, key)
    if (type(event._propChange) ~= "table") then
        return true
    end
    local conf = event._propChange[className]
    if (type(conf) ~= "table") then
        return true
    end
    return conf[key] == true
end