--- 连锁型Lighting
---@class LightningChain:LightningChainClass
---@param lightningType table LIGHTNING_TYPE
---@param unit1 Unit
---@param unit2 Unit
---@return LightningChain|nil
function LightningChain(lightningType, unit1, unit2)
    must(type(lightningType) == "table")
    must(isClass(unit1, UnitClass) and unit1:isAlive())
    must(isClass(unit2, UnitClass) and unit2:isAlive())
    return Object(LightningChainClass, {
        options = {
            lightningType = lightningType,
            unit1 = unit1,
            unit2 = unit2,
        }
    })
end
