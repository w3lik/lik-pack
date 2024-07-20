--- 常态化Lighting
---@class Lightning:LightningClass
---@param lightningType table LIGHTNING_TYPE
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@return Lightning|nil
function Lightning(lightningType, x1, y1, z1, x2, y2, z2)
    must(type(lightningType) == "table")
    return Object(LightningClass, {
        options = {
            lightningType = lightningType,
            x1 = x1 or 0,
            y1 = y1 or 0,
            z1 = z1 or 0,
            x2 = x2 or 0,
            y2 = y2 or 0,
            z2 = z2 or 0,
        }
    })
end
