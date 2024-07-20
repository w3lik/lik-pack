--[[
    指针定义
    也就是鼠标行为
]]
---@alias evtOnMouseMoveData {triggerPlayer:Player,rx:number,ry:number}
---@alias evtOnMouseLeftClickData {triggerPlayer:Player,rx:number,ry:number}
---@alias evtOnMouseRightClickData {triggerPlayer:Player,rx:number,ry:number}
---@alias cursorQuoteStart fun():boolean 调用开始时的预设执行,当返回false时(不包含nil)，跳过后面的流程
---@alias cursorQuoteOver fun():void 调用结束时的预设执行
---@alias cursorQuoteRefresh fun(evtData:evtOnMouseMoveData):void 刷新操作的预设执行
---@alias cursorQuoteOnLeftClick fun(evtData:evtOnMouseLeftClickData):void 左键点击操作的预设执行
---@alias cursorQuoteOnRightClick fun(evtData:evtOnMouseRightClickData):void 右键点击操作的预设执行
---@alias cursorQuoteOptions {start:cursorQuoteStart,over:cursorQuoteOver,refresh:cursorQuoteRefresh,leftClick:cursorQuoteOnLeftClick,rightClick:cursorQuoteOnRightClick}
---@class cursor
cursor = cursor or {}

---@type string 默认指针名
cursor._default = cursor._default or "default"
---@type table<string,cursorQuoteOptions>
cursor._list = cursor._list or {}
---@type table<string,boolean>
cursor._status = cursor._status or {}
---@type string 临时key
cursor._key = cursor._key or nil
---@type table 临时数据
cursor._data = cursor._data or nil

--- 预先设置引用指针是否生效
---@param key string
---@param status boolean
---@return void
function cursor.setStatus(key, status)
    sync.must()
    must(type(status) == "boolean")
    cursor._status[key] = status
end

--- 获取引用指针生效状态，默认生效
---@param key string
---@return boolean
function cursor.getStatus(key)
    return cursor._status[key] or false
end

--- 预先配置引用指针
---@param key string
---@param options cursorQuoteOptions
---@return void
function cursor.setQuote(key, options)
    sync.must()
    cursor._list[key] = options
    if (cursor._status[key] == nil) then
        cursor._status[key] = true -- 默认配置为生效
    end
end

--- 获取指针配置
---@param key string
---@return cursorQuoteOptions|nil
function cursor.getQuote(key)
    return cursor._list[key]
end

--- 对象调用指针
---@param key string
---@param data any
---@return void
function cursor.quote(key, data)
    async.must()
    local quote = cursor.getQuote(key)
    if (nil == quote) then
        return
    end
    local status = cursor.getStatus(key)
    if (status ~= true) then
        return
    end
    cursor._key = key
    cursor._data = data
    --- 当start流程返回false时(不包含nil)，跳过后面的流程
    if (type(quote.start) == "function") then
        if (false == quote.start()) then
            cursor.quoteOver()
            return
        end
    end
    if (type(quote.refresh) == "function") then
        quote.refresh({
            triggerPlayer = PlayerLocal(),
            rx = japi.MouseRX(),
            ry = japi.MouseRY(),
        })
        ---@param evtData evtOnMouseMoveData
        event.asyncRegister("mouse", EVENT.Mouse.Instant, "_lk_m_i", function(evtData)
            quote.refresh(evtData)
        end)
    end
    if (type(quote.leftClick) == "function") then
        ---@param evtData evtOnMouseLeftClickData
        mouse.onLeftClick("_lk_m_lc", function(evtData)
            quote.leftClick(evtData)
            return false
        end)
    end
    if (type(quote.rightClick) == "function") then
        ---@param evtData evtOnMouseRightClickData
        mouse.onRightClick("_lk_m_rc", function(evtData)
            quote.rightClick(evtData)
            return false
        end)
    end
end

--- 强制终止当前调用指针
--- 如有默认指针，则尝试切回默认指针
---@param key string 限定终止某个key的指针，若当前指针key不是指定的key，则无效
---@return void
function cursor.quoteOver(key)
    async.must()
    if (cursor._key == nil) then
        return
    end
    if (type(key) == "string" and cursor._key ~= key) then
        return
    end
    local quote = cursor.getQuote(cursor._key)
    if (quote == nil) then
        return
    end
    event.asyncRegister("mouse", EVENT.Mouse.Instant, "_lk_m_i", nil)
    mouse.onLeftClick("_lk_m_lc", nil)
    mouse.onRightClick("_lk_m_rc", nil)
    if (type(quote.over) == "function") then
        quote.over()
    end
    cursor._key = nil
    cursor._data = nil
    cursor.quote(cursor._default) -- 尝试切回默认指针
end

--- 配置默认指针
--- 当需要使用自定义默认指针时，使用此方法配置常驻的默认指针
---@param options cursorQuoteOptions
---@return void
function cursor.setDefault(options)
    cursor.setQuote(cursor._default, options)
    async.call(PlayerLocal(), function()
        cursor.quote(cursor._default) -- 默认指针默认启动
    end)
end

--- 当前调用指针的key
---@return string
function cursor.currentKey()
    return cursor._key
end

--- 当前调用指针的data
---@return {object:Object,ability:Ability,frame:Frame,texture:string,size:number[]} 预想数据非标准
function cursor.currentData()
    return cursor._data or {}
end

--- 是否引用中
---@return boolean
function cursor.isQuoting()
    return cursor._key ~= nil and cursor._key ~= cursor._default
end

--- 是否拖拽中
---@return boolean
function cursor.isDragging()
    return cursor.currentKey() == "drag"
end
--- 是否跟踪图层中
---@return boolean
function cursor.isFollowing()
    return cursor.currentKey() == "follow"
end
