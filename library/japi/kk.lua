--[[
    JAPI自kk库
    包含kk平台引擎自带的japi方法
    方法以 KK_ 开头
]]

--- [别名]KKApiTriggerRegisterBackendLogicUpdata
--- 注册随机存档更新事件
--- 当玩家随机存档更新的时候触发该事件。用“当前变动的随机存档”来获取变动的随机存档key。
---@param trig number
---@return void
function japi.KK_TriggerRegisterBackendLogicUpdate(trig)
    japi.DZ_TriggerRegisterSyncData(trig, "DZBLU", true)
end

--- 注册随机存档删除事件
--- 当玩家随机存档删除的时候触发该事件。用“当前变动的随机存档”来获取变动的随机存档key。
---@param trig number
---@return void
function japi.KK_TriggerRegisterBackendLogicDelete(trig)
    japi.DZ_TriggerRegisterSyncData(trig, "DZBLD", true)
end

--- 获取变动的随机存档
--- 用在注册随机存档更新和删除事件之后
---@return string
function japi.KK_GetSyncBackendLogic()
    return japi.DZ_GetTriggerSyncData()
end

--- 注册天梯投降事件
--- 当玩家在天梯投降时候触发该事件。用“获取投降的队伍id”来获取。
---@param trig number
---@return void
function japi.KK_TriggerRegisterLadderSurrender(trig)
    japi.DZ_TriggerRegisterSyncData(trig, "DZSR", true)
end

--- 获取天梯投降的队伍ID
--- 用于天梯投降事件动作里
---@return number integer
function japi.KK_GetLadderSurrenderTeamId()
    return math.round(tonumber(japi.DZ_GetTriggerSyncData()))
end

