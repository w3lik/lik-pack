---@class Unit:UnitClass
---@param tpl UnitTpl
---@param owner Player
---@param x number 坐标X[可选:0]
---@param x number 坐标Y[可选:0]
---@param facing number 面向角度[可选:270]
---@return Unit
function Unit(tpl, owner, x, y, facing)
    must(isClass(tpl, UnitTplClass))
    must(isClass(owner, PlayerClass))
    return Object(UnitClass, {
        options = {
            tpl = tpl,
            owner = owner,
            x = x,
            y = y,
            facing = facing,
        }
    })
end
