---@class Region:RegionClass
---@param key string 唯一标识key
---@param shape string | "'square'" | "'circle'"
---@param x number
---@param y number
---@param width number
---@param height number
---@return Region|nil
function Region(key, shape, x, y, width, height)
    must(type(key) == "string")
    return Object(RegionClass, {
        static = key,
        options = {
            key = key,
            shape = shape,
            x = x,
            y = y,
            width = width,
            height = height,
        }
    })
end
