---@class PlayerClass:Class
local class = Class(PlayerClass)

---@private
function class:construct(options)
    href(self, J.Player(options.index - 1))
    self:prop("index", options.index) -- 玩家索引[1-16]
    self:prop("mapLv", math.max(1, japi.DZ_Map_GetMapLevel(self:handle()) or 1))
    self:prop("isRedVip", japi.KK_Map_IsRedVIP(self:handle()) or false) -- 红VIP
    self:prop("isBlueVip", japi.KK_Map_IsBlueVIP(self:handle()) or false) -- 蓝VIP
    self:prop("isPlatformVIP", japi.DZ_Map_IsPlatformVIP(self:handle()) or false) -- 平台VIP
    self:prop("apm", 0)
    self:prop("isUser", J.GetPlayerController(self:handle()) == MAP_CONTROL_USER)
    self:prop("isComputer", J.GetPlayerController(self:handle()) == MAP_CONTROL_COMPUTER or J.GetPlayerSlotState(self:handle()) ~= PLAYER_SLOT_STATE_PLAYING)
    self:prop("name", J.GetPlayerName(self:handle()))
    self:prop("team", J.GetPlayerTeam(self:handle()))
    self:prop("teamColor", options.index)
    self:prop("prestige", "-") -- 称号
    self:prop("worth", {})
    self:prop("worthRatio", 100)
    self:prop("sellRatio", 50) --售卖折价率
    self:prop("chatPattern", Array()) --聊天内容
    self:prop("warehouseSlotObj", WarehouseSlot(self)) --仓库
    local pRace = J.GetPlayerRace(self:handle())
    if (pRace == RACE_UNDEAD or pRace == RACE_PREF_UNDEAD or pRace == RACE_DEMON or pRace == RACE_PREF_DEMON) then
        self:prop("race", RACE_UNDEAD_NAME)
    elseif (pRace == RACE_NIGHTELF or pRace == RACE_PREF_NIGHTELF) then
        self:prop("race", RACE_NIGHTELF_NAME)
    elseif (pRace == RACE_ORC or pRace == RACE_PREF_ORC) then
        self:prop("race", RACE_ORC_NAME)
    else
        self:prop("race", RACE_HUMAN_NAME)
    end
    self:prop("skin", self:prop("race"))
    local pSlotState = J.GetPlayerSlotState(self:handle())
    if (pSlotState == PLAYER_SLOT_STATE_EMPTY) then
        self:prop("status", PLAYER_STATUS.empty)
    elseif (pSlotState == PLAYER_SLOT_STATE_PLAYING) then
        self:prop("status", PLAYER_STATUS.playing)
    elseif (pSlotState == PLAYER_SLOT_STATE_LEFT) then
        self:prop("status", PLAYER_STATUS.leave)
    end
    J.SetPlayerHandicapXP(self:handle(), 0) -- 经验置0
    --叠加态(叠加态可以轻松管理可叠层的状态控制)
    self:superposition("hurt", 0) --受到伤害态
    self:superposition("damage", 0) --造成伤害态
    self:superposition("mark", 0) --贴图显示态
    --evt
    event.condition(player._evtDead, function(tgr)
        J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_DEATH, nil)
    end)
    event.condition(player._evtAttacked, function(tgr)
        J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_ATTACKED, nil)
    end)
    event.condition(player._evtOrder, function(tgr)
        J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
        J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    end)
    if (false == self:prop("isComputer")) then
        event.condition(player._evtLeave, function(tgr)
            J.TriggerRegisterPlayerEvent(tgr, self:handle(), EVENT_PLAYER_LEAVE)
        end)
        event.condition(player._evtEsc, function(tgr)
            J.TriggerRegisterPlayerEvent(tgr, self:handle(), EVENT_PLAYER_END_CINEMATIC)
        end)
        event.condition(player._evtChat, function(tgr)
            J.TriggerRegisterPlayerChatEvent(tgr, self:handle(), "", false)
        end)
        event.condition(player._evtSelection, function(tgr)
            J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_SELECTED, nil)
        end)
        event.condition(player._evtDeSelection, function(tgr)
            J.TriggerRegisterPlayerUnitEvent(tgr, self:handle(), EVENT_PLAYER_UNIT_DESELECTED, nil)
        end)
    end
end

---@private
function class:destruct()
    self:clear("warehouseSlotObj", true)
end

--- 玩家选择单位 n 次
---@param n number integer
---@param callFunc fun(evtData:noteOnPlayerSelectUnitData)
---@return self
function class:onSelectUnit(n, callFunc)
    event.syncRegister(self, EVENT.Player.SelectUnit .. "#" .. n, callFunc)
    return self
