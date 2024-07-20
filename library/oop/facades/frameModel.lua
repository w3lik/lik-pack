---@class FrameModel:FrameModelClass
---@param frameIndex string 索引名
---@param parent Frame
---@return FrameModel
function FrameModel(frameIndex, parent)
    must(frameIndex ~= nil)
    return Object(FrameModelClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = "FRAMEWORK_MODEL",
            fdfType = "SPRITE",
        }
    })
end
