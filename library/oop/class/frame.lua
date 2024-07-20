---@class FrameClass:Class
local class = Class(FrameClass)

---@private
---@param options {frameId:number,parent:Frame,fdfType:string,fdfName:string}
function class:construct(options)
    if (options.frameId == nil) then
        options.tag = japi.FrameTagIndex()
        options.parent = options.parent or FrameGameUI
        options.frameId = japi.DZ_CreateFrameByTagName(options.fdfType, options.tag, options.parent:handle(), options.fdfName, 0)
        self:prop("tag", options.tag)
        self:prop("fdfName", options.fdfName)
        self:prop("fdfType", options.fdfType)
    end
    must(type(options.frameId) == "number" and options.frameId > 0)
    self._frameId = options.frameId
    self:prop("frameIndex", options.frameIndex)
    self:prop("parent", options.parent)
    self:prop("children", {})
    self:prop("show", true)
    self:prop("esc", false)
    local kits = string.explode("->", options.frameIndex)
    self:prop("kit", tostring(kits[1]))
    local id = self:id()
    if (view.isGameUI(self)) then
        self:prop("adaptive", false)
        self:prop("size", { 0.8, 0.6 })
        self:prop("anchor", { 0.4, 0.3, 0.8, 0.6 })
    end
    local parent = self:parent()
    if (parent ~= nil) then
        local child = parent:children()
        if (nil == child[id]) then
            child[id] = self
            self:prop("adaptive", parent:adaptive())
        end
    end
end

---@private
function class:destruct()
    japi.FrameSetAdaptive(self:id(), nil)
    -- 清理事件
    local evtList = event.get(event._async, self)
    if (type(evtList) == "table") then
        ---@param v Array
        for evt, v in pairx(evtList) do
            v:backEach(function(key)
                view.frame2Mouse(self, evt, false, key, nil)
            end)
        end
    end
    self:clear("lowerNodes", true)
    local child = self:children()
    if (type(child) == "table") then
        for k, c in pairx(child) do
            child[k] = nil
            destroy(c)
        end
        child = nil
        self:clear("children")
    end
    local parent = self:parent()
    if (parent ~= nil) then
        local pChild = parent:children()
        if (type(pChild) == "table") then
            pChild[self:id()] = nil
        end
        self:clear("parent")
    end
    self:clear("gradientTimer", true)
    japi.DZ_DestroyFrame(self._frameId)
end

--- handle
---@return number
function class:handle()
    return self._frameId
end

--- frame index
--- cache key
---@return any
function class:frameIndex()
    return self:prop("frameIndex")
end

--- frame kit
---@return string
function class:kit()
    return self:prop("kit")
end

--- 自适应
---@param modify boolean|nil
---@return self|boolean
function class:adaptive(modify)
    if (type(modify) == "boolean") then
        self:prop("adaptive", modify)
        return self
    end
    return self:prop("adaptive")
end

--- 锚
--- 记录从屏幕左下角为原点的[偏移XY，宽高]
---@alias noteAnchorData {x,y,width,height}
---@return noteAnchorData
function class:anchor()
    return self:prop("anchor")
end

--- 焦点
---@return boolean
function class:isFocus()
    return japi.DZ_GetMouseFocus() == self:handle()
end

--- 屏幕相对坐标是否在Frame内
---@param rx number 默认鼠标RX
---@param ry number 默认鼠标RY
---@param checkShow boolean 是否检查可见性
---@return boolean
function class:isInner(rx, ry, checkShow)
    if (cursor.isDragging()) then
        return false
    end
    if (type(checkShow) ~= "boolean") then
        checkShow = true
    end
    if (checkShow == true and self:show() == false) then
        return false
    end
    local anchor = self:anchor()
    if (anchor == nil) then
        return false
    end
    rx = rx or japi.MouseRX()
    ry = ry or japi.MouseRY()
    local ax = anchor[1]
    local ay = anchor[2]
    local w = anchor[3]
    local h = anchor[4]
    local xMin = ax - w / 2
    local xMax = ax + w / 2
    local yMin = ay - h / 2
    local yMax = ay + h / 2
    return rx < xMax and rx > xMin and ry < yMax and ry > yMin
end

