---@class Class
local class = Class(AbstractClass)

---@private
function class:construct()
    ---@protected
    self._id = ObjectID(self._className)
    ---@protected
    self._prop = {}
    --
    oop._i2o[self._id] = self
    if (DEBUGGING) then
        if (oop._dbg[self._className] == nil) then
            oop._dbg[self._className] = setmetatable({}, { __mode = "v" })
        end
        oop._dbg[self._className][self._id] = self
    end
end

---@private
function class:destruct()
    if (sync.is()) then
        event.syncTrigger(self, EVENT.Object.Destruct, { triggerObject = self })
        self:buffClear()
        self:clear("buffs", true)
        href(self, nil)
        if (self._static ~= nil) then
            oop._static[self._static] = nil
        end
        -- 事件注销
        self._event = nil
    end
    oop._i2o[self._id] = nil
    if (DEBUGGING) then
        oop._dbg[self._className][self._id] = nil
    end
end

---@return string
function class:id()
    return self._id
end

---@return string
function class:className()
    return self._className
end

---@protected
---@param key string
---@param value any
function class:normalizer(key, value)
    if (value ~= nil) then
        local l = ClassExpander(CLASS_EXPANDS_NOR, self:className())
        if (type(l[key]) == "function") then
            value = l[key](self, value)
        end
    end
    return value
end

---@protected
---@param key string
---@param value any
function class:preposition(key, value)
    local eb = ClassExpander(CLASS_EXPANDS_PRE, self:className())
    if (type(eb[key]) == "function") then
        eb[key](self, self:normalizer(key, value))
    end
end

---@protected
---@param key string
---@param value any
---@return any
function class:limiter(key, value)
    local eb = ClassExpander(CLASS_EXPANDS_LMT, self:className())
    if (type(eb[key]) == "function") then
        value = eb[key](self, value)
    end
    return value
end

---@protected
---@param key string
---@param prev any
function class:modifier(key, prev)
    local exec, call
    local sk = string.sub(key, 1, 5)
    if (sk == SYMBOL_SUP) then
        exec = ClassExpander(CLASS_EXPANDS_SUP, self:className())
        call = exec[string.sub(key, 6)]
    else
        exec = ClassExpander(CLASS_EXPANDS_MOD, self:className())
        if (sk == SYMBOL_MUT) then
            local mk = string.sub(key, 6)
            call = exec[mk]
            local mut = prev or 0
            prev = self:propValue(mk)
            if (type(prev) == "number" and prev > 0 and mut ~= 0) then
                if (mut <= -100) then
                    prev = 0
                else
                    prev = prev * (1 + mut * 0.01)
                end
                prev = self:normalizer(key, prev)
            end
        else
            call = exec[key]
            if (type(prev) == "number" and prev > 0) then
                local mut = self:PROP(SYMBOL_MUT .. key) or 0
                if (mut <= -100) then
                    prev = 0
                else
                    prev = prev * (1 + mut * 0.01)
                end
                prev = self:normalizer(key, prev)
            end
        end
    end
    if (type(call) == "function") then
        local re = self:prop("restruct")
        if (isClass(re, ArrayClass) and false == re:keyExists(key)) then
            re:set(key, 1)
        end
        call(self, prev)
    end
end

---@protected
---@param key string
---@return any
function class:propValue(key, std, dyn)
    if (key == nil) then
        return
    end
    local aid = tostring(async._id)
    if (self._prop == nil) then
        error("PropValueIsNil" .. self:id())
        return
    end
    if (self._prop[aid] ~= nil) then
        if (std == nil) then
            std = self._prop[aid].std[key]
        end
        if (dyn == nil) then
            dyn = self._prop[aid].dyn[key]
        end
    end
    if (self._prop["0"] ~= nil) then
        if (std == nil) then
            std = self._prop["0"].std[key]
        end
        if (dyn == nil) then
            dyn = self._prop["0"].dyn[key]
        end
    end
    if (std == "__NIL__") then
        std = nil
    end
    if (dyn == "__NIL__") then
        dyn = nil
    end
    local val = std
    if (dyn ~= nil) then
        if (type(dyn) == "number") then
            val = (val or 0) + dyn
        else
            val = dyn
        end
    end
    return val
