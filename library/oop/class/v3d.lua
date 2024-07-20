---@class V3dClass:Class
local class = Class(V3dClass)

---@private
function class:construct(options)
    href(self, J.CreateSound(assets.v3d(options.alias), false, true, true, 10, 10, "DefaultEAXON"))
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
---@param min number|nil
---@param max number|nil
---@return self|number[2]
function class:distances(min, max)
    if (type(min) == "number" and type(max) == "number") then
        local modify = { min, max }
        return self:prop("distances", modify)
    end
    return self:prop("distances")
end

--- 对单位绑定音效播放
---@param whichUnit Unit
---@return self
function class:unit(whichUnit)
    J.AttachSoundToUnit(self:handle(), whichUnit:handle())
    return self
end

--- 对坐标绑定音效并播放
---@param x number
---@param y number
---@param z number
---@return self
function class:xyz(x, y, z)
    J.SetSoundPosition(self:handle(), x, y, z)
    return self
end

--- 对区域绑定音效
---@param whichRegion Region
---@param duration number 等于0时为无限持续时间
---@return self
function class:region(whichRegion, duration)
    duration = duration or 0
    local width = whichRegion:width()
    local height = whichRegion:height()
    J.SetSoundPosition(self:handle(), whichRegion:x(), whichRegion:y(), 0)
    J.RegisterStackedSound(self:handle(), true, width, height)
    if (duration > 0) then
        time.setTimeout(duration, function(curTimer)
            destroy(curTimer)
            J.UnregisterStackedSound(self:handle(), true, width, height)
        end)
    end
    return self
end

--- 播放
---@return void
function class:play()
    J.StartSound(self:handle())
end