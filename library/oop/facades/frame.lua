---@class Frame:FrameClass
---@param frameIndex any
---@param frameId number
---@param parent Frame|nil
---@return Frame
function Frame(frameIndex, frameId, parent)
    must(frameIndex ~= nil)
    if (frameId == nil) then
        must(isStaticClass(frameIndex, FrameClass))
    end
    return Object(FrameClass, {
        static = frameIndex,
        options = {
            parent = parent,
            frameIndex = frameIndex,
            frameId = frameId,
        }
    })
end
