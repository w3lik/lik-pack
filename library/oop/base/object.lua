---@return Object|nil
function ObjectID(className)
    if (oop._oid[className] == nil) then
        oop._oid[className] = {}
    end
    local aid = async._id
    if (oop._oid[className][aid] == nil) then
        oop._oid[className][aid] = 0
    end
    oop._oid[className][aid] = oop._oid[className][aid] + 1
    return string.format('%s:%s:%s:%s', className, aid, time._inc or 0, oop._oid[className][aid])
end

---@param className string
---@param setting nil|{protect:boolean,static:string,options:table}
---@vararg any
---@return Object|nil
function Object(className, setting)
    must(type(className) == "string")
    local classType = Class(className)
    if (type(classType) == "table" and classType._type == "Class") then
        local _protect = false
        local _static
        setting = setting or {}
        if (type(setting.protect) == "boolean") then
            _protect = setting.protect
        end
        if (setting.static ~= nil) then
            _static = className .. tostring(setting.static)
        end
        if (_static ~= nil) then
            local cc = oop._static[_static]
            if (type(cc) == "table" and cc._type == "Object") then
                return cc
            end
        end
        ---@class Object:Class
        local o = {
            ---@private
            _type = "Object",
            ---@private
            _protect = _protect,
            ---@private
            _static = _static,
        }
        setmetatable(o, { __index = classType })
        --- static
        if (_static ~= nil) then
            oop._static[_static] = o
        end
        --- construct
        do
            local options = setting.options or {}
            local construct
            construct = function(c)
                local super = getmetatable(c)
                if super ~= nil and super.__index then
                    construct(super.__index)
                end
                if rawget(c, "construct") then
                    c.construct(o, options)
                    event.reactTrigger(EVENT.Object.Construct, { triggerObject = o, className = c._className })
                end
            end
            construct(classType)
        end
        return o
    end
end