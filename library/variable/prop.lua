-- CLASS
CLASS_EXPANDS_PRE = "preposition"
CLASS_EXPANDS_LMT = "limiter"
CLASS_EXPANDS_MOD = "modifier"
CLASS_EXPANDS_NOR = "normalizer"
CLASS_EXPANDS_SUP = "superposition"

-- 玩家状态
PLAYER_STATUS = {
    empty = { value = "empty", label = "空置" },
    playing = { value = "playing", label = "在线" },
    leave = { value = "leave", label = "离线" },
}

-- 技能目标类型
ABILITY_TARGET_TYPE = {
    pas = { value = "PAS", label = "被动" },
    tag_nil = { value = "TAG_E", label = "无目标" },
    tag_unit = { value = "TAG_U", label = "单位目标" },
    tag_loc = { value = "TAG_L", label = "点目标" },
    tag_circle = { value = "TAG_C", label = "圆形范围目标" },
    tag_square = { value = "TAG_S", label = "方形范围目标" },
}

--- 闪电效果
LIGHTNING_TYPE = {
    thunder = { value = "CLPB", label = "闪电链主", effect = "BoltImpact" },
    thunderLite = { value = "CLSB", label = "闪电链次", effect = "BoltImpact" },
    thunderShot = { value = "CHIM", label = "闪电攻击", effect = "BoltImpact" },
    thunderFork = { value = "FORK", label = "叉状闪电", effect = "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl" },
    thunderRed = { value = "AFOD", label = "死亡之指", effect = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl" },
    suck = { value = "DRAB", label = "汲取", effect = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl" },
    suckGreen = { value = "DRAL", label = "生命汲取", effect = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl" },
    suckBlue = { value = "DRAM", label = "魔法汲取", effect = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl" },
    cure = { value = "HWPB", label = "医疗波主", effect = "Abilities\\Spells\\Orc\\HealingWave\\HealingWaveTarget.mdl" },
    cureLite = { value = "HWSB", label = "医疗波次", effect = "Abilities\\Spells\\Orc\\HealingWave\\HealingWaveTarget.mdl" },
    soul = { value = "SPLK", label = "灵魂锁链", effect = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl" },
    manaBurn = { value = "MBUR", label = "法力燃烧", effect = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareBoltImpact.mdl" },
    manaFrame = { value = "MFPB", label = "魔力之焰", effect = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareBoltImpact.mdl" },
    manaChain = { value = "LEAS", label = "魔法镣铐", effect = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl" },
}

-- ODDS
ATTR_ODDS = { 'hurtRebound', 'crit', 'stun' }

-- RESISTANCE
ATTR_RESISTANCE = {
    'hpSuckAttack', 'hpSuckAbility',
    'mpSuckAttack', 'mpSuckAbility',
    'hurtRebound', 'crit', 'stun',
    'split', 'silent', 'unArm', 'lightningChain', 'crackFly'
}

--- buff标识
BUFF_SIGNAL = {
    up = "up", -- 提升;增益
    down = "down", -- 下降;负面
}

--- 单位材质
UNIT_MATERIAL = {
    flesh = { value = "flesh", label = "肉体" },
    metal = { value = "metal", label = "金属" },
    rock = { value = "rock", label = "石头" },
    wood = { value = "wood", label = "木头" },
}

--- 单位移动类型
UNIT_MOVE_TYPE = {
    foot = { value = MOVE_NAME_FOOT, label = "步行" },
    fly = { value = MOVE_NAME_FLY, label = "飞行" },
    float = { value = MOVE_NAME_FLOAT, label = "漂浮" },
    amphibious = { value = MOVE_NAME_AMPH, label = "两栖" },
}

--- 单位核心
UNIT_PRIMARY = {
    str = { value = "str", label = "力量" },
    agi = { value = "agi", label = "敏捷" },
    int = { value = "int", label = "智力" },
}

-- 物品拾取模式
ITEM_PICK_MODE = {
    itemWarehouse = { value = "itemWarehouse", label = "优先物品栏，满则转移至仓库" },
    itemOnly = { value = "itemOnly", label = "只拾取到物品栏" },
    warehouseOnly = { value = "warehouseOnly", label = "只拾取到仓库" },
}

--- 伤害来源
DAMAGE_SRC = {
    common = { value = "common", label = "常规" },
    attack = { value = "attack", label = "攻击" },
    ability = { value = "ability", label = "技能" },
    item = { value = "item", label = "物品" },
    rebound = { value = "rebound", label = "反伤" },
    reaction = { value = "reaction", label = "附魔反应" },
}

--- 伤害类型
DAMAGE_TYPE = {
    common = { value = "common", label = "常规" },
}
DAMAGE_TYPE_KEYS = { "common" }

--- 无视防御种类
BREAK_ARMOR = {
    defend = { value = "defend", label = "防御" },
    avoid = { value = "avoid", label = "回避" },
    invincible = { value = "invincible", label = "无敌" },
}