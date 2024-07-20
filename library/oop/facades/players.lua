---@param indexes nil|number[]
---@return Player[]
function Players(indexes)
    local ps = {}
    if (indexes == nil) then
        indexes = table.section(1, BJ_MAX_PLAYER_SLOTS)
    end
    if (#indexes > 0) then
        for _, i in ipairs(indexes) do
            if (isClass(Player(i), PlayerClass)) then
                table.insert(ps, Player(i))
            end
        end
    end
    return ps
end

---@param call fun(enumPlayer:Player,enumIndex:number)
---@return void
function PlayersForeach(call)
    for i = 1, BJ_MAX_PLAYERS do
        local p = Player(i)
        if (p:isPlaying() and p:isUser()) then
            call(p, i)
        end
    end
end