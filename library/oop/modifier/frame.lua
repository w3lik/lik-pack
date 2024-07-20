local expander = ClassExpander(CLASS_EXPANDS_MOD, FrameClass)

---@param obj Frame
expander["size"] = function(obj)
    ---@type number[]
    local data = obj:propData("size")
    japi.DZ_FrameSetSize(obj:handle(), data[1], data[2])
end

---@param obj Frame
expander["relation"] = function(obj)
    ---@type number[]
    local data = obj:propData("relation")
    japi.DZ_FrameClearAllPoints(obj:handle())
    japi.DZ_FrameSetPoint(obj:handle(), data[1], data[2]:handle(), data[3], data[4], data[5])
end

---@param obj Frame
expander["show"] = function(obj)
    ---@type boolean
    local data = obj:propData("show")
    japi.DZ_FrameShow(obj:handle(), data)
    if (data == true) then
        event.asyncTrigger(obj, EVENT.Frame.Show)
    else
        event.asyncTrigger(obj, EVENT.Frame.Hide)
    end
    if (obj:esc() == true) then
        view.esc(obj, data)
    end
    local f2m
    f2m = function(o)
        local evtList = event.get(event._async, o)
        if (type(evtList) == "table") then
            ---@param v Array
            for evt, v in pairx(evtList) do
                v:backEach(function(key, callFunc)
                    view.frame2Mouse(o, evt, data, key, callFunc)
                end)
            end
        end
        local child = o:children()
        if (type(child) == "table") then
            for _, c in pairx(child) do
                f2m(c)
            end
        end
    end
    f2m(obj)
end

---@param obj Frame
expander["adaptive"] = function(obj)
    ---@type boolean
    local data = obj:propData("adaptive")
    if (true == data) then
        local rel = obj:relation()
        if (type(rel) == "table") then
            obj:relation(table.unpack(rel))
        end
        local s = obj:size()
        if (type(s) == "table") then
            obj:size(table.unpack(s))
        end
        local child = obj:children()
        if (type(child) == "table") then
            for _, c in pairx(child) do
                c:adaptive(true)
            end
        end
        japi.FrameSetAdaptive(obj:id(), obj)
    else
        japi.FrameSetAdaptive(obj:id(), nil)
    end
end