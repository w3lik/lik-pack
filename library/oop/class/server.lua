---@class ServerClass:Class
local class = Class(ServerClass)

---@private
function class:construct(options)
    self:prop("bindPlayer", options.bindPlayer)
end

--- 绑定玩家
---@return Player
function class:bindPlayer()
    return self:prop("bindPlayer")
end

--- 保存服务器数据
---@param key string
---@param value string|number|boolean
---@return void
function class:save(key, value)
    japi.ServerSaveValue(self:bindPlayer():handle(), key, value)
end

--- 读取服务器数据
---@param key string
---@param default any 默认值
---@return any
function class:load(key, default)
    return datum.default(japi.ServerLoadValue(self:bindPlayer():handle(), key), default)
end

--- 清理服务器数据
---@param key string
---@return void
function class:clear(key)
    japi.ServerSaveValue(self:bindPlayer():handle(), key, nil)
end

--- 设置房间服务器数据
---@param key string
---@param value string|number
---@return void
function class:room(key, value)
    japi.ServerSaveRoom(self:bindPlayer():handle(), key, value)
end