--- 屏幕相对坐标是否在Frame外
---@param rx number 默认鼠标RX
---@param ry number 默认鼠标RY
---@return boolean
function class:isBorder(rx, ry)
    if (self:show() == false) then
        return false
    end
    local anchor = self:anchor()
    if (anchor == nil) then
        return false
    end
    rx = rx or japi.MouseRX()
    ry = ry or japi.MouseRY()
    local ax = anchor[1]
    local ay = anchor[2]
    local w = anchor[3]
    local h = anchor[4]
    local xMin = ax - w / 2
    local xMax = ax + w / 2
    local yMin = ay - h / 2
    local yMax = ay + h / 2
    return rx > xMax or rx < xMin or ry > yMax or ry < yMin
end

--- 检查弹层区
--- 指针区可以限制某些功能
--- 自动根据FrameTooltips对象计算
---@param rx number|nil
---@param ry number|nil
---@return boolean
function class:checkTooltips(rx, ry)
    local is = true
    if (Group():count(FrameTooltipsClass) == 0) then
        return is
    end
    rx = rx or japi.MouseRX()
    ry = ry or japi.MouseRY()
    Group():forEach(FrameTooltipsClass, nil, function(enumObj)
        if (enumObj:isInner(rx, ry)) then
            is = false
            return false
        end
    end)
    if (is == false) then
        local f = self
        is = (f:className() == FrameTooltipsClass)
        while (is == false) do
            f = f:parent()
            if (f == nil or f == FrameGameUI) then
                break
            end
            is = (f:className() == FrameTooltipsClass)
        end
    end
    return is
end

--- 获取父节点
--- 手动设置japi父节点必须base on simple frame，意义低得可怜，故直接舍弃
---@return Frame|nil
function class:parent()
    return self:prop("parent")
end

--- 所有子节点
---@return table<string,Frame>
function class:children()
    return self:prop("children")
end

--- 上级关系节点
---@return Frame
function class:upperNode()
    local r = self:prop("relation")
    if (type(r) == "table") then
        return r[2]
    end
end

--- 所有下级关系节点
---@return Array Frame[]
function class:lowerNodes()
    return self:prop("lowerNodes")
end

--- 宽高尺寸(0-0.8,0-0.6)
--- 百分比占比设置
---@param w number
---@param h number
---@return self|number[2]
function class:size(w, h)
    if (w ~= nil and h ~= nil) then
        if (view.isGameUI(self)) then
            -- 游戏UI禁止
            return self
        end
        local aw = w
        if (true == self:adaptive()) then
            aw = japi.FrameAdaptive(w)
        end
        self:gradientStop()
        local _, updated = self:PROP("size", { aw, h })
        if (updated == true) then
            self:prop("unAdaptiveSize", { w, h })
            view.setAnchor(self)
        end
        return self
    end
    return self:prop("size")
end

--- 相对锚点
---@param point number integer 参考 blizzard:^FRAME_ALIGN_*
---@param relativeFrame Frame 相对节点ID(def:FrameGameUI)
---@param relativePoint number 以 align-> alignParent 对齐
---@param x number 锚点X
---@param y number 锚点Y
---@return self|table
function class:relation(point, relativeFrame, relativePoint, x, y)
    if (point ~= nil and relativeFrame ~= nil and relativePoint ~= nil and x ~= nil and y ~= nil) then
        must(relativeFrame ~= self)
        if (view.isGameUI(self)) then
            -- 游戏UI禁止
            return self
        end
        local ax = x
        if (true == self:adaptive()) then
            ax = japi.FrameAdaptive(x)
        end
        self:gradientStop()
        local upper = self:upperNode()
        local _, updated = self:PROP("relation", { point, relativeFrame, relativePoint, ax, y })
        if (updated == true) then
            if (upper ~= relativeFrame) then
                if (instanceof(upper, FrameClass) and view.isGameUI(upper) == false) then
                    local lns = upper:lowerNodes()
                    if (isClass(lns, ArrayClass)) then
                        lns:set(self:id(), nil)
                    end
                end
                if (view.isGameUI(relativeFrame) == false) then
                    local lns = relativeFrame:lowerNodes()
                    if (lns == nil) then
                        lns = Array()
                        relativeFrame:prop("lowerNodes", lns)
                    end
                    if (false == lns:keyExists(self:id())) then
                        lns:set(self:id(), self)
                    end
                end
            end
            self:prop("unAdaptiveRelation", { point, relativeFrame, relativePoint, x, y })
            view.setAnchor(self)
        end
        return self
    end
    return self:prop("relation")
end

