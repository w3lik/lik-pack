---@class FrameTooltips:FrameTooltipsClass
---@param index number 序号0框架保留使用，请使用其他1-3号序号或缺省（默认1）
---@return FrameTooltips
function FrameTooltips(index)
    index = math.floor(index or 1)
    must(type(index) == "number")
    must(index >= 0 and index <= 3)
    local frameIndex = FrameTooltipsClass .. index
    return Object(FrameTooltipsClass, {
        static = frameIndex,
        options = {
            frameIndex = frameIndex,
            fdfName = "FRAMEWORK_BACKDROP_TOOLTIP",
            fdfType = "BACKDROP",
        }
    })
end