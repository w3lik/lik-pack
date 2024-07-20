---@class camera
camera = camera or {}

--- 当前镜头X地图目标坐标
---@return number
function camera.x()
    return japi.CameraTargetX()
end

--- 当前镜头Y地图目标坐标
---@return number
function camera.y()
    return japi.CameraTargetY()
end

--- 当前镜头Z地图目标坐标
---@return number
function camera.z()
    return japi.CameraTargetZ()
end

--- 远景截断距离
---@param value number|nil
---@return number
function camera.farZ(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_FARZ, value, 100, 3000)
    end
    return japi.CameraFarZ()
end

--- Z轴偏移（高度偏移）
---@param value number|nil
---@return number
function camera.zOffset(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_ZOFFSET, value, -1000, 3000)
    end
    return japi.CameraZOffset()
end

--- 观察角度
---@param value number|nil
---@return number
function camera.fov(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_FIELD_OF_VIEW, value, 20, 120)
    end
    return math._r2d * japi.CameraFOV()
end

--- X轴翻转角度
---@param value number|nil
---@return number
function camera.traX(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_FIELD_OF_VIEW, value, 270, 350)
    end
    return math._r2d * japi.CameraTraX()
end

--- Y轴翻转角度
---@param value number|nil
---@return number
function camera.traY(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_ROLL, value, 80, 280)
    end
    return math._r2d * japi.CameraTraY()
end

--- Z轴翻转角度
---@param value number|nil
---@return number
function camera.traZ(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_ROTATION, value, 80, 280)
    end
    return math._r2d * japi.CameraTraZ()
end

--- 镜头距离
---@param value number|nil
---@return number
function camera.distance(value)
    if (type(value) == "number") then
        japi.CameraSetField(CAMERA_FIELD_TARGET_DISTANCE, value, 400, 3000)
    end
    return japi.CameraDistance()
end

--- 重置镜头
---@param duration number
---@return void
function camera.reset(duration)
    J.CameraSetSourceNoise(0, 0)
    J.CameraSetTargetNoise(0, 0)
    J.ResetToGameCamera(duration)
end

--- 设置空格坐标
--- 空格设置魔兽最大记录8个队列位置，不定死坐标则按空格时轮循跳转
--- 如要完全定死一个坐标，需要强行覆盖8次
---@param x number
---@param y number
---@param unique boolean 是否定死坐标记录,默认不锁死
---@return void
function camera.spacePosition(x, y, unique)
    if (type(unique) ~= "boolean") then
        unique = false
    end
    if (unique) then
        for _ = 1, 8, 1 do
            J.SetCameraQuickPosition(x, y)
        end
    else
        J.SetCameraQuickPosition(x, y)
    end
end

--- 设置镜头坐标到XY
---@param x number
---@param y number
---@param duration number
---@return void
function camera.to(x, y, duration)
    duration = duration or 0
    J.PanCameraToTimed(x, y, duration)
end

--- 锁定镜头跟踪某单位
---@param whichUnit Unit
---@return void
function camera.follow(whichUnit)
    J.SetCameraTargetController(whichUnit:handle(), 0, 0, false)
end

--- 摇晃镜头
---@param magnitude number 幅度
---@param velocity number 速率
---@param duration number 持续时间
---@return void
function camera.shake(magnitude, velocity, duration)
    magnitude = magnitude or 0
    velocity = velocity or 0
    duration = math.trunc(duration or 0, 2)
    if (magnitude <= 0 or velocity <= 0 or duration <= 0) then
        return
    end
    J.CameraSetTargetNoise(magnitude, velocity)
    async.setTimeout(duration * 60, function()
        J.CameraSetTargetNoise(0, 0)
    end)
end

--- 震动镜头
---@param magnitude number 幅度
---@param duration number 持续时间
---@return self
function camera.quake(magnitude, duration)
    magnitude = magnitude or 0
    duration = math.trunc(duration or 0, 2)
    if (magnitude <= 0 or duration <= 0) then
        return
    end
    local richter = magnitude
    if (richter > 5) then
        richter = 5
    end
    if (richter < 2) then
        richter = 2
    end
    J.CameraSetTargetNoiseEx(magnitude * 2, magnitude * (10 ^ richter), true)
    J.CameraSetSourceNoiseEx(magnitude * 2, magnitude * (10 ^ richter), true)
    async.setTimeout(duration * 60, function()
        J.CameraSetSourceNoise(0, 0)
        J.CameraSetTargetNoise(0, 0)
    end)
end

--- 当镜头移动
---@param key string
---@param callFunc fun(evtData:evtOnCameraMoveData)
---@return void
function camera.onMove(key, callFunc)
    event.asyncRegister("camera", EVENT.Camera.Move, key, callFunc)
end