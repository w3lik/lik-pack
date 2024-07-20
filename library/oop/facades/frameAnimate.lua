---@class FrameAnimate:FrameAnimateClass
---@param frameIndex string 索引名
---@param parent Frame
---@return FrameAnimate
function FrameAnimate(frameIndex, parent)
    must(frameIndex ~= nil)
    return Object(FrameAnimateClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_BACKDROP",
            fdfType = "BACKDROP",
        }
    })
end
