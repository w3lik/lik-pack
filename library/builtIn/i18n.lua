i18n = i18n or {}

---@protected
i18n._enable = i18n._enable or false
---@protected
i18n._data = i18n._data or {}
---@protected
i18n._langDef = nil
---@protected
i18n._langList = {}
---@protected
i18n._seps = {
    { "|cff", 6 },
    { "|r", 0 },
    { "|n", 0 },
    { " ", 0 },
    { ":", 0 },
    { "：", 0 },
    { ",", 0 },
    { "，", 0 },
    { "、", 0 },
    { "[", 0 },
    { "]", 0 },
    { "(", 0 },
    { ")", 0 },
    { "（", 0 },
    { "）", 0 },
    { SYMBOL_RAI, 0 },
    { SYMBOL_MUT, 0 },
    { SYMBOL_SUP, 0 },
}

---@return boolean
function i18n.isEnable()
    return i18n._enable == true
end

---@param status boolean
---@return void
function i18n.setEnable(status)
    if (type(status) == "boolean") then
        i18n._enable = status
    end
end

---@param value string
function i18n.lang(value)
    if (type(value) == "string") then
        Game():prop("i18nLang", value)
    end
end

---@param str string
---@param values Array
function i18n.data(str, values)
    if (type(values) == "table") then
        for _, l in ipairs(i18n._langList) do
            local val = values[l.value]
            if (type(val) == "string") then
                local lang = l.value
                if (i18n._data[lang] == nil) then
                    i18n._data[lang] = {}
                end
                i18n._data[lang][str] = val
            end
        end
        local c = Game():prop("i18nLangCache")
        if (c ~= nil) then
            Game():clear("i18nLangCache")
        end
    end
end

function i18n.cache(lang, str, value)
    local c = Game():prop("i18nLangCache")
    if (c == nil) then
        c = {}
        Game():prop("i18nLangCache", c)
    end
    if (value == nil) then
        if (c[lang] ~= nil and c[lang][str] ~= nil) then
            return c[lang][str]
        end
        return
    else
        if (c[lang] == nil) then
            c[lang] = {}
        end
        c[lang][str] = value
    end
end

function i18n.tr(str)
    if (false == i18n.isEnable()) then
        return str
    end
    if (type(str) ~= "string" or str == '') then
        return str
    end
    local lang = Game():prop("i18nLang")
    if (lang == nil) then
        lang = i18n._langDef
    end
    if (lang == nil or i18n._data[lang] == nil) then
        return str
    end
    local tr = i18n.cache(lang, str)
    if (tr == nil) then
        local trs = {}
        local cur = 1
        while true do
            local sep, start_pos, end_pos
            local phase = 0
            for _, s in ipairs(i18n._seps) do
                local sp, ep = string.find(str, s[1], cur, true)
                if sp and (start_pos == nil or sp < start_pos) then
                    sep = s[1]
                    phase = s[2]
                    start_pos = sp
                    end_pos = ep
                end
            end
            if (sep == nil) then
                break
            end
            if (start_pos > cur) then
                table.insert(trs, string.sub(str, cur, start_pos - 1))
            end
            table.insert(trs, sep)
            cur = end_pos + 1
            if (phase > 0) then
                table.insert(trs, string.sub(str, cur, cur + phase - 1))
                cur = cur + phase
            end
        end
        if (cur <= string.len(str)) then
            table.insert(trs, string.sub(str, cur))
        end
        for ti, t in ipairs(trs) do
            if (type(i18n._data[lang][t]) == "string") then
                trs[ti] = i18n._data[lang][t]
            end
        end
        tr = table.concat(trs, '')
        local d = string.find(str, "%d")
        if (d == nil) then
            i18n.cache(lang, str, tr)
        end
    end
    return tr
end