--- 获取服务器存档限制余额
--- 获取指定服务器存档变量的天/周上限余额，需要在开发者平台配置服务器存档防刷。
--- 访问授权限制
--- 高级接口，需要授权后才允许使用。
---@param whichPlayer number
---@param key string
---@return number integer
function japi.KK_GetServerValueLimitLeft(whichPlayer, key)
    return japi.DZ_RequestExtraIntegerData(82, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 随机只读存档-生成随机数
--- 通知服务器端产生一个随机数，并将随机数保存至指定的只读型存档变量Key中。
--- 生成随机数时需要关联一个组ID，该组ID可以在开发者平台进行防刷分管理，同组ID下各个Key共享CD和次数。
---@param whichPlayer number
---@param key string
---@param groupKey string
---@return boolean
function japi.KK_RequestBackendLogic(whichPlayer, key, groupKey)
    return japi.DZ_RequestExtraBooleanData(83, whichPlayer, key, groupKey, false, 0, 0, 0)
end

--- 随机只读存档-判断随机数是否为空
--- 判断服务器端所生成的随机数是否为空。
---@param whichPlayer number
---@param key string
---@return boolean
function japi.KK_CheckBackendLogicExists(whichPlayer, key)
    return japi.DZ_RequestExtraBooleanData(84, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 随机只读存档-读取随机数的值
--- 读取服务器端所产生的随机数的值。
---@param whichPlayer number
---@param key string
---@return number
function japi.KK_GetBackendLogicIntResult(whichPlayer, key)
    return japi.DZ_RequestExtraIntegerData(85, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 获取后端逻辑生成结果 字符串
---@param whichPlayer number
---@param key string
---@return string
function japi.KK_GetBackendLogicStrResult(whichPlayer, key)
    return japi.DZ_RequestExtraStringData(86, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 随机只读存档-读取随机数的生成时间
--- 读取服务器端所产生随机数的生成时间。
---@param whichPlayer number
---@param key string
---@return number integer
function japi.KK_GetBackendLogicUpdateTime(whichPlayer, key)
    return japi.DZ_RequestExtraIntegerData(87, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 随机只读存档-读取随机数的组ID
--- 读取指定的随机只读存档变量Key最后一次是由哪个组ID所生成的。
---@param whichPlayer number
---@param key string
---@return string
function japi.KK_GetBackendLogicGroup(whichPlayer, key)
    return japi.DZ_RequestExtraStringData(88, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 随机只读存档-删除随机数
--- 删除指定的随机只读存档变量Key中所保存的随机数
---@param whichPlayer number
---@param key string
---@return boolean
function japi.KK_RemoveBackendLogicResult(whichPlayer, key)
    return japi.DZ_RequestExtraBooleanData(89, whichPlayer, key, nil, false, 0, 0, 0)
end

--- 是否在平台正常游戏中
--- 主要试用于平台运行中区分正常游戏和观战模式，返回true代表是正常游戏模式，反之为观战模式
---@return boolean
function japi.KK_IsGameMode()
    return japi.DZ_RequestExtraBooleanData(90, nil, nil, nil, false, 0, 0, 0)
end

--- 初始化平台键位显示设置
--- 设置whichPlayer的第n套方案的键位key,设置描述data
--- 初始化键位设置会显示在平台改键界面上，最多2套方案
---@param whichPlayer number
---@param setIndex number integer
---@param k string
---@param data string
---@return boolean
function japi.KK_InitializeGameKey(whichPlayer, setIndex, k, data)
    return japi.DZ_RequestExtraBooleanData(91, whichPlayer, '[{"name":"' .. data .. '","key":"' .. k .. '"}]', nil, false, setIndex, 0, 0)
end

--- 获取当前玩家在平台的身份类型（主播/职业选手）
---@param whichPlayer number
---@param id number integer 3=主播，4=职业选手
---@return boolean
function japi.KK_IsPlayerIdentityType(whichPlayer, id)
    return japi.DZ_RequestExtraBooleanData(92, whichPlayer, nil, nil, false, id, 0, 0)
end

--- [别名]DzApi_Map_IsBlueVIP
--- 判断是否是蓝V
---@param whichPlayer number
---@return boolean
function japi.KK_Map_IsBlueVIP(whichPlayer)
    return japi.KK_IsPlayerIdentityType(whichPlayer, 3)
end

--- [别名]DzApi_Map_IsRedVIP
--- 判断是否是红V
---@param whichPlayer number
---@return boolean
function japi.KK_Map_IsRedVIP(whichPlayer)
    return japi.KK_IsPlayerIdentityType(whichPlayer, 4)
end

--- 获取玩家的平台ID
--- 返回的是一个32位的字符串
---@param whichPlayer number
---@return boolean
function japi.KK_PlayerGUID(whichPlayer)
    return japi.DZ_RequestExtraStringData(93, whichPlayer, nil, nil, false, 0, 0, 0)
end

--- 玩家地图任务状态
--- 获取玩家地图任务状态，需要先在作者之家创建地图任务并生成任务ID。
---@param whichPlayer number
---@param setIndex number integer
---@param taskStatus number integer 某状态
---@return boolean
function japi.KK_IsTaskInProgress(whichPlayer, setIndex, taskStatus)
    return japi.DZ_RequestExtraIntegerData(94, whichPlayer, nil, nil, false, setIndex, 0, 0) == taskStatus
end

--- 玩家地图任务当前进度
--- 获取玩家地图任务状态，需要先在作者之家创建地图任务并生成任务ID。
---@param whichPlayer number
---@param setIndex number integer
---@return boolean
function japi.KK_QueryTaskCurrentProgress(whichPlayer, setIndex)
    return japi.DZ_RequestExtraIntegerData(95, whichPlayer, nil, nil, false, setIndex, 0, 0)
end

--- 玩家地图任务总进度
--- 获取玩家地图任务状态，需要先在作者之家创建地图任务并生成任务ID。
---@param whichPlayer number
---@param setIndex number integer
---@return boolean
function japi.KK_QueryTaskTotalProgress(whichPlayer, setIndex)
    return japi.DZ_RequestExtraIntegerData(96, whichPlayer, nil, nil, false, setIndex, 0, 0)
end

--- 获取玩家成就是否完成
---@param whichPlayer number
---@param id string 成就id
---@return boolean
function japi.KK_IsAchievementCompleted(whichPlayer, id)
    return japi.DZ_RequestExtraBooleanData(98, whichPlayer, id, nil, false, 0, 0, 0)
end

--- 获取玩家地图成就点数
---@param whichPlayer number
---@return number integer
function japi.KK_AchievementPoints(whichPlayer)
    return japi.DZ_RequestExtraIntegerData(99, whichPlayer, nil, nil, false, 0, 0, 0)
end

--- 判断游戏时长是否满足条件
---@param whichPlayer number
---@param minHours number integer 最小小时数
---@param maxHours number integer 最大小时数，0表示不限制
---@return number integer
function japi.KK_PlayedTime(whichPlayer, minHours, maxHours)
    return japi.DZ_RequestExtraBooleanData(100, whichPlayer, nil, nil, false, minHours, maxHours, 0)
end

--- 获取随机存档剩余次数
--- 今日的剩余次数
---@param whichPlayer number
---@param groupKey string
---@return boolean
function japi.KK_RandomSaveGameCount(whichPlayer, groupKey)
    return japi.DZ_RequestExtraIntegerData(101, whichPlayer, groupKey, nil, false, 0, 0, 0)
end

--- 开始批量保存存档
--- 对添加批量保存存档条目进行保存
---@param whichPlayer number
---@return boolean
function japi.KK_BeginBatchSaveArchive(whichPlayer)
    return japi.DZ_RequestExtraBooleanData(102, whichPlayer, nil, nil, false, 0, 0, 0)
end

--- 添加批量保存存档条目
---@param whichPlayer number
---@param key string 条目
---@param value string 数据
---@param caseInsensitive boolean 区分大小写
---@return boolean
function japi.KK_AddBatchSaveArchive(whichPlayer, key, value, caseInsensitive)
    return japi.DZ_RequestExtraBooleanData(103, whichPlayer, key, value, caseInsensitive, 0, 0, 0)
end

--- 结束批量保存存档
---@param whichPlayer number
---@param abandon boolean
---@return boolean
function japi.KK_EndBatchSaveArchive(whichPlayer, abandon)
    return japi.DZ_RequestExtraBooleanData(104, whichPlayer, nil, nil, abandon, 0, 0, 0)
end