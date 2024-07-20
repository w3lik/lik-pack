---@class FrameTextBlock:FrameTextBlockClass
---@param frameIndex string 索引名
---@param parent Frame
---@return FrameTextBlock
function FrameTextBlock(frameIndex, parent)
    must(frameIndex ~= nil)
    return Object(FrameTextBlockClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_BLOCK",
            fdfType = "TEXT",
        }
    })
end
