local inc = 1

FRAMEWORK_N2C = {}
FRAMEWORK_GO_IDS = {}
FRAMEWORK_SLK_I2V = {}
FRAMEWORK_SLK_N2I = {}
FRAMEWORK_ALIAS = { icon = {}, model = {}, vcm = {}, v3d = {}, bgm = {}, vwp = {} }
FRAMEWORK_DESTRUCTABLE = {}
FRAMEWORK_SPEECH = {}
FRAMEWORK_FONT = ''
FRAMEWORK_MAP_NAME = ''

-- 用于反向补充slk优化造成的数据丢失问题
-- 如你遇到slk优化后（dist后）地图忽然报错问题，则有可能是优化丢失
FRAMEWORK_SLK_FIX = {
    ability = {},
    unit = { "sight", "nsight" },
    destructable = {},
}

-- 音频初始化
function FRAMEWORK_VOICE_INIT()
    for _ = 1, 5 do
        __FRAMEWORK_VOICE_INIT__ = 117532
    end
end

-- I2023Y5#DTOX
function FRAMEWORK_SETTING(_v)
    _v._id = FRAMEWORK_GO_IDS[inc]
    local id = _v._id
    local data = _v
    FRAMEWORK_SLK_I2V[id] = data[id] or {}
    FRAMEWORK_SLK_I2V[id]._type = FRAMEWORK_SLK_I2V[id]._type or "slk"
    if (J.Slk["unit"][id] ~= nil) then
        FRAMEWORK_SLK_I2V[id].slk = setmetatable({}, { __index = J.Slk["unit"][id] })
        for _, f in ipairs(FRAMEWORK_SLK_FIX.unit) do
            if (FRAMEWORK_SLK_I2V[id].slk[f] == nil) then
                FRAMEWORK_SLK_I2V[id].slk[f] = FRAMEWORK_SLK_I2V[id][f] or 0
            end
        end
    elseif (J.Slk["ability"][id] ~= nil) then
        FRAMEWORK_SLK_I2V[id].slk = setmetatable({}, { __index = J.Slk["ability"][id] })
        for _, f in ipairs(FRAMEWORK_SLK_FIX.ability) do
            if (FRAMEWORK_SLK_I2V[id].slk[f] == nil) then
                FRAMEWORK_SLK_I2V[id].slk[f] = FRAMEWORK_SLK_I2V[id][f] or 0
            end
        end
    elseif (J.Slk["destructable"][id] ~= nil) then
        FRAMEWORK_SLK_I2V[id].slk = setmetatable({}, { __index = J.Slk["destructable"][id] })
        for _, f in ipairs(FRAMEWORK_SLK_FIX.destructable) do
            if (FRAMEWORK_SLK_I2V[id].slk[f] == nil) then
                FRAMEWORK_SLK_I2V[id].slk[f] = FRAMEWORK_SLK_I2V[id][f] or 0
            end
        end
    end
    if (FRAMEWORK_SLK_I2V[id].slk) then
        local n = FRAMEWORK_SLK_I2V[id].slk.Name
        if (n ~= nil) then
            if (FRAMEWORK_SLK_N2I[n] == nil) then
                FRAMEWORK_SLK_N2I[n] = {}
            end
            table.insert(FRAMEWORK_SLK_N2I[n], id)
        end
    end
    inc = inc + 1
end