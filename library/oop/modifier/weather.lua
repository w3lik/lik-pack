local expander = ClassExpander(CLASS_EXPANDS_MOD, WeatherClass)

---@param obj Weather
expander["enable"] = function(obj)
    J.EnableWeatherEffect(obj:handle(), obj:propData("enable"))
end

---@param obj Weather
expander["period"] = function(obj)
    local t = obj:prop("periodTimer")
    if (isClass(t, TimerClass)) then
        destroy(t)
        obj:clear("periodTimer")
        t = nil
    end
    local data = obj:propData("period")
    if (data > 0) then
        t = time.setTimeout(data, function()
            obj:clear("periodTimer")
            destroy(obj)
        end)
        obj:prop("periodTimer", t)
    end
end