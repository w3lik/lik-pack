---@class FrameLabel:FrameLabelClass
---@param frameIndex string 索引名
---@param parent Frame
---@return FrameLabel
function FrameLabel(frameIndex, parent)
    must(frameIndex ~= nil)
    return Object(FrameLabelClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_BACKDROP",
            fdfType = "BACKDROP",
        }
    })
end
