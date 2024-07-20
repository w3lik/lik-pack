---@class TeamClass:Class
local class = Class(TeamClass)

---@private
function class:construct(options)
    self:prop("key", options.key)
    self:prop("name", options.key)
    self:prop("nameSync", false)
    self:prop("colorSync", false)
    self:prop("members", {})
    self:prop("counter", {})
end

--- 名字同步
--- 设为true后，成员的名称会同步跟随队伍的名称（一般用于通用共同敌人）
---@param modify boolean|nil
---@return self|boolean
function class:nameSync(modify)
    if (type(modify) == "boolean") then
        if (true == modify and self:name()) then
            local ms = self:members()
            if (#ms > 0) then
                for _, i in ipairs(ms) do
                    Player(i):name(self:name())
                end
            end
        end
        return self:prop("nameSync", modify)
    end
    return self:prop("nameSync")
end

--- 全员颜色同步
--- 设为true后，成员的颜色以及他单位的颜色都会同步跟随队伍的颜色（一般用于通用共同敌人）
---@param modify boolean|nil
---@return self|boolean
function class:colorSync(modify)
    if (type(modify) == "boolean") then
        if (true == modify and self:color()) then
            local ms = self:members()
            if (#ms > 0) then
                for _, i in ipairs(ms) do
                    Player(i):teamColor(self:color())
                end
            end
        end
        return self:prop("colorSync", modify)
    end
    return self:prop("colorSync")
end

--- 队伍名称
---@param modify string|nil
---@return self|string
function class:name(modify)
    local prev = self:prop("name")
    if (modify == nil) then
        return prev
    end
    if (prev ~= modify) then
        self:prop("name", modify)
        if (true == self:nameSync()) then
            local ms = self:members()
            if (#ms > 0) then
                for _, i in ipairs(ms) do
                    if (modify) then
                        Player(i):name(modify)
                    end
                end
            end
        end
    end
    return self
end

--- 为队伍设置统一的颜色
--- 一般用于通用共同敌人
--- 使用玩家索引1-12决定颜色值
---@param modify number|nil
---@return self|number
function class:color(modify)
    local prev = self:prop("color")
    if (modify == nil) then
        return prev
    end
    if (prev ~= modify) then
        self:prop("color", modify)
        if (true == self:colorSync()) then
            local ms = self:members()
            if (#ms > 0) then
                if (modify) then
                    for _, i in ipairs(ms) do
                        Player(i):teamColor(modify)
                    end
                end
            end
        end
    end
    return self
end

--- 队伍成员玩家（只控制索引）
---@param modify number[]|nil
---@return self|number[]
function class:members(modify)
    if (modify ~= nil) then
        if (type(modify) ~= "table") then
            return self
        end
        local pls = {}
        local c, mn
        if (self:colorSync()) then
            c = self:color()
        end
        if (self:colorSync()) then
            mn = self:name()
        end
        for _, m in ipairs(modify) do
            if (type(m) == "number") then
                if (false == table.includes(pls, m)) then
                    table.insert(pls, m)
                    if (c ~= nil) then
                        Player(m):teamColor(c)
                    end
                    if (mn ~= nil) then
                        Player(m):name(mn)
                    end
                end
            end
        end
        self:prop("members", pls)
        -- 联盟
        if (#pls > 0) then
            for _, i in ipairs(pls) do
                for _, j in ipairs(pls) do
                    if (i ~= j) then
                        alliance.ally(Player(i), Player(j), true)
                        alliance.vision(Player(i), Player(j), true)
                        alliance.control(Player(i), Player(j), false)
                        alliance.fullControl(Player(i), Player(j), false)
                    end
                end
            end
        end
        return self
    end
    return self:prop("members")
end

--- 在队伍玩家内创建一个单位
--- 这个单位的拥有者会自动分配给队伍内的某个玩家
--- 一般用于通用共同敌人
function class:unit(tpl, x, y, facing)
    local ms = self:members()
    must(#ms > 0)
    local counter = self:prop("counter")
    local i = 0
    local c = 101
    for _, m in ipairs(ms) do
        if (counter[m] == nil) then
            counter[m] = 0
            i = m
            break
        end
        if (counter[m] < c) then
            i = m
            c = counter[m]
        end
    end
    counter[i] = counter[i] + 1
    if (counter[i] >= 100) then
        for _, m in ipairs(ms) do
            counter[m] = 0
        end
    end
    local u = Unit(tpl, Player(i), x, y, facing)
    if (u) then
        u:teamColor(self:color())
    end
    return u
end