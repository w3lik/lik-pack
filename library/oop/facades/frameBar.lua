---@class FrameBar:FrameBarClass
---@param frameIndex string 索引名
---@param parent Frame
---@param fdfName string 模版边框(可选) 启用边框时，边框也会算进整体宽高里，自行设置borderOffset调整
---@param borderOffset number 边框模式下的内置位置调整值，默认0.007
---@return FrameBar
function FrameBar(frameIndex, parent, fdfName, borderOffset)
    must(frameIndex ~= nil)
    return Object(FrameBarClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            borderOffset = borderOffset,
            fdfName = fdfName or "FRAMEWORK_BACKDROP",
            fdfType = "BACKDROP",
        }
    })
end
