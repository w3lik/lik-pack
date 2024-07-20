---@class Server:ServerClass
---@param bindPlayer Player
---@return nil|Server
function Server(bindPlayer)
    must(isClass(bindPlayer, PlayerClass))
    return Object(ServerClass, {
        static = bindPlayer:index(),
        options = {
            bindPlayer = bindPlayer,
        }
    })
end
