---@class FrameHighlight:FrameHighlightClass
---@param frameIndex string 索引名
---@param parent Frame
---@param fdfName string|nil
---@return FrameHighlight
function FrameHighlight(frameIndex, parent, fdfName)
    must(frameIndex ~= nil)
    return Object(FrameHighlightClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = fdfName or "FRAMEWORK_HIGHLIGHT_HUMAN_CONSOLE",
            fdfType = "HIGHLIGHT",
        }
    })
end