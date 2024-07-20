---@class GameClass:Class
local class = Class(GameClass)

---@private
function class:construct()
    local qty = 0
    for i = 0, BJ_MAX_PLAYERS - 1 do
        if ((J.GetPlayerController(J.Player(i)) == MAP_CONTROL_USER) and (J.GetPlayerSlotState(J.Player(i)) == PLAYER_SLOT_STATE_PLAYING)) then
            qty = qty + 1
        end
    end
    self:prop("isStarted", false)
    self:prop("name", FRAMEWORK_MAP_NAME)
    self:prop("description", Array())
    self:prop("playingQuantityStart", qty)
    self:prop("playingQuantity", qty)
    self:prop("syncCallback", {})
    self:prop("commands", {})
    self:prop("worth", Array())
    self:prop("abilityHotkey", {})
    self:prop("abilityLevelMax", 0) -- [技能]最大等级数
    self:prop("abilityExpFixed", 0) -- [技能]每级需要经验固定值
    self:prop("abilityExpRatio", 0) -- [技能]每级需要经验对上一级提升百分比(默认固定提升)
    self:prop("abilityExpLimit", 0) -- [技能]每级需要经验上限
    self:prop("itemHotkey", {}) -- [物品]栏热键配置
    self:prop("itemLevelMax", 0) -- [物品]最大等级数
    self:prop("itemExpFixed", 0) -- [物品]每级需要经验固定值
    self:prop("itemExpRatio", 0) -- [物品]每级需要经验对上一级提升百分比(默认固定提升)
    self:prop("itemExpLimit", 0) -- [物品]每级需要经验上限
    self:prop("itemKeyBoardRecord", {})
    self:prop("itemActionDistance", 200)
    self:prop("itemPickMode", ITEM_PICK_MODE.itemWarehouse)
    self:prop("unitLevelMax", 0) -- [单位]最大等级数
    self:prop("unitExpFixed", 0) -- [单位]每级需要经验固定值
    self:prop("unitExpRatio", 0) -- [单位]每级需要经验对上一级提升百分比(默认固定提升)
    self:prop("unitExpLimit", 0) -- [单位]每级需要经验上限
    self:prop("warehouseSlot", 18) -- 玩家仓库容量(鉴于set,这里使用18为默认值)
    self:prop("regulateUI", Array()) -- 使之无效的UI列表，默认为空
    self:prop("hideInterface", false)
end

--- 游戏是否已启动
---@return boolean
function class:isStarted()
    return self:prop("isStarted")
end

--- 游戏名字（地图名字）
---@param modify string|nil
---@return self|string
function class:name(modify)
    return self:prop("name", modify)
end

--- 开始玩家数
---@return number
function class:playingQuantityStart()
    return self:prop("playingQuantityStart")
end

--- 正在游戏的玩家数
---@param modify number|nil
---@return self|number
function class:playingQuantity(modify)
    return self:prop("playingQuantity", modify)
end

--- 定义某个key游戏描述体设置
---@alias noteGameDescriptionSetting fun(this:Object,options:table):string[]|string
---@param key string
---@param descSetting noteGameDescriptionSetting
---@return noteGameDescriptionSetting|nil
function class:defineDescription(key, descSetting)
    if (type(descSetting) == "function") then
        ---@type Array
        local desc = self:prop("description")
        desc:set(key, descSetting)
    end
    return self
end

--- 获取游戏描述设置
---@vararg string
---@param obj Tpl
---@param options table
---@vararg table
---@return string[]
function class:combineDescription(obj, options, ...)
    local joiner = {}
    ---@type Array
    local desc = self:prop("description")
    options = options or {}
    local _join
    _join = function(ts)
        if (type(ts) == "string") then
            if (string.subPos(ts, "|n") == -1) then
                table.insert(joiner, ts)
            else
                _join(string.explode("|n", ts))
            end
        elseif (type(ts) == "table") then
            for _, v in ipairs(ts) do
                _join(v)
            end
        end
    end
    for _, data in ipairs({ ... }) do
        if (type(data) == "string" and data == SYMBOL_D) then
            _join(obj:description())
        elseif (type(data) == "string" and desc:keyExists(data)) then
            _join(desc:get(data)(obj, options))
        else
            _join(data)
        end
    end
    return joiner
end

--- 设置战争迷雾
---@param enableFog boolean
---@return self
function class:fog(enableFog)
    J.FogEnable(enableFog)
    return self
end

--- 设置黑色阴影
---@param enableMark boolean
---@return self
function class:mark(enableMark)
    J.FogMaskEnable(enableMark)
    return self
end