end

--- 玩家选择物品 n 次
---@param n number integer
---@param callFunc fun(evtData:noteOnPlayerSelectItemData)
---@return self
function class:onSelectItem(n, callFunc)
    event.syncRegister(self, EVENT.Player.SelectItem .. "#" .. n, callFunc)
    return self
end

--- 当聊天时
---@param pattern string 正则匹配内容
---@param callFunc fun(evtData:noteOnPlayerChatData)
---@return self
function class:onChat(pattern, callFunc)
    if (false == event.syncHas(self, EVENT.Player.Chat)) then
        event.syncRegister(self, EVENT.Player.Chat, function(evtData)
            ---@type Array
            local chatPattern = self:prop("chatPattern")
            chatPattern:forEach(function(p, c)
                local m = string.match(evtData.chatString, p)
                if (m ~= nil) then
                    evtData.matchedString = m
                    J.Promise(c, nil, nil, evtData)
                end
            end)
        end)
    end
    ---@type Array
    local chatPattern = self:prop("chatPattern")
    if (type(callFunc) == "function") then
        chatPattern:set(pattern, callFunc)
    else
        chatPattern:set(pattern, nil)
    end
    return self
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 是否中立玩家
---@return boolean
function class:isNeutral()
    return self:prop("index") >= 13
end

--- 是否电脑(如果位置为电脑玩家或无玩家，则为true)【常用来判断电脑AI是否开启】
---@return boolean
function class:isComputer()
    return self:prop("isComputer")
end

--- 是否玩家位置(如果位置为真实玩家或为空，则为true；而如果选择了电脑玩家补充，则为false)【常用来判断该是否玩家可填补位置】
---@return boolean
function class:isUser()
    return self:prop("isUser")
end

--- 是否正在游戏
---@return boolean
function class:isPlaying()
    return self:prop("status") == PLAYER_STATUS.playing
end

--- 是否红V
---@return boolean
function class:isRedVip()
    return self:prop("isRedVip")
end

--- 是否蓝V
---@return boolean
function class:isBlueVip()
    return self:prop("isBlueVip")
end

--- 是否平台VIP
---@return boolean
function class:isPlatformVIP()
    return self:prop("isPlatformVIP")
end

--- 是否正在受伤
---@return boolean
function class:isHurting()
    return self:superposition("hurt") > 0
end

--- 是否正在造成伤害
---@return boolean
function class:isDamaging()
    return self:superposition("damage") > 0
end

--- 是否有屏幕贴图正在展示
---@return boolean
function class:isMarking()
    return self:superposition("mark") > 0
end

--- 单位是否在某玩家真实视野内
---@param whichObj Unit|Item
---@return boolean
function class:isDetectedUnit(whichObj)
    if (isClass(whichObj, UnitClass) or isClass(whichObj, ItemClass)) then
        return J.IsUnitDetected(whichObj:handle(), self:handle()) == true
    end
    return false
end

--- 单位是否对某玩家不可见
---@param whichObj Unit|Item
---@return boolean
function class:isInvisibleUnit(whichObj)
    if (isClass(whichObj, UnitClass) or isClass(whichObj, ItemClass)) then
        return J.IsUnitInvisible(whichObj:handle(), self:handle()) == true
    end
    return false
end

--- 坐标是否对某玩家不可见
---@param x number
---@param y number
---@return boolean
function class:isInvisible(x, y)
    return J.IsVisibleToPlayer(x, y, self:handle()) == true
end

--- 坐标是否对某玩家存在迷雾
---@param x number
---@param y number
---@return boolean
function class:isFogged(x, y)
    return J.IsFoggedToPlayer(x, y, self:handle()) == true
end

--- 坐标是否对某玩家存在迷雾
---@param x number
---@param y number
---@return boolean
function class:isMasked(x, y)
    return J.IsMaskedToPlayer(x, y, self:handle()) == true
end

--- 是否有商城道具
---@param mallItemKey string
---@return boolean
function class:hasMallItem(mallItemKey)
    if (mallItemKey == nil) then
        return false
    end
    return japi.DZ_Map_HasMallItem(self:handle(), mallItemKey) or false
end

--- 索引[1-16]
---@return number
function class:index()
    return self:prop("index")
end

--- 地图等级
---@return number
function class:mapLv()
    return self:prop("mapLv")
end

--- 名称
---@param modify string
---@return string|self
function class:name(modify)
    return self:prop("name", modify)
end

