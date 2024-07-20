---@class UnitTpl:UnitTplClass
---@param speechAlias string
---@return UnitTpl
function UnitTpl(speechAlias)
    if (speechAlias == nil) then
        speechAlias = ''
    end
    must(type(speechAlias) == "string", "speechAliasType")
    must(speechAlias == '' or FRAMEWORK_SPEECH[speechAlias] == true, speechAlias)
    return Object(UnitTplClass, {
        options = {
            speechAlias = speechAlias,
        }
    })
end
