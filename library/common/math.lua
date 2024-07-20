math._e = 2.7182818
math._pi = 3.1415926
math._r2d = 180 / math._pi
math._d2r = math._pi / 180

--- 判断数字是否为NaN
---@param decimal number
---@return boolean
function math.isNaN(decimal)
    local s = tostring(decimal)
    if (s == "inf" or s == "-nan(ind)") then
        return true
    end
    return false
end

--- 四舍五入取整
---@param decimal number
---@return number integer
function math.round(decimal)
    return math.floor(decimal + 0.5)
end

--- 随机整数
---@param n number
---@param m number
---@return number
function math.rand(n, m)
    if (n == nil or m == nil) then
        return 0
    end
    m = math.floor(m)
    n = math.floor(n)
    if (n == m) then
        return n
    end
    if (m < n) then
        return J.GetRandomInt(m, n)
    end
    return J.GetRandomInt(n, m)
end

--- 随机切割整数
---@param digit number integer 被切割的数
---@param n number integer 切割份数
---@return number[]
function math.divide(digit, n)
    digit = math.floor(digit)
    n = math.floor(n)
    if (n < 1) then
        n = 1
    end
    local div = {}
    while (n > 1) do
        n = n - 1
        local d = math.rand(0, digit)
        div[#div + 1] = d
        digit = digit - d
    end
    div[#div + 1] = digit
    return div
end

--- 数字格式化
---@param decimal number 数字
---@param n number 小数最大截断位，默认2位
---@return string
function math.format(decimal, n)
    n = math.floor(n or 2)
    if (n < 1) then
        local m = math.modf(decimal)
        return tostring(m)
    end
    return string.format('%.' .. n .. 'f', decimal)
end

--- 数字位数截断
---@param decimal number 数字
---@param n number 小数最大截断位，默认2位
---@return number
function math.trunc(decimal, n)
    return tonumber(math.format(decimal, n))
end

--- 两数正差额
---@param value1 number 数字1
---@param value2 number 数字2
---@return number
function math.disparity(value1, value2)
    if (value1 >= value2) then
        return value1 - value2
    end
    return value2 - value1
end

--- 数字格式化
---@param value number
---@param n number 小数最大截断位，默认2位
---@return string
function math.numberFormat(value, n)
    n = math.floor(n or 2)
    if (n < 1) then
        n = 2
    end
    if (value >= 1e12) then
        return string.format("%." .. n .. "f", value / 1e12) .. "T"
    elseif (value >= 1e9) then
        return string.format("%." .. n .. "f", value / 1e9) .. "B"
    elseif (value >= 1e6) then
        return string.format("%." .. n .. "f", value / 1e6) .. "M"
    elseif (value >= 1e4) then
        return string.format("%." .. n .. "f", value / 1e3) .. "K"
    else
        return string.format("%." .. n .. "f", value)
    end
end

--- 整型格式化
---@param value number
---@return string
function math.integerFormat(value)
    if (value >= 1e12) then
        return math.floor(value / 1e12) .. "T"
    elseif (value >= 1e9) then
        return math.floor(value / 1e9) .. "B"
    elseif (value >= 1e6) then
        return math.floor(value / 1e6) .. "M"
    elseif (value >= 1e4) then
        return math.floor(value / 1e3) .. "K"
    else
        return tostring(math.floor(value))
    end
end

--- 时间戳转日期对象
---@param timestamp number Unix时间戳
---@return table {Y:"年",m:"月",d:"日",H:"时",i:"分",s:"秒",w:"周[0-6]",W:"周[日-六]"}
function math.date(timestamp)
    local d = os.date("%Y|%m|%d|%H|%M|%S|%w", timestamp)
    d = string.explode("|", d)
    local W = { "日", "一", "二", "三", "四", "五", "六" }
    return {
        Y = d[1],
        m = d[2],
        d = d[3],
        H = d[4],
        i = d[5],
        s = d[6],
        w = d[7],
        W = W[d[7] + 1],
    }
end

--- 升级经验计算
---@param max number 最大等级
---@param fixed number 每级需要经验固定值
---@param ratio number 每级需要经验对上一级提升百分比(默认固定提升)
---@param limit number 每级需要经验上限
---@return number[]
function math.expNeeds(max, fixed, ratio, limit)
    local needs = {}
    local need = 0
    for i = 1, math.max(1, max) do
        if (i > 1) then
            fixed = math.max(1, fixed)
            ratio = math.max(1.00, ratio)
            local add = need * (ratio - 1.00) + fixed
            if (add >= limit) then
                add = limit
                need = math.floor(need / limit) * limit
            end
            need = need + add
            need = math.floor(need / 10) * 10
        end
        needs[i] = math.ceil(need)
    end
    return needs
end

--- 矩形内随机
---@param x number
---@param y number
---@param width number
---@param height number
---@return number,number
function math.square(x, y, width, height)
    local px = x + math.rand(-width / 2, width / 2)
    local py = y + math.rand(-height / 2, height / 2)
    if (px < RegionPlayable:xMin()) then
        px = RegionPlayable:xMin()
    elseif (px > RegionPlayable:xMax()) then
        px = RegionPlayable:xMax()
    end
    if (py < RegionPlayable:yMin()) then
        py = RegionPlayable:yMin()
    elseif (py > RegionPlayable:yMax()) then
        py = RegionPlayable:yMax()
    end
    return px, py
end

--- 高度斜率的角度
---@param z1 number
---@param z2 number
---@param distance number
---@return number
function math.slopeAngle(z1, z2, distance)
    return math._r2d * math.atan(z2 - z1, distance)
end

--- 奇妙计算
--- 专算字符串 ; == += -= *= /= 其他类型跳过
---@param variety string 目标值，如："+=10" | "*=10"
---@param base number|nil 基值|数字时可用，其他类型不可用
---@return any,number|nil diff只有在数字类型才会存在
function math.cale(variety, base)
    local val = variety
    local diff
    if (type(variety) == "string") then
        local opr = string.sub(variety, 1, 2)
        if (opr == "+=" or opr == "-=" or opr == "*=" or opr == "/=") then
            -- 相对值时必须带数字型基值
            if (opr == "*=" or opr == "/=") then
                must(type(base) == "number")
            end
            local vd = tonumber(string.sub(val, 3))
            if (vd ~= nil) then
                val = base or 0
                if (opr == "+=") then
                    diff = vd
                elseif (opr == "-=") then
                    diff = -vd
                elseif (opr == "*=") then
                    diff = base * (vd - 1)
                elseif (opr == "/=") then
                    if (vd ~= 0) then
                        diff = base * (1 / vd - 1)
                    else
                        diff = 0
                    end
                end
                val = val + diff
            end
        end
    end
    return val, diff
end