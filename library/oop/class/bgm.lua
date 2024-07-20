---@class BgmClass:Class
local class = Class(BgmClass)

---@private
function class:construct()
    self:prop("volume", 100)
end

--- 是否播放中
---@return boolean
function class:isPlaying()
    return self:prop("currentMusic") ~= nil and self:prop("currentMusic") ~= ""
end

--- 当前播放音乐
---@return string|nil
function class:currentMusic()
    local cm = self:prop("currentMusic")
    if (cm == "") then
        cm = nil
    end
    return cm
end

--- 音量[0%-100%]
---@param modify number|nil
---@return self|number
function class:volume(modify)
    return self:prop("volume", modify)
end

--- 停止
---@return void
function class:stop()
    self:prop("currentMusic", "")
end

--- 播放
---@param musicAlias string
---@return void
function class:play(musicAlias)
    musicAlias = assets.bgm(musicAlias)
    if (musicAlias == nil) then
        return
    end
    self:prop("currentMusic", musicAlias)
end