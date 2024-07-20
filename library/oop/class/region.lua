---@class RegionClass:Class
local class = Class(RegionClass)

---@private
function class:reset()
    self:prop("xMin", self:prop("x") - self:prop("width") * 0.5)
    self:prop("yMin", self:prop("y") - self:prop("height") * 0.5)
    self:prop("xMax", self:prop("x") + self:prop("width") * 0.5)
    self:prop("yMax", self:prop("y") + self:prop("height") * 0.5)
end

---@private
function class:construct(options)
    self:prop("key", options.key)
    self:prop("name", options.key) -- 区域名称
    self:prop("shape", options.shape or "square") --区域形状 square[方] | circle[圆/椭圆]
    self:prop("x", options.x or 0) -- 中心X
    self:prop("y", options.y or 0) -- 中心Y
    self:prop("width", options.width or 0) -- 宽
    self:prop("height", options.height or 0) -- 高
    self:prop("useEvent", false)
    self:reset()
    self:propChange("frequency", "std", 0.4, false)
end

---@private
function class:unEvent()
    self:clear("eventTimer", true)
    local prevUnit = self:prop("prevUnits")
    if (type(prevUnit) == "table") then
        for _, u in ipairs(prevUnit) do
            event.syncTrigger(self, EVENT.Region.Enter, { triggerUnit = u })
        end
    end
    self:clear("prevUnits")
end

---@private
function class:destruct()
    local ws = self:prop("weathers")
    if (type(ws) == "table" and #ws > 0) then
        for i = #ws, 1, -1 do
            if (isClass(ws[i], WeatherClass)) then
                destroy(ws[i])
            end
        end
        self:clear("weathers")
    end
    self:unEvent()
end

--- 本对象事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onEvent(evt, ...)
    self:prop("useEvent", true)
    event.syncRegister(self, evt, ...)
    return self
end

--- handle
---@return number
function class:handle()
    if (self._handle == nil) then
        href(self, J.Rect(self:xMin(), self:yMin(), self:xMax(), self:yMax()))
    end
    return self._handle
end

--- 坐标是否在区域里
---@param x number
---@param y number
---@return boolean
function class:isInside(x, y)
    if (self:shape() == "square") then
        return (x < self:xMax() and x > self:xMin() and y < self:yMax() and y > self:yMin())
    elseif (self:shape() == "circle") then
        return 1 >= (((self:x() - x) ^ 2) / ((self:width()) ^ 2) + ((self:y() - y) ^ 2) / ((self:height() / 2) ^ 2))
    end
    return false
end

--- 坐标是否超出区域边界
---@param x number
---@param y number
---@return boolean
function class:isBorder(x, y)
    if (self:shape() == "square") then
        return x >= self:xMax() or x <= self:xMin() or y >= self:yMax() or y <= self:yMin()
    elseif (self:shape() == "circle") then
        return 1 < (((self:x() - x) ^ 2) / ((self:width()) ^ 2) + ((self:y() - y) ^ 2) / ((self:height() / 2) ^ 2))
    end
    return false
end

--- 区域名称
--- 默认与key相同
function class:name(modify)
    return self:prop("name", modify)
end

--- 形状 | 方 | 圆
---@param modify nil|string | "'square'" | "'circle'"
---@return self|string
function class:shape(modify)
    return self:prop("shape", modify)
end

--- 区域左下角X坐标
---@return number
function class:xMin()
    return self:prop("xMin")
end

--- 区域左下角Y坐标
---@return number
function class:yMin()
    return self:prop("yMin")
end

--- 区域右上角X坐标
---@return number
function class:xMax()
    return self:prop("xMax")
end

--- 区域右上角Y坐标
---@return number
function class:yMax()
    return self:prop("yMax")
end

--- 中心X
---@param modify number|nil
---@return self|number
function class:x(modify)
    local res, updated = self:PROP("x", modify)
    if (updated) then
        self:reset()
    end
    return res
end

--- 中心Y
---@param modify number|nil
---@return self|number
function class:y(modify)
    local res, updated = self:PROP("y", modify)
    if (updated) then
        self:reset()
    end
    return res
end

--- 宽
---@param modify number|nil
---@return self|number
function class:width(modify)
    local res, updated = self:PROP("width", modify)
    if (updated) then
        self:reset()
    end
    return res
end

--- 高
---@param modify number|nil
---@return self|number
function class:height(modify)
    local res, updated = self:PROP("height", modify)
    if (updated) then
        self:reset()
    end
    return res
end

--- 监听频率[秒]
---@param modify number|nil
---@return self|number
function class:frequency(modify)
    return self:prop("frequency", modify)
end

--- 内部随机坐标
---@return number,number
function class:rand()
    return math.square(self:x(), self:y(), self:width(), self:height())
end

--- 添加或删除天气
---@see file variable/weather
---@param weatherType WEATHER_TYPE 当设为nil且status为false时，去除所有天气，否则只去除1对应数量级
---@param status boolean true添加|false删除
---@return Weather|self
function class:weather(weatherType, status)
    must(type(status) == "boolean")
    ---@type Weather[]
    local ws = self:prop("weathers")
    if (ws == nil) then
        if (status == false) then
            return
        end
        ws = {}
        self:prop("weathers", ws)
    end
    if (status) then
        must(type(weatherType) == "table")
        local w = Weather(self, weatherType)
        w:enable(true)
        table.insert(ws, w)
        return w
    else
        if (#ws > 0) then
            for i = #ws, 1, -1 do
                local wv = ws[i]
                if (weatherType == nil) then
                    table.remove(ws, i)
                    destroy(wv)
                elseif (weatherType == wv:weatherType()) then
                    table.remove(ws, i)
                    destroy(wv)
                    break
                end
            end
        end
        return self
    end
end