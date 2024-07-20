---@class FrameCustom:FrameCustomClass
---@param frameIndex string 索引名
---@param parent Frame
---@param fdfName string
---@param fdfType string|nil
---@return FrameCustom
function FrameCustom(frameIndex, parent, fdfName, fdfType)
    must(frameIndex ~= nil and fdfName ~= nil and fdfType ~= nil)
    return Object(FrameCustomClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = fdfName,
            fdfType = fdfType,
        }
    })
end
