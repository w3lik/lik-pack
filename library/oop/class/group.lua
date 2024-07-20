---@alias GroupEnum Unit|Item|Effect|UIKit|number
---@class GroupClass:Class
local class = Class(GroupClass)

---@private
function class:construct()
    self:prop("data", {})
end

---@private
function class:destruct()
    self:clear("data")
end

--- 组统计
---@param scope string
---@return Array
function class:count(scope)
    return self:data(scope):count()
end

--- 域数据
---@param scope string
---@return Array
function class:data(scope)
    local d = self:prop("data")
    local s = d[scope]
    if (false == isClass(s, ArrayClass)) then
        s = Array()
        d[scope] = s
    end
    return s
end

--- 域统计
---@param scope string
---@return number
function class:count(scope)
    return self:data(scope):count()
end

--- 插入对象
---@protected
---@param obj GroupEnum
---@return void
function class:insert(obj)
    if (isDestroy(obj)) then
        return
    end
    local d = self:data(obj:className())
    if (d ~= nil and false == d:keyExists(obj:id())) then
        d:set(obj:id(), obj)
    end
end

--- 删除对象
---@protected
---@param obj GroupEnum
---@return void
function class:remove(obj)
    if (isDestroy(obj)) then
        return
    end
    local d = self:data(obj:className())
    if (d ~= nil and d:keyExists(obj:id())) then
        d:set(obj:id(), nil)
    end
end

--- 根据条件，获取域内对象数组
---@alias unitGroupOptionsCircle {x:number,y:number,radius:number}
---@alias unitGroupOptionsSquare {x:number,y:number,width:number,height:number}
---@alias unitGroupOptionsCorner {number,number,number,number} 对应 xMin,yMin,xMax,yMax
---@alias unitGroupOptions {region:Region,square:unitGroupOptionsSquare,circle:unitGroupOptionsCircle,corner:unitGroupOptionsCorner,limit:number,filter:fun(enum:GroupEnum)}
---@param scope string
---@param options unitGroupOptions
---@return GroupEnum[]
function class:catch(scope, options)
    local res = {}
    ---@param enum GroupEnum
    self:data(scope):backEach(function(_, enum)
        if (enum == nil) then
            self:remove(enum)
            return
        elseif (isObject(enum) and isDestroy(enum)) then
            self:remove(enum)
            return
        end
        if (type(options) == "table") then
            if (#res >= (options.limit or 100)) then
                return false
            end
            if (options.region or options.square or options.circle or options.corner) then
                local ex, ey
                if (isClass(enum, UnitClass)) then
                    ex, ey = enum:x(), enum:y()
                elseif (isClass(enum, ItemClass)) then
                    ex, ey = enum:x(), enum:y()
                elseif (isClass(enum, EffectClass)) then
                    ex, ey = enum:x(), enum:y()
                elseif (scope == "destructable" and type(enum) == "number") then
                    ex, ey = J.GetDestructableX(enum), J.GetDestructableY(enum)
                end
                if (ex == nil or ey == nil) then
                    return
                end
                if (isClass(options.region, RegionClass)) then
                    if (false == options.region:isInside(ex, ey)) then
                        return
                    end
                end
                if (type(options.square) == "table") then
                    local xMin = options.square.x - options.square.width * 0.5
                    local yMin = options.square.y - options.square.height * 0.5
                    local xMax = options.square.x + options.square.width * 0.5
                    local yMax = options.square.y + options.square.height * 0.5
                    if ((ex < xMax and ex > xMin and ey < yMax and ey > yMin) == false) then
                        return
                    end
                end
                if (type(options.circle) == "table") then
                    if (options.circle.radius < vector2.distance(options.circle.x, options.circle.y, ex, ey)) then
                        return
                    end
                end
                if (type(options.corner) == "table" and #options.corner == 4) then
                    if (ex < options.corner[1] or ey < options.corner[2] or ex > options.corner[3] or ey > options.corner[4]) then
                        return
                    end
                end
            end
            if (type(options.filter) == "function") then
                if (options.filter(enum) ~= true) then
                    return
                end
            end
        end
        res[#res + 1] = enum
    end)
    return res
end

--- 遍历域对象
---@param scope string
---@param options unitGroupOptions
---@param action fun(enum:GroupEnum):void
---@return void
function class:forEach(scope, options, action)
    local catch = self:catch(scope, options)
    if (#catch > 0) then
        for i = #catch, 1, -1 do
            action(catch[i])
        end
    end
end

--- 获取域内随机1|N个对象
--- 此方法不能超出符合捕获条件的数量极限
---@param scope string
---@param options unitGroupOptions
---@param n number 1?
---@return GroupEnum|GroupEnum[]
function class:rand(scope, options, n)
    local catch = self:catch(scope, options)
    n = n or 1
    if (#catch >= 1) then
        local m = math.min(#catch, n)
        local r = table.rand(catch, m)
        if (n == 1) then
            return r
        elseif (m == 1) then
            return { r }
        else
            return r
        end
    else
        if (n == 1) then
            return nil
        else
            return {}
        end
    end
end

--- 获取域内离选定的(x,y)最近的对象
--- 必须设定filter里面的x,y参数,radius默认600
---@param scope string
---@param options unitGroupOptions
---@return GroupEnum
function class:closest(scope, options)
    local x, y
    if (options.circle ~= nil) then
        x = x or options.circle.x
        y = y or options.circle.y
    end
    if (options.square ~= nil) then
        x = x or options.square.x
        y = y or options.square.y
    end
    if (x == nil or y == nil) then
        return nil
    end
    local catch = self:catch(scope, options)
    if (#catch <= 0) then
        return nil
    end
    local closer
    local closestDst = 99999
    for _, c in ipairs(catch) do
        local dst = vector2.distance(x, y, c:x(), c:y())
        if (dst < closestDst) then
            closer = c
            closestDst = dst
        end
    end
    return closer
end