---@class FrameTooltipsClass:FrameCustomClass
local class = Class(FrameTooltipsClass):extend(FrameCustomClass)

---@private
function class:construct()
    self:adaptive(true)
        :relation(FRAME_ALIGN_CENTER, self:parent(), FRAME_ALIGN_CENTER, 0, 0)
        :size(0.1, 0.1)
        :show(false)
    
    local ic = {}
    for i = 1, 4 do
        local tmp = {}
        tmp.bg = FrameBackdrop(self:frameIndex() .. "->icon1->bg->" .. i, self)
            :size(0.013, 0.013)
            :show(false)
        tmp.txt = FrameText(self:frameIndex() .. "->icon1->txt->" .. i, tmp.bg)
            :relation(FRAME_ALIGN_LEFT, tmp.bg, FRAME_ALIGN_RIGHT, 0.004, 0)
            :textAlign(TEXT_ALIGN_LEFT)
        table.insert(ic, tmp)
    end
    self:prop("childIcons", ic)
    
    local brs = {}
    for i = 1, 2 do
        local b = FrameBar(self:frameIndex() .. "->bar->" .. i, self)
        b:textLayout({ LAYOUT_ALIGN_LEFT_TOP })
        b:show(false)
        table.insert(brs, b)
    end
    self:prop("childBars", brs)
    
    FrameText(self:frameIndex() .. "->cText", self)
        :relation(FRAME_ALIGN_CENTER, self, FRAME_ALIGN_CENTER, 0, 0)
        :textAlign(TEXT_ALIGN_LEFT)
        :fontSize(10)
    
    ---@param evtData noteOnFrameShowData
    self:onEvent(EVENT.Frame.Show, "clear_", function(evtData)
        evtData.triggerFrame:onEvent(EVENT.Frame.LeftClick, "clear2_", function(evtData2)
            evtData2.triggerFrame:onEvent(EVENT.Frame.LeftClick, "clear2_", nil)
            evtData2.triggerFrame:show(false)
        end)
    end)
    
    Group():insert(self)
end

---@private
function class:destruct()
    Group():remove(self)
end

--- frame kit
---@param modify string|nil
---@return self|string
function class:kit(modify)
    return self:prop("kit", modify)
end

--- 子文本对象
---@protected
---@return FrameText
function class:childText()
    return FrameText(self:frameIndex() .. "->cText")
end

--- 子图标对象1
---@protected
---@return table<number,{bg:FrameBackdrop,txt:FrameText}>
function class:childIcons()
    return self:prop("childIcons")
end

--- 子条状物对象
---@protected
---@return FrameBar[]
function class:childBars()
    return self:prop("childBars")
end

--- 文本排列
---@param align string
---@return self
function class:textAlign(align)
    self:childText():textAlign(align)
    return self
end

--- 文本字号[6-16]
---@param fontSize number
---@return self
function class:fontSize(fontSize)
    self:childText():fontSize(fontSize)
    return self
end