--- WE内原生队伍索引，与Team对象无关
--- 存在负数的索引
---@return number
function class:team()
    return self:prop("team")
end

--- 队伍颜色
--- 使用玩家索引1-12决定颜色值,单位会自动同步
---@param modify number
---@return any|self
function class:teamColor(modify)
    return self:prop("teamColor", modify)
end

--- 种族
---@param modify string
---@return string|self
function class:race(modify)
    return self:prop("race", modify)
end

--- 皮肤
--- * 默认皮肤就是种族名
---@param modify string
---@return string|self
function class:skin(modify)
    return self:prop("skin", modify)
end

--- 状态值
---@see file variable/prop PLAYER_STATUS
---@param modify table|nil
---@return self|table
function class:status(modify)
    return self:prop("status", modify)
end

--- 资源管理
--- 当operator、data同时存在时，会根据当前玩家资源计算
--- 当operator为=符号时，设定价值，当operator为+-*/时，会进行运算
---@param operator string|nil "="|"+"|"-"|"*"|"/"
---@param data table|number 计算变动值
---@return self|table
function class:worth(operator, data)
    local w = self:prop("worth")
    if (type(operator) == "string" and (type(data) == "table" or type(data) == "number")) then
        if (operator == "=") then
            self:prop("worth", Game():worthL2U(Game():worthU2L(data)))
        else
            local ratio = self:worthRatio()
            if (ratio ~= 100 and operator == "+") then
                local r = math.max(0, ratio * 0.01)
                data = Game():worthCale(data, '*', r)
            end
            self:prop("worth", Game():worthCale(w, operator, data))
        end
        return self
    end
    return w
end

--- 资源获得率[%]
--- 默认100
--- 当使用worth方法且operator为+时有作用
---@param modify number|nil
---@return self|number
function class:worthRatio(modify)
    return self:prop("worthRatio", modify)
end

--- 售卖折价率[%]
---@param modify number|nil
---@return self|number
function class:sellRatio(modify)
    return self:prop("sellRatio", modify)
end

--- 称号
---@param modify string|nil
---@return self|string
function class:prestige(modify)
    return self:prop("prestige", modify)
end

--- 选择一个单位
---@return Unit|Item|nil
function class:select(targetUnit)
    self:clear("selection")
    if (isClass(targetUnit, UnitClass)) then
        async.call(self, function()
            J.ClearSelection()
            J.SelectUnit(targetUnit:handle(), true)
        end)
    end
end

--- 当前选中单位
---@return Unit|Item|nil
function class:selection()
    return self:prop("selection")
end

--- 仓库栏
---@return WarehouseSlot
function class:warehouseSlot()
    return self:prop("warehouseSlotObj")
end

--- APM
---@return number
function class:apm()
    return math.floor(self:prop("apm"))
end

--- 令玩家退出
---@param reason string 原因
function class:quit(reason)
    reason = reason or "已被系统判定出局"
    echo(self:name() .. reason .. "，退出了游戏", nil, 30)
    if (self:isUser()) then
        Dialog(reason, { { value = "Q", label = J.GetLocalizedString("GAMEOVER_QUIT_MISSION") } }, function(evtData)
            async.call(evtData.triggerPlayer, function()
                J.EndGame(true)
            end)
        end):show(self)
    end
end

--- 创建单位
---@param tpl UnitTpl 单位模版
---@param x number 坐标X[默认0]
---@param y number 坐标Y[默认0]
---@param facing number 面向角度[默认270]
---@return Unit
function class:unit(tpl, x, y, facing)
    return Unit(tpl, self, x, y, facing)
end

--- 创建一个遮罩
---@see file variable/texture
---@param path string 贴图路径 512x256 blp
---@param duration number 持续时间,默认3秒
---@param red number 0-255
---@param green number 0-255
---@param blue number 0-255
---@return self
function class:mark(path, duration, red, green, blue)
    if (path ~= nil and not self:isNeutral() and self:isPlaying()) then
        red = red or 255
        green = green or 255
        blue = blue or 255
        duration = math.trunc(duration or 3, 2)
        async.call(self, function()
            player._cinematicFilter(0.50, BLEND_MODE_ADDITIVE, path, red, green, blue, 255, red, green, blue, 0)
        end)
        self:superposition("mark", "+=1")
        time.setTimeout(duration, function()
            self:superposition("mark", "-=1")
            async.call(self, function()
                player._cinematicFilter(0.50, BLEND_MODE_ADDITIVE, path, red, green, blue, 0, red, green, blue, 255)
            end)
        end)
    end
    return self
end