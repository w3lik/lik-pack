---@class FogModifierClass:Class
local class = Class(FogModifierClass)

---@private
function class:construct(options)
    self:prop("bindPlayer", options.bindPlayer)
    self:prop("fogState", FOG_OF_WAR_VISIBLE)
    self:prop("enable", false)
    self:prop("radius", 0)
    self:prop("position", { 0, 0 })
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 绑定玩家
---@return Player
function class:bindPlayer()
    return self:prop("bindPlayer")
end

--- 绑定区域
--- 优先级比圆范围高，当设定区域后，修正器就自动变为区域模式，position、radius参数都会失效以区域为准
--- 消除绑定先enable为false，再clear区域，最后enable再次true即可
---@param modify Region|nil
---@return self|Region|nil
function class:bindRegion(modify)
    return self:prop("bindRegion", modify)
end

--- 可见器状态
--- 默认“可见:FOG_OF_WAR_VISIBLE”
---@see file builtIn/blizzard FOG_OF_WAR_MASKED|FOG_OF_WAR_FOGGED|FOG_OF_WAR_VISIBLE 黑色迷雾|战争迷雾|可见
---@alias noteFogModifierType any
---@param modify boolean|nil
---@return self|boolean
function class:fogState(modify)
    return self:prop("fogState", modify)
end

--- 启用状态
---@param modify boolean|nil
---@return self|boolean
function class:enable(modify)
    return self:prop("enable", modify)
end

--- 作用半径
---@param modify number|nil
---@return self|number
function class:radius(modify)
    return self:prop("radius", modify)
end

--- 获取 X 坐标
---@return number
function class:x()
    ---@type Region
    local r = self:bindRegion()
    if (isClass(r, RegionClass)) then
        return r:x()
    end
    return self:prop("position")[1]
end

--- 获取 Y 坐标
---@return number
function class:y()
    ---@type Region
    local r = self:bindRegion()
    if (isClass(r, RegionClass)) then
        return r:y()
    end
    return self:prop("position")[2]
end

--- 移动到X,Y坐标
---@param x number|nil
---@param y number|nil
---@return void
function class:position(x, y)
    if (type(x) == "number" and type(y) == "number") then
        self:prop("position", { x, y })
    end
end