---- 内容设置
--[[
    -- 数据格式
    data:{
        icons:{
            { texture, text },-- 图标带文本的东东格式，默认最多4个
        }
        bars:{
            { texture, text, ratio, width, height }, -- 条状物格式，默认最多2个
        }
        tips:{
            "string",
        }
    },
]]
---@alias noteFrameTooltipContentIcons { texture:string, text:string }
---@alias noteFrameTooltipContentBars { texture:string, text:string,ratio:number,width:number,height:number }
---@param data {icons:noteFrameTooltipContentIcons[],bars:noteFrameTooltipContentBars[],tips:string|string[]}
---@return self
function class:content(data)
    if (type(data) == "string") then
        data = { tips = data }
    end
    local bars = data.bars
    local tips = data.tips
    local childText = self:childText()
    local fs = childText:fontSize()
    if (type(tips) == "string") then
        tips = string.explode("|n", tips)
    end
    local kit = self:kit()
    local icons = data.icons
    -- 处理文本对齐方向
    if ((type(icons) == "table" and #icons > 0)) then
        -- 当有顶部图标时，自动调节为左对齐
        japi.DZ_FrameSetTextAlignment(childText:handle(), TEXT_ALIGN_LEFT)
    elseif (type(tips) == "table" and #tips == 1) then
        -- 当只有一行文本时，自动调节为居中
        japi.DZ_FrameSetTextAlignment(childText:handle(), TEXT_ALIGN_CENTER)
    else
        -- 无图标且多行文本时，以代码设定为准
        local ag = childText:textAlign()
        japi.DZ_FrameSetTextAlignment(childText:handle(), ag)
    end
    
    -- 处理内容及计算宽高
    local padW = 0.012
    local padH = 0.008
    local tw = 0
    local th = 0
    local hasIcons = false
    local hasTips = false
    
    ---@type table<number,{bg:FrameBackdrop,txt:FrameText}>
    local childIcons = self:childIcons()
    local cw = 0
    for i = 1, #childIcons, 1 do
        if (type(icons) ~= "table" or icons[i] == nil) then
            childIcons[i].bg:show(false)
        else
            if (i == 1) then
                hasIcons = true
                childIcons[i].bg:relation(FRAME_ALIGN_LEFT_TOP, self, FRAME_ALIGN_LEFT_TOP, padW, -padH)
            else
                childIcons[i].bg:relation(FRAME_ALIGN_LEFT, childIcons[i - 1].txt, FRAME_ALIGN_RIGHT, 0.01, 0)
                cw = cw + 0.01
            end
            childIcons[i].txt:text(icons[i].text):fontSize(fs - 1)
            childIcons[i].bg:texture(assets.uikit(kit, icons[i].texture, "tga"))
            childIcons[i].bg:show(true)
            cw = cw + 0.013 + vistring.width(icons[i].text, fs)
        end
    end
    tw = math.max(tw, cw)
    if (hasIcons) then
        th = th + 0.013
    end
    ---@type FrameBar[]
    local childBars = self:childBars()
    local lastBarIdx = 0
    for i = 1, #childBars, 1 do
        if (type(bars) ~= "table" or bars[i] == nil) then
            childBars[i]:show(false)
        else
            lastBarIdx = i
            local bh = vistring.height(1, fs - 2)
            if (i == 1) then
                tw = math.max(tw, bars[i].width)
                if (hasIcons) then
                    childBars[i]:relation(FRAME_ALIGN_LEFT_TOP, childIcons[1].bg, FRAME_ALIGN_LEFT_BOTTOM, 0, -bh - padH / 2)
                    th = th + padH / 2
                else
                    childBars[i]:relation(FRAME_ALIGN_LEFT_TOP, self, FRAME_ALIGN_LEFT_TOP, padW, -bh - padH)
                end
            else
                childBars[i]:relation(FRAME_ALIGN_LEFT_TOP, childBars[i - 1], FRAME_ALIGN_LEFT_BOTTOM, 0, -bh - padH / 4)
                th = th + padH / 4
            end
            childBars[i]:text(LAYOUT_ALIGN_LEFT_TOP, bars[i].text)
            childBars[i]:fontSize(LAYOUT_ALIGN_LEFT_TOP, fs - 2)
            childBars[i]:texture("value", assets.uikit(kit, bars[i].texture, "tga"))
            childBars[i]:value(bars[i].ratio, bars[i].width, bars[i].height)
            childBars[i]:show(true)
            th = th + bars[i].height + bh
        end
    end
    
    if (type(tips) == "table" and #tips > 0) then
        hasTips = true
        if (lastBarIdx > 0) then
            childText:relation(FRAME_ALIGN_LEFT_TOP, childBars[lastBarIdx], FRAME_ALIGN_LEFT_BOTTOM, 0, -padH / 3)
            th = th + padH / 3
        elseif (hasIcons) then
            childText:relation(FRAME_ALIGN_LEFT_TOP, childIcons[1].bg, FRAME_ALIGN_LEFT_BOTTOM, 0, -padH / 3)
            th = th + padH / 3
        else
            childText:relation(FRAME_ALIGN_LEFT_TOP, self, FRAME_ALIGN_LEFT_TOP, padW, -padH)
        end
        local txw = 0
        local txts = {}
        local ns = 0
        for _, s in ipairs(tips) do
            s = i18n.tr(s)
            txw = math.max(txw, vistring.width(s .. ' ', fs))
            txts[#txts + 1] = s
            ns = ns + string.subCount(s, "|n")
        end
        local txh = vistring.height(#txts + ns, fs)
        childText:size(txw, txh):text(table.concat(txts, "|n"))
        tw = math.max(tw, txw)
        th = th + txh
    end
    --
    tw = tw + padW * 2
    th = th + padH * 2
    self:size(tw, th)
    return self
end