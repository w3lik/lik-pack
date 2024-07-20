---@class attribute 属性
attribute = attribute or {}

--- 附魔上身默认持续时间
---@type number
attribute._enDmgAppDur = 10
attribute._labels = attribute._labels or {}
attribute._forms = attribute._forms or {}
attribute._antis = attribute._antis or {}

--- 属性名称配置
---@param key string 键值
---@param label string 名称
---@param form string 单位范式
---@param anti boolean 是否反属性（指增加反而不好的属性）默认false
---@return string|'???',string|'',boolean
function attribute.conf(key, label, form, anti)
    must(type(key) == "string")
    if (type(label) == "string") then
        attribute._labels[key] = label
        attribute._labels[SYMBOL_MUT .. key] = label
        attribute._forms[SYMBOL_MUT .. key] = '%'
    end
    if (type(form) == "string") then
        attribute._forms[key] = form
    end
    if (type(anti) == "boolean") then
        attribute._antis[key] = anti
        attribute._antis[SYMBOL_MUT .. key] = anti
    end
    return attribute._labels[key] or "???", attribute._forms[key] or '', attribute._antis[key] or false
end

--- 属性名称
---@param key string
---@return string
function attribute.label(key)
    return attribute._labels[key] or "???"
end

--- 属性单位
---@param key string
---@return string
function attribute.form(key)
    return attribute._forms[key] or ''
end

--- 是否百分比属性
---@param key string
---@return boolean
function attribute.isPercent(key)
    return type(key) == "string" and (attribute._forms[key] == '%')
end

--- 是否反式属性（指增加反而不好的属性）
---@param key string
---@return boolean
function attribute.isAnti(key)
    return type(key) == "string" and (attribute._antis[key] or false)
end

--- 属性字符串简单格式构建
--- 并不适合复杂情形
---@param key string
---@param value number
---@param label string|nil
---@return string
function attribute.format(key, value, label)
    must(type(key) == "string")
    must(type(value) == "number")
    local txt
    local la, form, iai = attribute.conf(key)
    local l = label or la
    if (value == 0) then
        txt = colour.hex(colour.darkgray, l .. ": " .. value .. form)
    elseif (value > 0) then
        if (iai) then
            txt = colour.hex(colour.indianred, l .. ": +" .. value .. form)
        else
            txt = colour.hex(colour.lawngreen, l .. ": +" .. value .. form)
        end
    else
        if (iai) then
            txt = colour.hex(colour.lawngreen, l .. ": " .. value .. form)
        else
            txt = colour.hex(colour.indianred, l .. ": " .. value .. form)
        end
    end
    return txt
end

--- 智能属性
---@param attributes table 属性集
---@param targetUnit Unit
---@param lv number 当前等级
---@param diff number 等级差值
---@return void
function attribute.clever(attributes, targetUnit, lv, diff)
    if (isClass(targetUnit, UnitClass) == false) then
        return
    end
    if (isClass(targetUnit, UnitClass)) then
        for _, a in ipairs(attributes) do
            local key = a[1]
            local t1 = a[2] or 0
            local d1
            local d2
            local params = {}
            if (type(t1) == "number") then
                d1 = t1
                d2 = a[3] or 0
            elseif (type(t1) == "string") then
                d1 = a[3] or 0
                d2 = a[4] or 0
                table.insert(params, t1)
            end
            local v = 0
            if (diff > 0) then
                if (lv <= 0) then
                    v = d1 + (diff - 1) * d2
                else
                    v = diff * d2
                end
            elseif (diff < 0) then
                if (lv + diff < 0) then
                    diff = -lv
                end
                if (lv + diff == 0) then
                    v = -d1 + (diff + 1) * d2
                else
                    v = diff * d2
                end
            end
            if (v > 0) then
                table.insert(params, "+=" .. v)
            elseif (v < 0) then
                table.insert(params, "-=" .. -v)
            end
            targetUnit:prop(key, table.unpack(params))
        end
    end
end