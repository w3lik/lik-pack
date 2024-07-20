---@class TplClass:Class
local class = Class(TplClass)

---@private
function class:construct()
    self:PROP("coverKeys", {})
    self:prop("category", "common")
    self:prop("name", self:id())
    self:prop("icon", "Framework\\ui\\default.tga")
    self:prop("conditionTips", "无")
    self:prop("conditionPassTips", "已拥有")
end

---@protected
---@param key string
---@param variety any
---@param duration number
---@return self|any
function class:prop(key, variety, duration)
    local coverKeys = self:PROP("coverKeys")
    if (table.includes(coverKeys, key) == false) then
        table.insert(coverKeys, key)
    end
    local v = self:PROP(key, variety, duration)
    return v
end

---@protected
function class:cover(obj)
    local coverKeys = self:prop("coverKeys")
    for _, k in ipairs(coverKeys) do
        obj:prop(k, self:prop(k))
    end
end

--- 归类
---@param modify string|nil
---@return self|string
function class:category(modify)
    return self:prop("category", modify)
end

--- 名称
---@param modify string|nil
---@return self|string
function class:name(modify)
    return self:prop("name", modify)
end

--- 图标
---@param modify string|nil
---@return self|string
function class:icon(modify)
    return self:prop("icon", assets.icon(modify))
end

--- 价值
---@param modify number|nil
---@return self|number
function class:worth(modify)
    return self:prop("worth", modify)
end

--- 智能属性数组配置
--- {method, baseValue, varyValue}
--- Attr方法名, 1级数值, 升级加成
--- varyValue不设置时，自动取baseValue做线性加成
--- 方法不存在 或 1级数值、升级加成同时为0 会被忽略
--- * 只适用于部分数值型方法
--[[
    attrs:{
        {"attack", 10, 10}, -- 每级+10点攻击
        {"attackSpeed", 10, 0}, -- 1级+10点攻击
        {"attackSpeed", 10 }, -- 1级+10点攻击，后面升级默认不增加，与0一样
        {"defend", -1, -0.1}, -- 第1级-1防御，2级-1.1防御...
    }
]]
---@param modify table|nil
---@return self|table|nil
function class:attributes(modify)
    return self:prop("attributes", modify)
end

--- 描述体
---@alias noteTplDescriptionFunc fun(obj:Item|Ability|Unit):string[]
---@param modify nil|string[]|string|noteTplDescriptionFunc
---@return self|string[]
function class:description(modify)
    local mType = type(modify)
    if (mType == "string" or mType == "table" or mType == "function") then
        return self:prop("description", modify)
    end
    local desc = {}
    local d = self:prop("description")
    if (type(d) == "string") then
        desc[#desc + 1] = d
    elseif (type(d) == "table") then
        for _, v in ipairs(d) do
            desc[#desc + 1] = v
        end
    elseif (type(d) == "function") then
        desc = d(self)
    end
    return desc
end