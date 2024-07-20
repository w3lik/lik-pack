### 原生UI构成

```lua
-- 可选隐藏初始化原生UI
Game():hideInterface(true)
```

### 单位等级极限、技能经验计算

```lua
-- 技能升级极限以及经验计算参数 max fixed ratio limit
Game():unitExp(100, 100, 1.20, 1000000)
```

### 技能栏热键、等级极限、技能经验计算

```lua
-- 配置游戏 - 技能栏热键
-- A S H 被默认命令占用建议不使用
Game():abilityHotkey({ KEYBOARD.Q, KEYBOARD.W, KEYBOARD.E, KEYBOARD.R, KEYBOARD.D, KEYBOARD.F, KEYBOARD.C, KEYBOARD.V })

Game():abilityUpgrade(99, 100, 1.00, 10000)
```

### 物品栏热键、等级极限、技能经验计算

```lua
-- 配置游戏 - 物品栏热键
-- 这里使用魔兽的 78 45 12
Game():itemHotkey({ KEYBOARD.Numpad7, KEYBOARD.Numpad8, KEYBOARD.Numpad4, KEYBOARD.Numpad5, KEYBOARD.Numpad1, KEYBOARD.Numpad2 })

-- 技能升级极限以及经验计算参数 max fixed ratio limit
Game():itemExp(99, 100, 1.00, 10000)
```

### 物品拾取模式

```lua
Game():itemPickMode(ITEM_PICK_MODE.itemOnly)
```

### 玩家仓库上限

```lua
-- 配置游戏 - 玩家仓库
Game():warehouseSlot(18)
```
