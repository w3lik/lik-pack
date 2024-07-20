---@return Player
function PlayerLocal()
    local i = 1 + J.GetPlayerId(J.Common["GetLocalPlayer"]())
    must(isStaticClass(i, PlayerClass), "StaticPlayerUninitialized")
    return Player(i)
end