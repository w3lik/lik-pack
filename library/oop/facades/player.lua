---@class Player:PlayerClass
---@param index number integer
---@return Player
function Player(index)
    index = math.floor(index)
    must(type(index) == "number" and index > 0 and index <= BJ_MAX_PLAYER_SLOTS)
    return Object(PlayerClass, {
        protect = true,
        static = index,
        options = {
            index = index,
        }
    })
end