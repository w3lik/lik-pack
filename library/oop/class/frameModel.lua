---@class FrameModelClass:FrameCustomClass
local class = Class(FrameModelClass):extend(FrameCustomClass)

--- 模型
---@param modify string|nil
---@return self|string
function class:model(modify)
    if (modify) then
        modify = assets.model(modify)
    end
    return self:prop("model", modify)
end

--- 动画
---@param animId string
---@param autoCast boolean
---@return self|{string,boolean}
function class:animate(animId, autoCast)
    if (animId and type(autoCast) == "boolean") then
        return self:prop("animate", { animId, autoCast })
    end
    return self:prop("animate")
end