end

---@param key string
---@return any
function class:propData(key)
    local val = self:propValue(key)
    if (type(val) == "number") then
        if (val > 0 and key[1] ~= "<") then
            local mut = self:PROP(SYMBOL_MUT .. key) or 0
            if (mut ~= 0) then
                if (mut <= -100) then
                    val = 0
                else
                    val = val * (1 + mut * 0.01)
                end
            end
        end
        val = self:normalizer(key, val)
    end
    return val
end

---@protected
function class:propChange(key, space, setVal, isExec)
    must(type(key) == "string" and (space == "std" or space == "dyn"))
    if (type(isExec) ~= "boolean") then
        isExec = true
    end
    local aid = tostring(async._id)
    if (self._prop[aid] == nil) then
        self._prop[aid] = { std = {}, dyn = {} }
    end
    local oldVal = self:propValue(key)
    local newVal
    if (space == "std") then
        newVal = self:propValue(key, setVal, nil)
    elseif (space == "dyn") then
        newVal = self:propValue(key, nil, setVal)
    else
        return
    end
    local updated = (false == datum.equal(oldVal, newVal))
    if (updated) then
        local checkChange = event.checkPropChange(self:className(), key)
        if (true == checkChange and sync.is()) then
            event.syncTrigger(self, EVENT.Prop.BeforeChange, { key = key, old = oldVal, new = newVal })
        end
        isExec = isExec and (newVal ~= nil)
        if (isExec) then
            self:preposition(key, newVal)
        end
        if (setVal == "__NIL__") then
            setVal = nil
        end
        local pda = self._prop[aid]
        if (space == "std") then
            pda.std[key] = setVal
        elseif (space == "dyn") then
            pda.dyn[key] = setVal
        end
        if (true == checkChange and sync.is()) then
            event.syncTrigger(self, EVENT.Prop.Change, { key = key, old = oldVal, new = newVal })
        end
        if (isExec) then
            self:modifier(key, oldVal)
        end
    end
    return updated
end

