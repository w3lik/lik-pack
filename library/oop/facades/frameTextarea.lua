---@class FrameTextarea:FrameTextareaClass
---@param frameIndex string 索引名
---@param parent Frame
---@return FrameTextarea
function FrameTextarea(frameIndex, parent)
    must(frameIndex ~= nil)
    return Object(FrameTextareaClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_TEXTAREA",
            fdfType = "TEXTAREA",
        }
    })
end
