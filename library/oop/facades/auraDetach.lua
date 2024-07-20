--- 领域解绑
---@param key string 领域名
---@return void
function AuraDetach(key)
    must(type(key) == "string")
    if (isStaticClass(key, AuraClass)) then
        destroy(oop._static[AuraClass .. key])
    end
end