---@class Weather:WeatherClass
---@see file variable/weather
---@param bindRegion Region
---@param weatherType string
---@return Weather|nil
function Weather(bindRegion, weatherType)
    must(isClass(bindRegion, RegionClass))
    must(weatherType ~= nil)
    local realType = J.C2I(weatherType.value)
    must(realType ~= nil)
    return Object(WeatherClass, {
        options = {
            bindRegion = bindRegion,
            weatherType = weatherType,
            realType = realType,
        }
    })
end