--- 游戏技能栏热键
--- 当param为字符串数组时，设置键值
--- 当param为字符、字符串时，返回对应键值设置
--- 当param为nil时，返回所有设置
---@see file variable/keyboard
---@param param nil|number|string[]
---@return self|string|string[]
function class:abilityHotkey(param)
    if (type(param) == "table") then
        local prev = self:prop("abilityHotkey")
        if (type(prev) == "table") then
            for _, key in ipairs(prev) do
                keyboard.onRelease(KEYBOARD[key], "abilityHotkey", nil)
            end
        end
        for idx, key in ipairs(param) do
            keyboard.onRelease(KEYBOARD[key], "abilityHotkey", function(evtData)
                local selection = evtData.triggerPlayer:selection()
                if (isClass(selection, UnitClass) == false) then
                    return
                end
                local abilitySlot = selection:abilitySlot()
                if (abilitySlot == nil) then
                    return
                end
                local ab = abilitySlot:storage()[idx]
                if (isClass(ab, AbilityClass)) then
                    cursor.quote(ab:targetType(), { ability = ab })
                end
            end)
        end
        return self:prop("abilityHotkey", param)
    end
    if (type(param) == "number") then
        return self:prop("abilityHotkey")[param] or ''
    else
        return self:prop("abilityHotkey")
    end
end

--- 游戏技能升级经验机制
---@param max number 最大等级
---@param fixed number 每级固定需要经验
---@param ratio number 每级对应上一级需要经验的加成数
---@param limit number 每级需要经验上限，当fixed、ratio计算超过这个值的时候进行约束
---@return self|number,number,number,number
function class:abilityUpgrade(max, fixed, ratio, limit)
    local isModify = max or fixed or ratio or limit
    if (max) then
        self:prop("abilityLevelMax", max)
    end
    if (fixed) then
        self:prop("abilityExpFixed", fixed)
    end
    if (ratio) then
        self:prop("abilityExpRatio", ratio)
    end
    if (limit) then
        self:prop("abilityExpLimit", limit)
    end
    local _max = self:prop("abilityLevelMax") or 1
    local _fixed = self:prop("abilityExpFixed") or 100
    local _radio = self:prop("abilityExpRatio") or 1.00
    local _limit = self:prop("abilityExpLimit") or 10000
    if (isModify) then
        self:prop("abilityExpNeeds", math.expNeeds(_max, _fixed, _radio, _limit))
        return self
    end
    return _max, _fixed, _radio, _limit
end

--- 游戏技能升级最大级
---@return number
function class:abilityLevelMax()
    return self:prop("abilityLevelMax")
end

--- 游戏技能升级经验需要条件
---@param whichLevel number
---@return number|number[]
function class:abilityExpNeeds(whichLevel)
    local ns = self:prop("abilityExpNeeds")
    must(type(ns) == "table")
    if (type(whichLevel) == "number") then
        return ns[whichLevel] or 0
    else
        return ns
    end
end

--- 游戏物品栏热键
--- 当param为字符串数组时，设置键值
--- 当param为数字时，返回对应键值设置
--- 当param为nil时，返回所有设置
---@see file variable/keyboard
---@param param nil|number|string[]
---@return self|string|string[]
function class:itemHotkey(param)
    if (type(param) == "table") then
        local prev = self:prop("abilityHotkey")
        if (type(prev) == "table") then
            for _, key in ipairs(prev) do
                keyboard.onRelease(KEYBOARD[key], "itemHotkey", nil)
            end
        end
        for idx, key in ipairs(param) do
            keyboard.onRelease(KEYBOARD[key], "itemHotkey", function(evtData)
                local selection = evtData.triggerPlayer:selection()
                if (isClass(selection, UnitClass) == false) then
                    return
                end
                local itemSlot = selection:itemSlot()
                if (itemSlot == nil) then
                    return
                end
                local it = itemSlot:storage()[idx]
                if (isClass(it, ItemClass)) then
                    local ab = it:ability()
                    if (isClass(ab, AbilityClass)) then
                        cursor.quote(ab:targetType(), { ability = ab })
                    end
                end
            end)
        end
        return self:prop("itemHotkey", param)
    end
    if (type(param) == "number") then
        return self:prop("itemHotkey")[param] or ''
    else
        return self:prop("itemHotkey")
    end
end

