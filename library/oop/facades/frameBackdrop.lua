---@class FrameBackdrop:FrameBackdropClass
---@param frameIndex string 索引名
---@param parent Frame
---@param fdfName string
---@return FrameBackdrop
function FrameBackdrop(frameIndex, parent, fdfName)
    must(frameIndex ~= nil)
    return Object(FrameBackdropClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = fdfName or "FRAMEWORK_BACKDROP",
            fdfType = "BACKDROP",
        }
    })
end
