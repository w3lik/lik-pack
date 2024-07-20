---@class buff 状态
buff = buff or {}

---@type table<string,string>
buff._labels = buff._labels or {}

---@type table<string,string>
buff._icons = buff._icons or {}

--- 状态名称配置及获取
---@param key string 键值
---@param label string|nil 文本叙述，当缺省时取attribute.label
---@param icon string 图标路径
---@return string|nil,string|nil
function buff.conf(key, label, icon)
    if (type(label) == "string") then
        buff._labels[key] = label
    end
    if (type(icon) == "string") then
        buff._icons[key] = assets.icon(icon)
    end
    return (buff._labels[key] or attribute._labels[key] or key), buff._icons[key]
end

--- 状态名称
---@param key string
---@return string
function buff.label(key)
    return buff._labels[key] or attribute._labels[key] or key
end

--- 状态图标
---@param key string
---@return string
function buff.icon(key)
    return buff._icons[key]
end
