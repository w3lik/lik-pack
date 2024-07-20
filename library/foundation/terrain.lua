---@class terrain 地形
terrain = terrain or {}

--- 设置水颜色
---@param red number 0-255
---@param green number 0-255
---@param blue number 0-255
---@param alpha number 0-255
---@return void
function terrain.setWaterColor(red, green, blue, alpha)
    J.SetWaterBaseColor(red, green, blue, alpha)
end

--- 获取x，y坐标的地形地表贴图类型
---@see file variable/terrain TERRAIN_*
---@param x number
---@param y number
---@return number
function terrain.getType(x, y)
    return J.GetTerrainType(x, y)
end

--- 设置x，y坐标的地形地表贴图类型
---@param x number
---@param y number
---@param typ number variable/TERRAIN_?
---@param radius number 默认128，改变的半径范围，实际会转为刷子大小，1刷子等于128
---@param shape number 默认0，0圆形|1方形
---@param style number 默认-1，随机样式
---@return void
function terrain.setType(x, y, typ, radius, shape, style)
    radius = radius or 128
    radius = math.floor(radius / 128)
    if (radius < 1) then
        return
    end
    J.SetTerrainType(x, y, typ, style or -1, radius, shape or 0)
end

--- 是否某类型
---@param x number
---@param y number
---@see file variable/terrain TERRAIN_*
---@param whichType number
---@return boolean
function terrain.isType(x, y, whichType)
    return whichType == terrain.getType(x, y)
end

--- 为玩家设置x，y坐标的荒芜地表
---@param whichPlayer Player
---@param enable boolean true添加，false消除
---@param x number
---@param y number
---@param radius number 小于1无效
---@return void
function terrain.setBlight(whichPlayer, enable, x, y, radius)
    must(isClass(whichPlayer, PlayerClass))
    must(type(enable) == "boolean")
    if (radius < 1) then
        return
    end
    J.SetBlight(whichPlayer:handle(), x, y, radius, enable)
end

--- 为玩家设置区域的荒芜地表
--- 会创建区域
---@param whichPlayer Player
---@param enable boolean true添加，false消除
---@param whichRegion Region
---@return void
function terrain.setBlightRegion(whichPlayer, enable, whichRegion)
    must(isClass(whichPlayer, PlayerClass))
    must(type(enable) == "boolean")
    must(isClass(whichRegion, RegionClass))
    J.SetBlightRect(whichPlayer:handle(), whichRegion:handle(), enable)
end

--- 是否荒芜地表
---@param x number
---@param y number
---@return boolean
function terrain.isBlighted(x, y)
    return J.IsPointBlighted(x, y)
end

--- 是否可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkable(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
end

--- 是否飞行可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkableFly(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_FLYABILITY)
end

--- 是否水(海)面可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkableWater(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
end

--- 是否两栖可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkableAmphibious(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_AMPHIBIOUSPATHING)
end

--- 是否荒芜可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkableBlight(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_BLIGHTPATHING)
end

--- 是否建造可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkableBuild(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY)
end

--- 是否采集时可通行
---@param x number
---@param y number
---@return boolean
function terrain.isWalkablePeonHarvest(x, y)
    return not J.IsTerrainPathable(x, y, PATHING_TYPE_PEONHARVESTPATHING)
end

--- 是否处在水面
---@param x number
---@param y number
---@return boolean
function terrain.isWater(x, y)
    return terrain.isWalkableWater(x, y)
end

--- 是否处于地面
--- 这里实际上判断的是非水区域
---@param x number
---@param y number
---@return boolean
function terrain.isGround(x, y)
    return not terrain.isWalkableWater(x, y)
end