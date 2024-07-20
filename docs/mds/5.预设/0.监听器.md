### 监听器

```lua
--- 恢复生命监听器
---@param obj Unit
Monitor("hp_regen")
    :frequency(0.2)
    :actionFunc(
    function(obj)
        local regen = 0.2 * obj:hpRegen()
        local cure = (obj:prop("cure") or 0) * 0.01
        local v = 0
        if (regen >= 0) then
            v = math.max(0, 1 + cure) * regen
            obj:hpCur("+=" .. v)
        else
            v = math.min(0, cure - 1) * regen
            obj:hpCur("-=" .. v)
        end
    end)
    :ignoreFilter(function(obj) return obj:isDead() or obj:hpRegen() == nil or obj:hpRegen() == 0 end)

--- 恢复魔法监听器
---@param obj Unit
Monitor("mp_regen")
    :frequency(0.3)
    :actionFunc(
    function(obj)
        local regen = 0.3 * obj:mpRegen()
        local cure = (obj:prop("cure") or 0) * 0.01
        local v = 0
        if (regen >= 0) then
            v = math.max(0, 1 + cure) * regen
            obj:mpCur("+=" .. v)
        else
            v = math.min(0, cure - 1) * regen
            obj:mpCur("-=" .. v)
        end
    end)
    :ignoreFilter(function(obj) return obj:isDead() or obj:mpRegen() == nil or obj:mpRegen() == 0 end)
```
