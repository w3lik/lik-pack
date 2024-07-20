---@class Game:GameClass
---@return Game
function Game()
    return Object(GameClass, {
        protect = true,
        static = '_',
    })
end