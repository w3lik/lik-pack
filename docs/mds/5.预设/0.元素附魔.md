### 预设附魔

> 用于定义附魔种类、反应的设置

```lua
--- 方便伤害类型引用
---@alias noteDamageTypeData {value:string,label:string}

---@type noteDamageTypeData
DAMAGE_TYPE.fire = nil
---@type noteDamageTypeData
DAMAGE_TYPE.rock = nil
---@type noteDamageTypeData
DAMAGE_TYPE.water = nil
---@type noteDamageTypeData
DAMAGE_TYPE.ice = nil
---@type noteDamageTypeData
DAMAGE_TYPE.wind = nil
---@type noteDamageTypeData
DAMAGE_TYPE.light = nil
---@type noteDamageTypeData
DAMAGE_TYPE.dark = nil
---@type noteDamageTypeData
DAMAGE_TYPE.grass = nil
---@type noteDamageTypeData
DAMAGE_TYPE.thunder = nil
---@type noteDamageTypeData
DAMAGE_TYPE.poison = nil
---@type noteDamageTypeData
DAMAGE_TYPE.steel = nil

-- 附魔设定
Enchant("fire"):name("火"):attachEffect("origin", "BreathOfFireDamage")
Enchant("rock"):name("岩")
Enchant("water"):name("水")
Enchant("ice"):name("冰")
Enchant("wind"):name("风")
Enchant("light"):name("光")
Enchant("dark"):name("暗")
Enchant("grass"):name("草")
Enchant("thunder"):name("雷")
Enchant("poison"):name("毒")
Enchant("steel"):name("钢")
```
