---@class FrameText:FrameTextClass
---@param frameIndex string 索引名
---@param parent Frame
---@param fdfName string|nil
---@return FrameText
function FrameText(frameIndex, parent, fdfName)
    must(frameIndex ~= nil)
    return Object(FrameTextClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = fdfName or "FRAMEWORK_TEXT",
            fdfType = "TEXT",
        }
    })
end