--- 绝对锚点
---@param point number
---@param x number
---@param y number
---@return self|table
function class:absolut(point, x, y)
    return self:relation(point, FrameGameUI, point, x, y)
end

--- 显示
---@param modify boolean|nil
---@param delay number|nil 延时
---@return self|boolean
function class:show(modify, delay)
    if (view.isGameUI(self)) then
        -- 游戏UI禁止
        return self
    end
    if (type(modify) == "boolean") then
        if (modify == true and Game():regulateUI(self) == true) then
            -- 无效UI禁止
            return self
        end
        local showDelay = self:prop("showDelay")
        if (isClass(showDelay, TimerClass)) then
            self:prop("showDelay", true)
            showDelay = nil
        end
        delay = delay or 0
        if (delay >= 0.1 and async.is()) then
            --- FrameTooltips延时时添加一个显隐策略
            if (isClass(self, FrameTooltipsClass)) then
                self:onEvent(EVENT.Frame.Hide, "tactics_", function(evtData)
                    event.asyncUnregister(evtData.triggerFrame, EVENT.Frame.Hide, "tactics_")
                    event.asyncUnregister(evtData.triggerFrame, EVENT.Frame.Enter, "tactics_")
                    event.asyncUnregister(evtData.triggerFrame, EVENT.Frame.Leave, "tactics_")
                end)
                self:onEvent(EVENT.Frame.Enter, "tactics_", function(evtData)
                    event.asyncUnregister(evtData.triggerFrame, EVENT.Frame.Enter, "tactics_")
                    if (evtData.triggerFrame:show() == true) then
                        evtData.triggerFrame:show(true)
                    end
                end)
                self:onEvent(EVENT.Frame.Leave, "tactics_", function(evtData)
                    if (evtData.triggerFrame:show() == true) then
                        evtData.triggerFrame:show(false)
                    end
                end)
            end
            self:prop("showDelay", async.setTimeout(delay * 60, function()
                self:clear("showDelay")
                self:PROP("show", modify)
            end))
        else
            self:PROP("show", modify)
        end
        return self
    end
    local o = self
    local s = o:prop("show") or false
    while (s == true) do
        local p = o:parent()
        if (p == nil or p == FrameGameUI) then
            break
        end
        o = p
        s = o:prop("show")
        if (s == false) then
            break
        end
    end
    return s
end

--- 强制停止匀渐变
---@return void
function class:gradientStop()
    local t = self:prop("gradientTimer")
    if (isClass(t, TimerAsyncClass)) then
        self:clear("gradientTimer", true)
        t = nil
        japi.DZ_FrameClearAllPoints(self:handle())
        local oriRelation = self:relation()
        if (type(oriRelation) == "table") then
            japi.DZ_FrameSetPoint(self:handle(), oriRelation[1], oriRelation[2]:handle(), oriRelation[3], oriRelation[4], oriRelation[5])
        end
        local oriSize = self:size()
        if (type(oriSize) == "table") then
            japi.DZ_FrameSetSize(self:handle(), oriSize[1], oriSize[2])
        end
        japi.DZ_FrameSetAlpha(self:handle(), self:alpha())
        japi.DZ_FrameShow(self:handle(), self:show())
    end
end

