--- 图像的贴图影响显示效果，当边上有非alpha像素时，容易造成渲染溢出，所以建议图四边都留1像素的透明边
---@class Image:ImageClass
---@param texture string
---@param width number
---@param height number
---@return Image|nil
function Image(texture, width, height)
    must(type(texture) == "string")
    must(type(width) == "number")
    if (type(height) ~= "number") then
        height = width
    end
    return Object(ImageClass, {
        options = {
            texture = texture,
            width = width,
            height = height,
        }
    })
end