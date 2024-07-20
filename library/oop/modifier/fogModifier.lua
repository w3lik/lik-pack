local expander = ClassExpander(CLASS_EXPANDS_MOD, FogModifierClass)

---@param obj FogModifier
local _modifier = function(obj)
    local enable = obj:propData("enable")
    local fogState = obj:propData("fogState")
    if (enable ~= true) then
        return
    end
    ---@type Player
    local bindPlayer = obj:propData("bindPlayer")
    ---@type Region
    local bindRegion = obj:propData("bindRegion")
    if (isClass(bindRegion, RegionClass)) then
        href(obj, J.CreateFogModifierRect(bindPlayer:handle(), fogState, bindRegion:handle(), true, false))
    else
        local pos = obj:propData("position")
        local radius = obj:propData("radius")
        if (radius <= 0) then
            return
        end
        local loc = J.Location(pos[1], pos[2])
        J.HandleRef(loc)
        href(obj, J.CreateFogModifierRadiusLoc(bindPlayer:handle(), fogState, loc, radius, true, false))
        J.RemoveLocation(loc)
        J.HandleUnRef(loc)
    end
    if (enable == true) then
        J.FogModifierStart(obj:handle())
    end
end

---@param obj FogModifier
expander["enable"] = function(obj)
    local data = obj:propData("enable")
    if (data == true) then
        _modifier(obj)
    else
        local h = obj:handle()
        if (h ~= nil) then
            J.FogModifierStop(h)
        end
    end
end

---@param obj FogModifier
expander["bindRegion"] = function(obj)
    _modifier(obj)
end

---@param obj FogModifier
expander["fogState"] = function(obj)
    _modifier(obj)
end

---@param obj FogModifier
expander["position"] = function(obj)
    _modifier(obj)
end

---@param obj FogModifier
expander["radius"] = function(obj)
    _modifier(obj)
end