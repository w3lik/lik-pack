local expander = ClassExpander(CLASS_EXPANDS_MOD, QuestClass)

---@param obj Quest
expander["title"] = function(obj)
    J.QuestSetTitle(obj:handle(), obj:propData("title"))
end

---@param obj Quest
expander["icon"] = function(obj)
    J.QuestSetIconPath(obj:handle(), assets.icon(obj:propData("icon")))
end

---@param obj Quest
expander["side"] = function(obj)
    local data = obj:propData("side")
    local questType
    if (data == "left") then
        questType = BJ_QUESTTYPE_REQ_DISCOVERED
    elseif (data == "right") then
        questType = BJ_QUESTTYPE_OPT_DISCOVERED
    end
    if (questType ~= nil) then
        local required = questType == BJ_QUESTTYPE_REQ_DISCOVERED or questType == BJ_QUESTTYPE_REQ_UNDISCOVERED
        local discovered = questType == BJ_QUESTTYPE_REQ_DISCOVERED or questType == BJ_QUESTTYPE_OPT_DISCOVERED
        J.QuestSetRequired(obj:handle(), required)
        J.QuestSetDiscovered(obj:handle(), discovered)
    end
end

---@param obj Quest
expander["content"] = function(obj)
    J.QuestSetDescription(obj:handle(), obj:propData("content"))
end

---@param obj Quest
expander["complete"] = function(obj)
    J.QuestSetCompleted(obj:handle(), obj:propData("complete"))
end

---@param obj Quest
expander["fail"] = function(obj)
    J.QuestSetFailed(obj:handle(), obj:propData("fail"))
end

---@param obj Quest
expander["discover"] = function(obj)
    J.QuestSetDiscovered(obj:handle(), obj:propData("discover"))
end