local expander = ClassExpander(CLASS_EXPANDS_MOD, UnitTplClass)

---@param obj UnitTpl
local _modelId = function(obj)
    local speech = assets.speech(obj:propValue("speechAlias"))
    must(type(speech) == "string")
    local extra = obj:propValue("speechExtra")
    local id
    if (type(extra) == "string" and extra ~= '') then
        id = slk.n2i(speech .. "|EX|" .. extra)
    end
    if (id == nil) then
        id = slk.n2i(speech .. "|D")
    end
    obj:prop("modelId", J.C2I(id))
end

---@param obj UnitTpl
expander["modelId"] = function(obj, prev)
    local modelId = obj:propData("modelId")
    local uSlk = slk.i2v(modelId)
    must(type(uSlk) == "table")
    local building = math.round(uSlk.slk.isbldg or 0)
    local spd = math.round(uSlk.slk.spd or 0)
    local sightBase = math.round(uSlk.slk.sight)
    local sightDiff = math.round(uSlk.slk.sight) - math.round(uSlk.slk.nsight)
    local attackSpaceBase = math.round(uSlk.slk.cool1 or 0)
    local attackRangeAcquire = math.round(uSlk.slk.acquire)
    obj:prop("collision", math.round(uSlk.slk.collision))
    obj:prop("building", building == 1)
    obj:prop("immovable", spd <= 0)
    obj:prop("sightBase", sightBase)
    obj:prop("sightDiff", sightDiff)
    obj:prop("attackSpaceBase", attackSpaceBase)
    obj:prop("attackRangeAcquire", attackRangeAcquire)
    obj:prop("turnSpeed", tonumber(uSlk.slk.turnRate))
    obj:prop("corpse", tonumber(uSlk.slk.death or 3))
    if (spd <= 0) then
        obj:prop("move", 0)
    end
    if (prev == nil) then
        local sight = math.round(uSlk.slk.sight)
        local nsight = math.round(uSlk.slk.nsight)
        local attackRange = math.round(uSlk.slk.rangeN1 or 0)
        local modelScale = math.trunc(uSlk.slk.modelScale or 1, 2)
        local scale = math.trunc(uSlk.slk.scale or 1, 2)
        local rgba = { math.round(uSlk.slk.red), math.round(uSlk.slk.green), math.round(uSlk.slk.blue), 255 }
        local flyHeight = math.round(uSlk.slk.moveHeight or 0)
        local icon = uSlk.slk.Art or "Framework\\ui\\default.tga"
        obj:prop("move", spd)
        obj:prop("sight", sight)
        obj:prop("nsight", nsight)
        obj:prop("attackRange", attackRange)
        obj:prop("modelScale", modelScale)
        obj:prop("scale", scale)
        obj:prop("rgba", rgba)
        obj:prop("flyHeight", flyHeight)
        obj:prop("icon", icon)
    end
end

---@param obj UnitTpl
expander["speechExtra"] = function(obj)
    _modelId(obj)
end

---@param obj UnitTpl
expander["flyHeight"] = function(obj)
    local data = obj:propData("flyHeight")
    if (data > 0) then
        obj:prop("moveType", UNIT_MOVE_TYPE.fly)
    end
end

---@param obj UnitTpl
expander["hp"] = function(obj)
    obj:prop("hpCur", obj:propData("hp"))
end

---@param obj UnitTpl
expander["mp"] = function(obj)
    obj:prop("mpCur", obj:propData("mp"))
end

---@param obj UnitTpl
expander["shield"] = function(obj)
    obj:prop("shieldCur", obj:propData("shield"))
end

---@param obj Unit
expander["sight"] = function(obj)
    obj:propChange("nsight", "std", obj:propData("sight") - obj:sightDiff())
end

---@param obj Unit
expander["nsight"] = function(obj)
    if (obj:sight() ~= nil) then
        obj:propChange("sight", "std", obj:propData("nsight") + obj:sightDiff())
    end
end