--- 匀渐变
--- 使用渐变开始时会强制显示此Frame（不显示等于0效果，没有任何意义）
--- 过程中引起的变化都是临时修改不会改变Frame对象的具体数据
---@see duration number 渐变时间，最快0.1秒
---@see alpha number|1|-1 设1表示逐渐显示，设-1表示逐渐消失
---@see x number 坐标偏移量总量
---@see y number 坐标偏移量总量
---@see size number 尺寸偏移百分比，如30，最终尺寸必定是真实尺寸
---@alias noteFrameShowGradient {duration:number,alpha:number,x:number,y:number,size:number}
---@param options noteFrameShowGradient
---@param callback fun(callFrame:Frame):void 动画结束后回调，可处理隐藏等操作
---@return self
function class:gradient(options, callback)
    self:gradientStop()
    options.duration = math.max(0.1, options.duration or 0.1)
    local step = 10
    local oriAlpha = self:alpha()
    local oriRelation = self:relation()
    local oriSize = self:size()
    local dtX = (options.x or 0) / step
    local dtY = (options.y or 0) / step
    local dtA = 0
    local dtW = 0
    local dtH = 0
    if (type(oriRelation) ~= "table") then
        dtX = 0
        dtY = 0
    end
    local curAlpha
    if (type(options.alpha) == "number") then
        if (options.alpha == 1) then
            curAlpha = 0
            dtA = oriAlpha / step
        elseif (options.alpha == -1) then
            curAlpha = oriAlpha
            dtA = -oriAlpha / step
        end
        if (curAlpha ~= nil) then
            japi.DZ_FrameSetAlpha(self:handle(), curAlpha)
        end
    end
    if (type(options.size) == "number" and oriSize ~= nil) then
        options.size = math.max(options.size, 0)
        options.size = math.min(options.size, 100)
        if (options.size ~= 0) then
            dtW = oriSize[1] * options.size * 0.01 / step
            dtH = oriSize[2] * options.size * 0.01 / step
        end
    end
    if (dtX ~= 0 or dtY ~= 0) then
        japi.DZ_FrameClearAllPoints(self:handle())
        japi.DZ_FrameSetPoint(self:handle(), oriRelation[1], oriRelation[2]:handle(), oriRelation[3], oriRelation[4] + dtX * step, oriRelation[5] + dtY * step)
    end
    if (dtW ~= 0 and dtH ~= 0) then
        japi.DZ_FrameSetSize(self:handle(), oriSize[1] + dtW * step, oriSize[2] + dtH * step)
    end
    japi.DZ_FrameShow(self:handle(), true)
    local t = async.setInterval(options.duration / step * 60, function(curTimer)
        step = step - 1
        if (step <= 0) then
            if (type(callback) == "function") then
                callback(self)
            end
            self:gradientStop()
            return
        end
        if (curAlpha ~= nil) then
            curAlpha = curAlpha + dtA
            japi.DZ_FrameSetAlpha(self:handle(), curAlpha)
        end
        if (dtX ~= 0 or dtY ~= 0) then
            japi.DZ_FrameClearAllPoints(self:handle())
            japi.DZ_FrameSetPoint(self:handle(), oriRelation[1], oriRelation[2]:handle(), oriRelation[3], oriRelation[4] + dtX * step, oriRelation[5] + dtY * step)
        end
        if (dtW ~= 0 and dtH ~= 0) then
            japi.DZ_FrameSetSize(self:handle(), oriSize[1] + dtW * step, oriSize[2] + dtH * step)
        end
    end)
    self:prop("gradientTimer", t)
    return self
end

--- 本对象事件注册
---@param evt string 事件类型字符
---@vararg any 可以填写一个function|或string,function 当拥有string参数时作为其key
---@return self
function class:onEvent(evt, ...)
    event.asyncRegister(self, evt, ...)
    view.frame2Mouse(self, evt, self:show(), ...)
    return self
end

--- ESC隐藏功能绑定
---@param modify boolean|nil 开启|关闭
---@return self|boolean
function class:esc(modify)
    if (type(modify) == "boolean") then
        view.esc(self, false)
        return self:prop("esc", modify)
    end
    return self:prop("esc")
end

--- 关闭功能按钮绑定
---@param enable boolean
---@param side string|'left'|'right'
---@param size number
---@param texture string
---@return self
function class:close(enable, size, side, texture)
    ---@type FrameButton
    local c = self:prop("childClose")
    if (enable == true) then
        side = side or "right"
        size = size or 0.02
        texture = texture or "Framework\\ui\\close.tga"
        if (isClass(c, FrameButtonClass) == false) then
            c = FrameButton(self:frameIndex() .. '->childClose', self, "FRAMEWORK_HIGHLIGHT_HUMAN_QUEST")
            self:prop("childClose", c)
            c:onEvent(EVENT.Frame.Enter, function() c:childHighlight():show(true) end)
            c:onEvent(EVENT.Frame.Leave, function() c:childHighlight():show(false) end)
            c:onEvent(EVENT.Frame.LeftClick, function()
                self:show(false)
                audio(Vcm("war3_MouseClick2"))
            end)
        end
        if (side == "left") then
            c:relation(FRAME_ALIGN_LEFT_TOP, self, FRAME_ALIGN_LEFT_TOP, -size / 4, size / 4)
        else
            c:relation(FRAME_ALIGN_RIGHT_TOP, self, FRAME_ALIGN_RIGHT_TOP, size / 4, size / 4)
        end
        c:size(size, size):texture(texture):show(true)
    else
        if (isClass(c, FrameButtonClass)) then
            c:show(false)
        end
    end
    return self
end