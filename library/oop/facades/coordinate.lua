---@class Coordinate:CoordinateClass
---@param x number
---@param y number
---@param z number
---@return Coordinate|nil
function Coordinate(x, y, z)
    must(type(x) == "number")
    must(type(y) == "number")
    must(z == nil or type(z) == "number")
    x = math.round(x)
    y = math.round(y)
    z = math.round(z or japi.Z(x, y))
    return Object(CoordinateClass, {
        static = table.concat({ x, y, z }, '_'),
        options = {
            x = x,
            y = y,
            z = z,
        }
    })
end
