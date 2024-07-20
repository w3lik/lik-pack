---@class VwpClass:Class
local class = Class(VwpClass)

---@private
function class:construct(options)
    href(self, J.CreateSound(assets.vwp(options.alias), false, true, true, 10, 10, "CombatSoundsEAX"))
    J.SetSoundDuration(self:handle(), options.duration)
    self:prop("alias", options.alias)
    self:prop("duration", options.duration / 1000)
    self:prop("volume", 100) --%
    self:prop("pitch", 1)
    self:prop("distanceCutoff", 2000)
    self:prop("distances", { 500, 2500 })
end

--- handle
---@return number
function class:handle()
    return self._handle
end

--- 获取时长
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

--- 衰减截断范围
---@param modify number|nil
---@return self|number
function class:distanceCutoff(modify)
    return self:prop("distanceCutoff", modify)
end

--- 衰减范围[最小,最大]
---@param modify {number,number}|nil
---@return self|{number,number}
function class:distances(modify)
    return self:prop("distances", modify)
end

--- 播放
---@return void
function class:play()
    local targetObj = self:prop("targetObj")
    if (inClass(targetObj, UnitClass, ItemClass)) then
        J.AttachSoundToUnit(self:handle(), targetObj:handle())
        J.StartSound(self:handle())
    end
end