--- 游戏物品升级经验机制
---@param max number 最大等级
---@param fixed number 每级固定需要经验
---@param ratio number 每级对应上一级需要经验的加成数
---@param limit number 每级需要经验上限，当fixed、ratio计算超过这个值的时候进行约束
---@return self|number,number,number,number
function class:itemUpgrade(max, fixed, ratio, limit)
    local isModify = max or fixed or ratio or limit
    if (max) then
        self:prop("itemLevelMax", max)
    end
    if (fixed) then
        self:prop("itemExpFixed", fixed)
    end
    if (ratio) then
        self:prop("itemExpRatio", ratio)
    end
    if (limit) then
        self:prop("itemExpLimit", limit)
    end
    local _max = self:prop("itemLevelMax") or 1
    local _fixed = self:prop("itemExpFixed") or 100
    local _radio = self:prop("itemExpRatio") or 1.00
    local _limit = self:prop("itemExpLimit") or 10000
    if (isModify) then
        self:prop("itemExpNeeds", math.expNeeds(_max, _fixed, _radio, _limit))
        return self
    end
    return _max, _fixed, _radio, _limit
end

--- 游戏物品升级最大级
---@return number
function class:itemLevelMax()
    return self:prop("itemLevelMax")
end

--- 游戏物品升级经验需要条件
---@param whichLevel number
---@return number|number[]
function class:itemExpNeeds(whichLevel)
    local ns = self:prop("itemExpNeeds")
    must(type(ns) == "table")
    if (type(whichLevel) == "number") then
        return ns[whichLevel] or 0
    else
        return ns
    end
end

--- 游戏物品行为判断距离(默认200)
--- 如捡取、丢弃、传递等
---@param modify number
---@return number
function class:itemActionDistance(modify)
    return self:prop("itemActionDistance", modify)
end

--- 物品捡取模式
--- 默认捡去物品栏，满了转移至仓库
---@see file variable/prop ITEM_PICK_MODE
---@param modify table|nil
---@return self|table
function class:itemPickMode(modify)
    return self:prop("itemPickMode", modify)
end

--- 游戏单位升级经验机制
---@param max number 最大等级
---@param fixed number 每级固定需要经验
---@param ratio number 每级对应上一级需要经验的加成数
---@param limit number 每级需要经验上限，当fixed、ratio计算超过这个值的时候进行约束
---@return self|number,number,number,number
function class:unitUpgrade(max, fixed, ratio, limit)
    local isModify = max or fixed or ratio or limit
    if (max) then
        self:prop("unitLevelMax", max)
    end
    if (fixed) then
        self:prop("unitExpFixed", fixed)
    end
    if (ratio) then
        self:prop("unitExpRatio", ratio)
    end
    if (limit) then
        self:prop("unitExpLimit", limit)
    end
    local _max = self:prop("unitLevelMax") or 1
    local _fixed = self:prop("unitExpFixed") or 100
    local _radio = self:prop("unitExpRatio") or 1.00
    local _limit = self:prop("unitExpLimit") or 10000
    if (isModify) then
        self:prop("unitExpNeeds", math.expNeeds(_max, _fixed, _radio, _limit))
        return self
    end
    return _max, _fixed, _radio, _limit
end

--- 游戏单位升级最大级
---@return number
function class:unitLevelMax()
    return self:prop("unitLevelMax")
end

--- 游戏单位升级经验需要条件
---@param whichLevel number
---@return number|number[]
function class:unitExpNeeds(whichLevel)
    local ns = self:prop("unitExpNeeds")
    must(type(ns) == "table")
    if (type(whichLevel) == "number") then
        return ns[whichLevel] or 0
    else
        return ns
    end
end

--- 玩家仓库容量机制
---@param modify number
---@return self|number
function class:warehouseSlot(modify)
    if (type(modify) == "number") then
        return self:prop("warehouseSlot", modify)
    end
    return self:prop("warehouseSlot")
end

--- 撤销指令
---@param pattern string 正则字符串
---@return self
function class:unCommand(pattern)
    if (type(pattern) == "string") then
        for i = 1, BJ_MAX_PLAYERS, 1 do
            Player(i):onChat(pattern, nil)
        end
    end
    return self
end

--- 配置这局游戏支持的框架指令
---@param pattern string 正则字符串
---@param callFunc fun(evtData:noteOnPlayerChatData)
---@return self
function class:command(pattern, callFunc)
    if (type(pattern) == "string") then
        for i = 1, BJ_MAX_PLAYERS, 1 do
            Player(i):onChat(pattern, callFunc)
        end
    end
    return self
end

--- 游戏财物规则
---@example Game():worth("lumber","木头",{"gold",1000000})
---@example Game():worth("gold","黄金")
---@param key string 财物key
---@param name string 财物名词
---@param convert table 等价物
---@return self|Array|number
function class:worth(key, name, convert)
    ---@type Array
    local wor = self:prop("worth")
    if (key ~= nil and name ~= nil) then
        wor:set(key, { name = name, convert = convert })
        self:clear("worthConvert")
        return self
    end
    if (key == nil) then
        return wor
    end
    return wor:get(key)
