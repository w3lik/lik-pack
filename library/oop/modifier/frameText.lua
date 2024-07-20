local expander = ClassExpander(CLASS_EXPANDS_MOD, FrameTextClass)

---@param obj FrameText
expander["textAlign"] = function(obj)
    japi.DZ_FrameSetTextAlignment(obj:handle(), obj:propData("textAlign"))
end

---@param obj FrameText
expander["textColor"] = function(obj)
    japi.FrameSetTextColor(obj:handle(), obj:propData("textColor"))
end

---@param obj FrameText
expander["textSizeLimit"] = function(obj)
    local tsl = obj:propData("textSizeLimit")
    if (tsl > 0) then
        local txt = obj:propData("text")
        if (type(txt) == "string") then
            txt = mbstring.sub(txt, 1, tsl)
            japi.DZ_FrameSetText(obj:handle(), txt)
        end
    end
end

---@param obj FrameText
expander["fontSize"] = function(obj)
    japi.DZ_FrameSetFont(obj:handle(), 'fonts.ttf', obj:propData("fontSize") * 0.001, 0)
end

---@param obj FrameText
expander["text"] = function(obj)
    local txt = obj:propData("text")
    local tsl = obj:propData("textSizeLimit")
    if (tsl > 0) then
        txt = mbstring.sub(txt, 1, tsl)
    end
    japi.DZ_FrameSetText(obj:handle(), txt)
end