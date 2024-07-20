---@class Ability:AbilityClass
---@param tpl AbilityTpl
---@return Ability
function Ability(tpl)
    must(isClass(tpl, AbilityTplClass))
    return Object(AbilityClass, {
        options = {
            tpl = tpl,
        }
    })
end