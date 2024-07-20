---@class FrameButton:FrameButtonClass
---@param frameIndex string 索引名
---@param parent Frame
---@param highlightFdfName string|nil
---@return FrameButton
function FrameButton(frameIndex, parent, highlightFdfName)
    must(frameIndex ~= nil)
    return Object(FrameButtonClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_BACKDROP",
            fdfType = "BACKDROP",
            highlightFdfName = highlightFdfName,
        }
    })
end
