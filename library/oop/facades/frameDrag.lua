---@class FrameDrag:FrameDragClass
---@param frameIndex string 索引名
---@param parent Frame
---@return FrameDrag
function FrameDrag(frameIndex, parent)
    must(frameIndex ~= nil)
    return Object(FrameDragClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_BACKDROP",
            fdfType = "BACKDROP",
        }
    })
end