---@private
---@param key string
---@param variety any
---@param duration number
---@return self,boolean|any,boolean
function class:PROP(key, variety, duration)
    if (key == nil and variety == nil and duration == nil) then
        error("prop")
    end
    if (type(duration) ~= "number") then
        duration = 0
    end
    if (type(variety) == "string") then
        local durc = string.explode(";", variety)
        if (#durc == 2) then
            local durc2 = tonumber(durc[2])
            if (type(durc2) == "number") then
                duration = math.max(0, durc2)
                variety = durc[1]
            end
        end
    end
    if (key == nil) then
        return nil, false
    end
    if (variety == nil) then
        return self:propData(key), false
    end
    local aid = tostring(async._id)
    if (self._prop[aid] == nil) then
        self._prop[aid] = { std = {}, dyn = {} }
    end
    --- 同步数据设置时，强制清理异步数据
    if (aid == "0") then
        for i = 1, BJ_MAX_PLAYERS do
            local si = tostring(i)
            if (self._prop[si]) then
                if (self._prop[si].std and self._prop[si].std[key]) then
                    self._prop[si].std[key] = nil
                end
                if (self._prop[si].dyn and self._prop[si].dyn[key]) then
                    self._prop[si].dyn[key] = nil
                end
            end
        end
    end
    
    local pda = self._prop[aid]
    
    local caleVal, diff = math.cale(variety, pda.std[key])
    if (caleVal == nil) then
        return self, false
    end
    
    -- 增幅 raise
    if (type(diff) == "number") then
        must(type(caleVal) == "number")
        if (diff ~= 0 and key[1] ~= "<") then
            local raise = self:PROP(SYMBOL_RAI .. key) or 0
            if raise ~= 0 then
                caleVal = caleVal - diff
                diff = diff * (raise * 0.01 + 1)
                caleVal = caleVal + diff
            end
        end
        local lmtVal = self:limiter(key, caleVal)
        diff = diff + (lmtVal - caleVal)
        caleVal = lmtVal
    end
    if (duration == nil) then
        duration = 0
    end
    if duration <= 0 then
        return self, self:propChange(key, "std", caleVal)
    end
    local tmpDyn
    if (type(diff) == "number") then
        if (diff == 0) then
            return self, false
        end
        tmpDyn = (pda.dyn[key] or 0) + diff
    else
        tmpDyn = caleVal
    end
    -- 同步时挂载Buff
    if (aid == "0") then
        local desc = {}
        local _, form, iai = attribute.conf(key)
        local signal
        if (type(diff) == "number") then
            if (diff >= 0) then
                if (iai) then
                    signal = BUFF_SIGNAL.down
                    desc[#desc + 1] = colour.hex(colour.indianred, "变化: +" .. diff .. form)
                else
                    signal = BUFF_SIGNAL.up
                    desc[#desc + 1] = colour.hex(colour.lawngreen, "变化: +" .. diff .. form)
                end
            else
                if (iai) then
                    signal = BUFF_SIGNAL.up
                    desc[#desc + 1] = colour.hex(colour.lawngreen, "变化: " .. diff .. form)
                else
                    signal = BUFF_SIGNAL.down
                    desc[#desc + 1] = colour.hex(colour.indianred, "变化: " .. diff .. form)
                end
            end
        end
        desc[#desc + 1] = "持续: " .. colour.hex(colour.skyblue, string.format("%0.1f", duration) .. " 秒")
        local bf = self:buff(key)
        bf:duration(duration):description(desc):signal(signal)
        bf:purpose(
            function(o)
                o:propChange(key, "dyn", tmpDyn)
            end)
          :rollback(
            function(o)
                if (type(pda.dyn[key]) == "number") then
                    local new = pda.dyn[key] - diff
                    o:propChange(key, "dyn", new)
                else
                    local cs = o:buffCatch({
                        forward = false,
                        key = key,
                        limit = 1,
                        filter = function(enumBuff) return enumBuff:id() ~= bf:id() end,
                    })
                    if (#cs > 0) then
                        cs[1]:purpose()(o)
                    else
                        o:propChange(key, "dyn", "__NIL__")
                    end
                end
            end)
          :run()
    else
        -- 异步时挂载计时器(只支持diff型)
        must(type(diff) == "number")
        self:propChange(key, "dyn", tmpDyn)
        async.setTimeout(duration * 60, function()
            if (type(pda.dyn[key]) == "number") then
                local new = pda.dyn[key] - diff
                self:propChange(key, "dyn", new)
            end
        end)
    end
    return self, true
end

--- 内部参
---@param key string
---@param variety any
---@param duration number
---@return self|any
function class:prop(key, variety, duration)
    local v = self:PROP(key, variety, duration)
    return v
end

--- 增幅，作用于[修改过程]的[改变]数值的增减
---@param key string
---@param modify number
---@param duration number
---@return self|number
function class:raise(key, modify, duration)
    local k = SYMBOL_RAI .. key
    return self:prop(k, modify, duration) or 0
end

--- 突变，作用于[获取时]的[终结]数值的突破增减
---@param key string
---@param modify number
---@param duration number
---@return self|number
function class:mutation(key, modify, duration)
    local k = SYMBOL_MUT .. key
    return self:prop(k, modify, duration) or 0
end

--- 叠加态，用于[判断时]叠加[结果]数值间的判断关系
---@param key string
---@param modify number
---@param duration number
---@return self|number
function class:superposition(key, modify, duration)
    local k = SYMBOL_SUP .. key
    return self:prop(k, modify, duration) or 0
end

--- 叠加态执行判断
---@param key string
---@param up function
---@param down function
---@return void
function class:superpositionCale(key, up, down)
    local data = self:propValue(SYMBOL_SUP .. key)
    local spl = self:prop("superposition")
    if (spl == nil) then
        spl = {}
        self:prop("superposition", spl)
    end
    if (spl[key] == nil) then
        spl[key] = false
    end
    if (data > 0 and false == spl[key]) then
        spl[key] = true
        up()
    elseif (data <= 0 and true == spl[key]) then
        spl[key] = false
        down()
    end
end

--- 清理内部参
---@param key string
---@return void
function class:clear(key, autoDestroy)
    local aid = tostring(async._id)
    local pda = self._prop[aid]
    if (pda ~= nil) then
        if (autoDestroy == true) then
            destroy(pda.std[key])
        end
        pda.std[key] = nil
        if (aid == "0") then
            for i = 1, BJ_MAX_PLAYERS do
                local si = tostring(i)
                if (self._prop[si]) then
                    if (self._prop[si].std and self._prop[si].std[key]) then
                        if (autoDestroy == true) then
                            destroy(self._prop[si].std[key])
                        end
                        self._prop[si].std[key] = nil
                    end
                    if (self._prop[si].dyn and self._prop[si].dyn[key]) then
                        if (autoDestroy == true) then
                            destroy(self._prop[si].dyn[key])
                        end
                        self._prop[si].dyn[key] = nil
                    end
                end
            end
        end
    end
end

---@param superName string
---@return self
function class:extend(superName)
    --- super
    setmetatable(self, { __index = Class(superName) })
    --- expands
    for _, e in ipairs(ClassExpands.kinds) do
        setmetatable(ClassExpander(e, self._className), { __index = ClassExpander(e, superName) })
    end
    return self
end

---@class Buff:BuffClass
---@param key string
---@return nil|Buff
function class:buff(key)
    must(type(key) == "string")
    return Object(BuffClass, {
        options = {
            obj = self,
            key = key,
        }
    })
end

---@protected
---@return Array|nil
function class:buffs()
    return self:prop("buffs")
end

--- buff提取器
---@alias forwardType boolean 正序(true)|反序(false)
---@alias buffFilter {forward:forwardType,key:string,name:string,signal:string,limit:number,filter:fun(enumBuff:Buff)}
---@param options buffFilter
---@return Buff[]
function class:buffCatch(options)
    local catch = {}
    local b = self:buffs()
    if (isClass(b, ArrayClass)) then
        local forward = true
        if (type(options) == "table") then
            if (type(options.forward) == "boolean") then
                forward = options.forward
            end
            if (type(options.limit) ~= "number") then
                options.limit = 100
            end
        end
        local des = {}
        ---@param enumBuff Buff
        local act = function(ek, enumBuff)
            if (isDestroy(enumBuff)) then
                des[#des + 1] = ek
                return
            end
            if (type(options) == "table") then
                if (#catch >= options.limit) then
                    return false
                end
                if (type(options.key) == "string") then
                    if (options.key ~= enumBuff:key()) then
                        return
                    end
                end
                if (type(options.name) == "string") then
                    if (options.name ~= enumBuff:name()) then
                        return
                    end
                end
                if (type(options.signal) == "string") then
                    if (options.signal ~= enumBuff:signal()) then
                        return
                    end
                end
                if (type(options.filter) == "function") then
                    if (options.filter(enumBuff) ~= true) then
                        return
                    end
                end
            end
            table.insert(catch, enumBuff)
        end
        if (forward) then
            b:forEach(act)
        else
            b:backEach(act)
        end
        for _, k in ipairs(des) do
            b:set(k, nil)
        end
    end
    return catch
end

--- buff某key数量
---@param key string
---@return number
function class:buffCount(key)
    local b = self:buffCatch({ key = key })
    return #b
end

--- buff某key获取1个
---@param key string
---@return Buff|nil
function class:buffOne(key)
    local b = self:buffCatch({ key = key, limit = 1 })
    if (#b > 0) then
        return b[1]
    end
end

--- buff某key是否存在
---@param key string
---@return boolean
function class:buffHas(key)
    return isClass(self:buffOne(key), BuffClass)
end

--- buff清理
---@param options buffFilter
function class:buffClear(options)
    local buffs = self:buffCatch(options)
    if (#buffs > 0) then
        for _, b in ipairs(buffs) do
            b:back()
        end
    end
end

--- 通用型对象事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onEvent(evt, ...)
    event.syncRegister(self, evt, ...)
    return self
end