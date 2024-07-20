---@class oop
oop = oop or {}

if (DEBUGGING) then
    oop._dbg = oop._dbg or {}
end
oop._oid = oop._oid or {}
oop._static = oop._static or {}
oop._h2o = oop._h2o or {}
oop._i2o = oop._i2o or setmetatable({}, { __mode = "v" })
---@type table<string,Array>
oop._uf6 = oop._uf6 or {}

---@param id string
---@return Object|nil
function i2o(id)
    if (id == nil) then
        return nil
    end
    return oop._i2o[id]
end

---@private
---@param handle number
---@return Object|nil
function h2o(handle)
    if (handle == nil) then
        return nil
    end
    return oop._h2o[handle]
end

---@param handle number
---@return Player|nil
function h2p(handle)
    return h2o(handle)
end

---@param handle number
---@return Unit|nil
function h2u(handle)
    return h2o(handle)
end

---@param handle number
---@return Item|nil
function h2i(handle)
    return h2o(handle)
end

---@param obj Object
---@return string[]
function classHierarchy(obj)
    local chain = {}
    if (type(obj) ~= "table" or isDestroy(obj)) then
        return chain
    end
    
    while (obj ~= nil) do
        if (getmetatable(obj)) then
            chain[#chain + 1] = getmetatable(obj).__index._className
            obj = getmetatable(obj).__index
        else
            break
        end
    end
    return chain
end

---@param obj Object
---@return string
function classHierarchyString(obj)
    return table.concat(classHierarchy(obj), '->')
end

---@param obj Object
---@param className string
---@return boolean
function isClass(obj, className)
    local classType = Classes[className]
    if (type(obj) ~= "table" or type(classType) ~= "table") then
        return false
    end
    if (isDestroy(obj)) then
        return false
    end
    if (obj == classType or (getmetatable(obj) and getmetatable(obj).__index == classType)) then
        return true
    end
    return false
end

---@param obj Object
---@vararg string
---@return boolean
function inClass(obj, ...)
    local r = false
    for _, v in ipairs({ ... }) do
        if (isClass(obj, v)) then
            r = true
            break
        end
    end
    return r
end

---@param key string
---@param class string
---@return boolean
function isStaticClass(key, class)
    return isClass(oop._static[class .. key], class)
end

---@param obj Object
---@return boolean
function isObject(obj)
    return type(obj) == "table" and type(obj._className) == "string"
end

---@param obj Object
---@param className string
---@return boolean
function instanceof(obj, className)
    local classType = Classes[className]
    if (type(obj) ~= "table" or type(classType) ~= "table") then
        return false
    end
    if (isDestroy(obj)) then
        return false
    end
    while (obj ~= nil) do
        if (obj == classType) then
            return true
        end
        obj = getmetatable(obj) and getmetatable(obj).__index
    end
    return false
end

---@param obj Object
---@param handle number
---@return void
function href(obj, handle)
    if (obj._id ~= nil) then
        local un = function()
            obj:clear("superposition")
            if (obj._handle ~= nil) then
                if (isClass(obj, UnitClass)) then
                    J.RemoveUnit(obj._handle)
                elseif (isClass(obj, ItemClass)) then
                    J.RemoveUnit(obj._handle)
                elseif (isClass(obj, PlayerClass)) then
                    J.RemovePlayer(obj._handle, PLAYER_GAME_RESULT_DEFEAT)
                elseif (isClass(obj, DialogClass)) then
                    ---@type Array
                    local buttons = obj:prop("buttons")
                    local keys = buttons:keys()
                    if (#keys > 0) then
                        for _, k in ipairs(keys) do
                            J.HandleUnRef(math.round(tonumber(k)))
                        end
                    end
                    buttons = nil
                    J.DialogClear(obj._handle)
                    J.DialogDestroy(obj._handle)
                elseif (isClass(obj, QuestClass)) then
                    J.DestroyQuest(obj._handle)
                elseif (isClass(obj, RegionClass)) then
                    J.RemoveRegion(obj._handle)
                elseif (isClass(obj, EffectClass)) then
                    japi.YD_SetEffectSize(obj._handle, 0.01)
                    J.DestroyEffect(obj._handle)
                elseif (isClass(obj, EffectAttachClass)) then
                    japi.YD_SetEffectSize(obj._handle, 0.01)
                    J.DestroyEffect(obj._handle)
                elseif (isClass(obj, FogModifierClass)) then
                    J.DestroyFogModifier(obj._handle)
                end
                J.HandleUnRef(obj._handle)
                oop._h2o[obj._handle] = nil
                obj._handle = nil
            end
        end
        if (handle ~= nil and handle > 0) then
            un()
            J.HandleRef(handle)
            obj._handle = handle
            oop._h2o[obj._handle] = obj
        else
            un()
        end
    end
end

---@param class Class
---@return Class|nil
function super(class)
    local s = getmetatable(class)
    if (type(s) == "table" and s.__index) then
        return s.__index
    end
end

---@param obj Object
function isDestroy(obj)
    return type(obj) ~= "table" or oop._i2o[obj._id] == nil
end

---@param obj Object
function destroy(obj, delay)
    if (isDestroy(obj)) then
        return
    end
    if (false == isObject(obj)) then
        print(tostring(obj) .. "IsNotAnObject")
        return
    end
    if (obj._protect == true) then
        print(obj._id .. "IsProtecting")
        return
    end
    local classType = Class(obj._className)
    delay = delay or 0
    if (delay < 0) then
        delay = 0
    end
    do
        local destruct
        destruct = function(c)
            if rawget(c, "destruct") then
                c.destruct(obj)
            end
            local super = getmetatable(c)
            if super ~= nil and super.__index then
                destruct(super.__index)
            end
        end
        if (delay == 0) then
            destruct(classType)
        else
            time.setTimeout(delay, function(_)
                if (false == isDestroy(obj)) then
                    destruct(classType)
                end
            end)
        end
    end
end