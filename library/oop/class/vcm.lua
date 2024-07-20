---@class VcmClass:Class
local class = Class(VcmClass)

---@private
function class:construct(options)
    href(self, J.CreateSound(assets.vcm(options.alias), false, false, false, 10, 10, "DefaultEAXON"))
    J.SetSoundDuration(self:handle(), options.duration)
    self:prop("alias", options.alias)
    self:prop("duration", options.duration / 1000)
    self:prop("volume", 100) --%
    self:prop("pitch", 1)
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 获取时长[秒]
---@return number
function class:duration()
    return self:prop("duration")
end

--- 音量[0-100]
---@param modify number|nil
---@return self|number
function class:volume(modify)
    return self:prop("volume", modify)
end

--- 通道
---@see file variable/sound
---@param modify SOUND_CHANNEL|nil
---@return self|SOUND_CHANNEL
function class:channel(modify)
    return self:prop("channel", modify)
end

--- 音高
---@param modify number|nil
---@return self|number
function class:pitch(modify)
    return self:prop("pitch", modify)
end

--- 播放
---@return void
function class:play()
    J.StartSound(self:handle())
end