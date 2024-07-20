--[[
    Assets资源管理
    用于映射资源文件的相对路径
    使得资源的别称或简称更方便地被引用
]]
---@class assets
assets = assets or {}

--- 判定资源是否自定义路径
--- 以路径是否包含后缀名部分判定，因引用assets无需包含后缀名
---@param trunk string
---@return boolean
function assets.isCustom(trunk)
    local l = #trunk - 3
    if (l < 2) then
        return false
    end
    local s = string.sub(trunk, l, l)
    return s == '.'
end

--- 资源自定义路径
---@param trunk string
---@param typ string
---@param suffix string
---@param kit string
---@return string|nil
function assets.path(trunk, typ, suffix, kit)
    if (nil == trunk) then
        return
    end
    if (assets.isCustom(trunk)) then
        return trunk
    end
    if (type(FRAMEWORK_ALIAS[typ]) == "table") then
        local base = FRAMEWORK_ALIAS[typ][trunk]
        if (nil ~= base and assets.isCustom(base)) then
            return base
        end
    end
    trunk = string.gsub(trunk, "/", "\\")
    if (typ == "icon") then
        trunk = "war3mapIcon\\" .. trunk
    elseif (typ == "model") then
        trunk = "war3mapModel\\" .. trunk
    elseif (typ == "bgm") then
        trunk = "resource\\war3mapSound\\bgm\\" .. trunk
    elseif (typ == "vcm") then
        trunk = "resource\\war3mapSound\\vcm\\" .. trunk
    elseif (typ == "v3d") then
        trunk = "resource\\war3mapSound\\v3d\\" .. trunk
    elseif (typ == "vwp") then
        trunk = "resource\\war3mapSound\\vwp\\" .. trunk
    elseif (typ == "uikit" and nil ~= kit) then
        trunk = "war3mapUI\\" .. kit .. "\\assets\\" .. trunk
    end
    if (suffix) then
        trunk = trunk .. "." .. suffix
    end
    return trunk
end

--- UI kit资源路径
---@param kit string
---@param trunk string
---@param suffix string
---@return string
function assets.uikit(kit, trunk, suffix)
    return assets.path(trunk, "uikit", suffix, kit)
end

--- 图标资源路径
---@param trunk string
---@return string
function assets.icon(trunk)
    return assets.path(trunk, "icon", "tga")
end

--- 模型资源路径
---@param trunk string
---@return string
function assets.model(trunk)
    return assets.path(trunk, "model", "mdl")
end

--- 音乐资源路径
---@param trunk string
---@return string
function assets.bgm(trunk)
    return assets.path(trunk, "bgm", "mp3")
end

--- 界面音效资源路径
---@param trunk string
---@return string
function assets.vcm(trunk)
    return assets.path(trunk, "vcm", "mp3")
end

--- 3D音效资源路径
---@param trunk string
---@return string
function assets.v3d(trunk)
    return assets.path(trunk, "v3d", "mp3")
end

--- 武器音效资源路径
---@param trunk string
---@return string
function assets.vwp(trunk)
    return assets.path(trunk, "vwp", "mp3")
end

--- 单位语音资源路径
---@param name string
---@return string
function assets.speech(name)
    if (true ~= FRAMEWORK_SPEECH[name]) then
        return ''
    end
    return name
end