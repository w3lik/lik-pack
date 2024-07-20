---@class datum 数据
datum = datum or {}

--- 坐标位置集合
---@type <string,number>
datum._position = datum._position or {}

--- 默认值
--- 当value可能为false不能简单使用or处理时可使用此方法
---@param value any 原数据
---@param defValue any 备用数据
---@return any
function datum.default(value, defValue)
    if (nil == value) then
        return defValue
    end
    return value
end

--- 比较两个数据是否相同
---@param data1 table array
---@param data2 table array
---@return boolean
function datum.equal(data1, data2)
    if (data1 == nil and data2 == nil) then
        return true
    end
    if (data1 == nil or data2 == nil) then
        return false
    end
    if (type(data1) ~= type(data2)) then
        return false
    end
    if (type(data1) == "table") then
        return table.equal(data1, data2)
    end
    return data1 == data2
end

--- 返回一个key<string>和function
--- 当复合参数key不存在时，key默认为default
--- 当func不存在时，为nil
---@vararg string|function
---@return string,function|nil
function datum.keyFunc(...)
    local data = { ... }
    local key = "default"
    if (type(data[1]) == "string") then
        key = data[1]
        table.remove(data, 1)
    end
    return key, table.unpack(data)
end

--- 三目值
---@param bool boolean 当有且仅有等于true时返回tVal，否则返回fVal
---@param tVal any True值
---@param fVal any False值
---@return any
function datum.ternary(bool, tVal, fVal)
    if (bool == true) then
        return tVal
    else
        return fVal
    end
end

--- 寻找未被占用坐标
---@protected
---@param x number
---@param y number
---@return number,number
function datum.findPosition(x, y)
    local nx = 0
    local ny = 0
    local d = 32
    if (nil ~= x and nil ~= y) then
        x = d * math.round(x / d)
        y = d * math.round(y / d)
        nx = x
        ny = y
        local pos = datum._position
        local ik = x .. '_' .. y
        local bic = 0
        local bor = 1
        local bi = 0
        while (pos[ik] == 1) do
            if (bi == 0) then
                bic = bic + 1
                bor = bor + 2
                nx = x + d * bic
                ny = y + d * bic
            elseif (bi < bor * 1 - 0) then
                ny = ny - d
            elseif (bi < bor * 2 - 1) then
                nx = nx - d
            elseif (bi < bor * 3 - 2) then
                ny = ny + d
            else
                nx = nx + d
            end
            bi = bi + 1
            if (bi >= (bor - 1) * 4) then
                bi = 0
            end
            ik = nx .. '_' .. ny
        end
        pos[ik] = 1
    end
    return nx, ny
end

--- 施放占用坐标
---@protected
---@return void
function datum.freePosition(x, y)
    if (nil ~= x and nil ~= y) then
        x = math.round(x)
        y = math.round(y)
        local ik = x .. '_' .. y
        datum._position[ik] = nil
    end
end