end

--- 获取游戏财物转化规则
---@param key string
---@return Array|table
function class:worthConvert(key)
    local cov = self:prop("worthConvert")
    if (cov == nil) then
        local wor = self:prop("worth")
        cov = Array()
        self:prop("worthConvert", cov)
        wor:forEach(function(k, v)
            if (v.convert ~= nil) then
                cov:set(v.convert[1], { k, v.convert[2] })
            end
        end)
    end
    if (key == nil) then
        return cov
    end
    return cov:get(key)
end

--- 游戏财物换算（Upper 2 Lower）
--- 将上级财物尽可能地换算为最下级财物单位
--- data = { gold = 1,silver = 1,copper = 0}
--- 得到 { gold = 0, silver = 0, copper = 10100 }
---@param data table
---@return table
function class:worthU2L(data)
    local turn = {}
    if (type(data) == "table") then
        ---@type Array
        local cvt = self:worthConvert()
        local rev = {}
        local keys = cvt:keys()
        self:worth():forEach(function(key, _)
            local value = cvt:get(key)
            if (value) then
                rev[value[1]] = { key, value[2] }
                turn[key] = data[key] or 0
            else
                turn[key] = data[key]
            end
        end)
        local run = true
        while (run) do
            local count = 0
            for _, k in ipairs(keys) do
                if (rev[k] ~= nil) then
                    if (turn[rev[k][1]] == nil) then
                        turn[rev[k][1]] = 0
                    end
                    if (turn[k] ~= 0) then
                        turn[rev[k][1]] = turn[rev[k][1]] + turn[k] * rev[k][2]
                        turn[k] = 0
                        count = count + 1
                    end
                end
            end
            run = (count > 0)
        end
    end
    return turn
end

--- 游戏财物换算（Lower 2 Upper）
--- 将上级财物尽可能地换算为最下级财物单位
--- data = { copper = 10100}
--- 得到 { gold = 1,silver = 1,copper = 0}
---@param data table
---@return table
function class:worthL2U(data)
    local turn = {}
    if (type(data) == "table") then
        ---@type Array
        local cvt = self:worthConvert()
        local rev = {}
        local keys = cvt:keys()
        self:worth():forEach(function(key, _)
            local value = cvt:get(key)
            if (value) then
                rev[key] = { value[1], value[2] }
                turn[key] = data[key] or 0
            else
                turn[key] = data[key]
            end
        end)
        local run = true
        while (run) do
            local count = 0
            for _, k in ipairs(keys) do
                if (rev[k] ~= nil) then
                    for i = 10, 0, -1 do
                        local d = math.floor(10 ^ i)
                        local rd = rev[k][2] * d
                        while (turn[k] >= rd) do
                            turn[k] = turn[k] - rd
                            turn[rev[k][1]] = (turn[rev[k][1]] or 0) + d
                            count = count + 1
                        end
                    end
                end
            end
            run = (count > 0)
        end
    end
    return turn
end

--- 游戏财物比例计算,如:
--- 乘除可算比例，加减可算相互计算
--- worthCale({gold=100}, "*", 0.5)
--- worthCale({gold=100}, "/", 2)
--- worthCale(3, "*", {gold=100})
--- worthCale({gold=100}, "+", {gold=100})
--- worthCale({gold=100}, "-", {gold=100})
---@param data1 table|number
---@param operator string "+"|"-"|"*"|"/"
---@param data2 table|number
---@return Array|table
function class:worthCale(data1, operator, data2)
    local keys = self:worth():keys()
    local res
    if (operator == "*" or operator == "/") then
        local ratio = 0
        if (type(data1) == "table" or type(data2) == "number") then
            res = self:worthU2L(data1)
            ratio = data2
        end
        if (type(data1) == "number" or type(data2) == "table") then
            res = self:worthU2L(data2)
            ratio = data1
        end
        for _, k in ipairs(keys) do
            if (type(res[k]) == "number") then
                if (operator == "*") then
                    res[k] = res[k] * ratio
                elseif (operator == "/") then
                    res[k] = res[k] / ratio
                end
            end
        end
    elseif (operator == "+" or operator == "-") then
        if (type(data1) == "table" and type(data2) == "table") then
            res = self:worthU2L(data1)
            data2 = self:worthU2L(data2)
            for _, k in ipairs(keys) do
                res[k] = res[k] or 0
                if (type(data2[k]) == "number") then
                    if (operator == "+") then
                        res[k] = res[k] + data2[k]
                    elseif (operator == "-") then
                        res[k] = res[k] - data2[k]
                    end
                end
            end
        end
    end
    if (res == nil) then
        print("wrong cale")
        return data1
    end
    return self:worthL2U(res)
