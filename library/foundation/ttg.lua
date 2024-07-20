---@class ttg
ttg = ttg or {}

ttg._max = 50
ttg._count = ttg._count or 0
ttg._char = ttg._char or {}
ttg._site = ttg._site or {}

--- 注册字符对应的模型和位宽
---@param style string 样式组
---@param char string
---@param modelAlias string
---@param bit number
function ttg.char(style, char, modelAlias, bit)
    if (ttg._char[style] == nil) then
        ttg._char[style] = {}
    end
    ttg._char[style][tostring(char)] = { modelAlias, bit }
end

--- 字串漂浮字
---@see style string 漂浮字样式组
---@see str number 漂浮字信息
---@see width number 字间
---@see speed number 速度
---@see size number 尺寸
---@see scale {number,number} 缩放变化
---@see x number 创建坐标X
---@see y number 创建坐标Y
---@see z number 创建坐标Z
---@see height number 上升高度
---@see duration number 持续时间
---@param options {style:string,str:number,width:number,speed:number,size:number,scale:{number,number},x:number,y:number,z:number,height:number,duration:number}
function ttg.word(options)
    if (ttg._count > ttg._max) then
        return
    end
    local style = options.style or "default"
    must(ttg._char[style] ~= nil)
    local str = tostring(options.str) or ""
    local width = options.width or 10
    local speed = options.speed or 1
    local size = options.size or 0.25
    local scale = options.scale or { 1, 1 }
    local x = options.x or 0
    local y = options.y or 0
    local z = options.z or 150
    local height = options.height or 200
    local duration = options.duration or 0.5
    local frequency = 0.05
    local spd = height / (duration / frequency)
    --
    local words = mbstring.split(str, 1)
    if (#words > 0) then
        x = math.floor(x)
        y = math.floor(y)
        local site = x .. y
        if (ttg._site[site] == nil) then
            ttg._site[site] = {}
        end
        if (ttg._site[site][str] == nil) then
            ttg._site[site][str] = true
            time.setTimeout(0.2, function()
                ttg._site[site][str] = nil
            end)
            ttg._count = ttg._count + 1
            local xs = {}
            local x0 = x
            for i, w in ipairs(words) do
                must(ttg._char[style][w] ~= nil)
                local bit = ttg._char[style][w][2]
                xs[i] = x0
                x0 = xs[i] + width * bit
            end
            ---@type number[]
            local effs = {}
            for i, w in ipairs(words) do
                local mdl = ttg._char[style][w][1]
                effs[i] = effector(mdl, xs[i], y, z, duration)
                japi.YD_SetEffectSpeed(effs[i], speed)
                japi.YD_EffectMatScale(effs[i], size, size, size)
            end
            local d = 0
            local h = z
            local ani = 0
            time.setInterval(frequency, function(curTimer)
                d = d + frequency
                if (d >= duration) then
                    destroy(curTimer)
                    ttg._count = ttg._count - 1
                    return
                end
                h = h + spd
                local siz
                if (scale[1] ~= 1 or scale[2] ~= 1) then
                    ani = ani + frequency
                    if (ani >= 0.1) then
                        ani = 0
                        if (d < duration * 0.5) then
                            siz = scale[1]
                            width = width * siz
                        else
                            siz = scale[2]
                            width = width * siz
                        end
                    end
                end
                for i, _ in ipairs(words) do
                    japi.YD_SetEffectXY(effs[i], xs[i], y)
                    japi.YD_SetEffectZ(effs[i], h)
                    if (siz ~= nil) then
                        japi.YD_EffectMatScale(effs[i], siz, siz, siz)
                    end
                end
            end)
        end
    end
end

-- 模型漂浮字
---@see model string 模型路径
---@see speed number 速度
---@see size number 尺寸
---@see scale number 缩放
---@see x number 创建坐标X
---@see y number 创建坐标Y
---@see z number 创建坐标Z
---@see offset number 偏移
---@see height number 上升高度
---@see duration number 持续时间
---@param options {model:string,speed:number,size:number,scale:number,x:number,y:number,z:number,offset:number,height:number,duration:number}
function ttg.model(options)
    local model = assets.model(options.model)
    if (model == nil) then
        return
    end
    if (ttg._count > ttg._max) then
        return
    end
    local size = options.size or 0.25
    local scale = options.scale or { 1, 1 }
    local x = options.x or 0
    local y = options.y or 0
    local z = options.z or 150
    local offset = math.floor(options.offset or 0)
    local height = options.height or 1000
    local speed = options.speed or 1
    local duration = options.duration or 1
    local frequency = 0.05
    x = math.floor(x)
    y = math.floor(y)
    local site = x .. y
    if (ttg._site[site] == nil) then
        ttg._site[site] = {}
    end
    if (ttg._site[site][model] == nil) then
        ttg._site[site][model] = true
        time.setTimeout(duration, function()
            ttg._site[site][model] = nil
        end)
        ttg._count = ttg._count + 1
        local spd = height / (duration / frequency)
        local eff = effector(model, x, y, z, duration)
        japi.YD_SetEffectSpeed(eff, speed)
        japi.YD_EffectMatScale(eff, size, size, size)
        local dur = 0
        local h = z
        local randX = 0
        local randY = 0
        if (offset ~= 0) then
            randX = math.rand(-offset, offset)
            randY = math.rand(-offset, offset)
        end
        local ani = 0
        time.setInterval(frequency, function(curTimer)
            dur = dur + frequency
            if (dur >= duration) then
                destroy(curTimer)
                ttg._count = ttg._count - 1
                return
            end
            h = h + spd
            local siz
            if (scale[1] ~= 1 or scale[2] ~= 1) then
                ani = ani + frequency
                if (ani >= 0.1) then
                    ani = 0
                    if (dur < duration * 0.5) then
                        siz = scale[1]
                    else
                        siz = scale[2]
                    end
                end
            end
            x = x + randX
            y = y + randY
            japi.YD_SetEffectXY(eff, x, y)
            japi.YD_SetEffectZ(eff, h)
            if (siz ~= nil) then
                japi.YD_EffectMatScale(eff, siz, siz, siz)
            end
        end)
    end
end