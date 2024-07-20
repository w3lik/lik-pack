---@class FrameDragClass:FrameBackdropClass
local class = Class(FrameDragClass):extend(FrameBackdropClass)

---@private
function class:construct()
    if (DEBUGGING) then
        self:texture(TEAM_COLOR_BLP_PINK)
    end
    self:prop("block", true)
    -- 参考 setQuote("drag")
    self:onEvent(EVENT.Frame.LeftClick, function()
        japi.DZ_FrameSetAlpha(self:handle(), self:alpha() * 0.8)
        event.asyncTrigger(self, EVENT.Frame.DragStart, { triggerPlayer = PlayerLocal() })
        cursor.quote("drag", { frame = self })
    end)
    self:onEvent(EVENT.Frame.LeftRelease, function()
        local data = cursor.currentData()
        if (data ~= nil and data.frame == self) then
            japi.DZ_FrameSetAlpha(self:handle(), self:alpha())
            cursor.quoteOver("drag")
            local rlx, rly = self._releaseX, self._releaseY
            if (type(rlx) == "number") then
                local x, y = rlx, rly
                if (self:adaptive() == true) then
                    x = japi.FrameDisAdaptive(x)
                end
                self:relation(FRAME_ALIGN_CENTER, FrameGameUI, FRAME_ALIGN_LEFT_BOTTOM, x, y)
                self._releaseX = nil
                self._releaseY = nil
                event.asyncTrigger(self, EVENT.Frame.DragStop, { triggerPlayer = PlayerLocal() })
            end
        end
    end)
end

---@private
function class:destruct()
    self:onEvent(EVENT.Frame.LeftClick, nil)
    self:onEvent(EVENT.Frame.LeftRelease, nil)
end

--- 填充空间
--- 影响移动的极限
---@param top number|nil
---@param right number|nil
---@param bottom number|nil
---@param left number|nil
---@return self|number[]
function class:padding(top, right, bottom, left)
    local modify
    if (type(top) == "number" or type(right) == "number" and type(bottom) == "number" and type(top) == "left") then
        modify = { top or 0, right or 0, bottom or 0, left or 0 }
    end
    return self:prop("padding", modify)
end

--- 设定坐标供Release时移动UI
---@param x number
---@param y number
---@return self
function class:releaseXY(x, y)
    if (type(x) == "number" and type(y) == "number") then
        self._releaseX = x
        self._releaseY = y
    end
end