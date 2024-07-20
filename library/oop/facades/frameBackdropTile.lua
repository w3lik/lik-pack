---@class FrameBackdropTile:FrameBackdropTileClass
---@param frameIndex string 索引名
---@param parent Frame
---@param fdfName string
---@return FrameBackdropTile
function FrameBackdropTile(frameIndex, parent, fdfName)
    must(frameIndex ~= nil)
    return Object(FrameBackdropTileClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            parent = parent,
            fdfName = fdfName or "FRAMEWORK_BACKDROP_TILE",
            fdfType = "BACKDROP",
        }
    })
end
