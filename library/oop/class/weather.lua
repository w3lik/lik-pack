---@class WeatherClass:Class
local class = Class(WeatherClass)

---@private
function class:construct(options)
    self:prop("handle", J.AddWeatherEffect(options.bindRegion:handle(), options.realType))
    self:prop("bindRegion", options.bindRegion) -- 绑定区域
    self:prop("weatherType", options.weatherType) -- 天气类型 WEATHER_TYPE
    self:prop("enable", false)
    self:prop("period", -1)
end

---@private
function class:destruct()
    self:clear("periodTimer", true)
    local h = self:prop("handle")
    J.EnableWeatherEffect(h, false)
    J.RemoveWeatherEffect(h)
    self:clear("handle")
end

---@return number
function class:handle()
    return self:prop("handle")
end

--- 天气所在区域
---@return Region
function class:bindRegion()
    return self:prop("bindRegion")
end

--- 天气类型
---@return WEATHER_TYPE
function class:weatherType()
    return self:prop("weatherType")
end

--- 是否启用
---@param modify boolean
---@return self|boolean
function class:enable(modify)
    return self:prop("enable", modify)
end

--- 存在周期
---@param modify number|nil
---@return self|number|-1
function class:period(modify)
    return self:prop("period", modify)
end