end

--- 采取 floor 的取整结果
---@param data table
---@return table
function class:worthFloor(data)
    data = self:worthU2L(data)
    for _, k in ipairs(self:worth():keys()) do
        if (type(data[k]) == "number") then
            data[k] = math.floor(data[k])
        end
    end
    return self:worthL2U(data)
end

--- 采取 ceil 的取整结果
---@param data table
---@return table
function class:worthCeil(data)
    data = self:worthU2L(data)
    for _, k in ipairs(self:worth():keys()) do
        if (type(data[k]) == "number") then
            data[k] = math.ceil(data[k])
        end
    end
    return self:worthL2U(data)
end

--- 采取 round 的取整结果
---@param data table
---@return table
function class:worthRound(data)
    data = self:worthU2L(data)
    for _, k in ipairs(self:worth():keys()) do
        if (type(data[k]) == "number") then
            data[k] = math.round(data[k])
        end
    end
    return self:worthL2U(data)
end

--- 在财物转化规则下，比较两个数据集的大小
--- 1大于2 返回true
--- 1小于2 返回false
--- 相等 返回 0（数据不相应时，没法比较）
--- 没法比较 返回nil
--[[ 如
    data1 = { gold = 1,silver = 1,copper = 0}
    data2 = { gold = 0,silver = 77,copper = 33}
    1 > 2
]]
---@param data1 table
---@param data2 table
---@return boolean|nil
function class:worthCompare(data1, data2)
    if (data1 == nil or data2 == nil) then
        return nil
    end
    local lower1 = self:worthU2L(data1)
    local lower2 = self:worthU2L(data2)
    local keys = self:worth():keys()
    local result = { g = 0, l = 0 }
    for _, k in ipairs(keys) do
        local d1 = lower1[k] or 0
        local d2 = lower2[k] or 0
        if (d1 > d2) then
            result.g = result.g + 1
        elseif (d1 < d2) then
            result.l = result.l + 1
        end
    end
    if (result.g == 0 and result.l == 0) then
        return 0
    end
    if (result.g > 0 and result.l > 0) then
        return nil
    end
    if (result.g > 0) then
        return true
    end
    if (result.l > 0) then
        return false
    end
end

--- 判断财物1是否 等价于 财物2
--- 无法比较时为false
---@param data1 table
---@param data2 table
---@return boolean
function class:worthEqual(data1, data2)
    return self:worthCompare(data1, data2) == 0
end

--- 判断财物1是否 大于 财物2
--- 无法比较时为false
---@param data1 table
---@param data2 table
---@return boolean
function class:worthGreater(data1, data2)
    return self:worthCompare(data1, data2) == true
end

--- 判断财物1是否 小于 财物2
--- 无法比较时为false
---@param data1 table
---@param data2 table
---@return boolean
function class:worthLess(data1, data2)
    return self:worthCompare(data1, data2) == false
end

--- 判断财物1是否 大于等于 财物2
--- 无法比较时为false
---@param data1 table
---@param data2 table
---@return boolean
function class:worthEqualOrGreater(data1, data2)
    local res = self:worthCompare(data1, data2)
    return res == true or res == 0
end

--- 判断财物1是否 小于等于 财物2
--- 无法比较时为false
---@param data1 table
---@param data2 table
---@return boolean
function class:worthEqualOrLess(data1, data2)
    local res = self:worthCompare(data1, data2)
    return res == false or res == 0
end

--- 规限UI(使之无效的UI列表，默认为空)
---@param frame Frame Frame对象
---@param disable boolean 当不设置时，返回该frame是否被规限的状态
---@return nil|boolean
function class:regulateUI(frame, disable)
    if (instanceof(frame, FrameClass) == false) then
        return
    end
    ---@type Array
    local regulate = self:prop("regulateUI")
    local fid = frame:id()
    local ex = regulate:keyExists(fid)
    if (type(disable) == "boolean") then
        if (disable == true) then
            if (frame:show() == true) then
                frame:show(false)
            end
            regulate:set(fid, frame)
        else
            regulate:set(fid, nil)
        end
        return
    end
    return ex
end

--- 是否初始化时隐藏原生UI
--- 必须在游戏开始之前设置才有效
---@param modify boolean|nil
---@return self|boolean
function class:hideInterface(modify)
    return self:prop("hideInterface", modify)
end