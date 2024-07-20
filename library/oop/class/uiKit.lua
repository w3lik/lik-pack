---@class UIKitClass:Class
local class = Class(UIKitClass)

---@private
function class:construct(options)
    self:prop("kit", options.kit)
    self:prop("refreshing", false)
    self:prop("stage", {})
    self:prop("frequency", 1)
    Group():insert(self)
end

---@private
function class:destruct()
    Group():remove(self)
    self:prop("refreshing", false)
    local refreshTimer = self:prop("refreshTimer")
    if (isClass(refreshTimer, TimerClass)) then
        self:clear("refreshTimer", true)
    end
end

---@return string
function class:kit()
    return self:prop("kit")
end

---@return table
function class:stage()
    return self:prop("stage")
end

---@alias noteUIKitCall fun(this:UIKit):void
---@param modify noteUIKitCall|nil
---@return self|noteUIKitCall
function class:onSetup(modify)
    if (type(modify) == "function") then
        self:prop("onSetup", modify)
        if (self:prop("refreshing") == true) then
            modify(self)
        end
        return self
    end
    return self:prop("onStart")
end

---@param modify noteUIKitCall|nil
---@return self|noteUIKitCall
function class:onStart(modify)
    if (type(modify) == "function") then
        self:prop("onStart", modify)
        if (self:prop("refreshing") == true) then
            modify(self)
        end
        return self
    end
    return self:prop("onStart")
end

---@param frequency number
---@param callFunc noteUIKitCall
---@return void
function class:onRefresh(frequency, callFunc)
    if (type(frequency) == "number") then
        self:prop("frequency", frequency)
    end
    local onRefresh = callFunc
    local refreshTimer = self:prop("refreshTimer")
    if (type(onRefresh) == "function") then
        self:prop("onRefresh", onRefresh)
        if (self:prop("refreshing") == true) then
            if (isClass(refreshTimer, TimerClass)) then
                destroy(refreshTimer)
            end
            self:prop("refreshTimer", time.setInterval(self:prop("frequency"), function()
                onRefresh(self)
            end))
        end
    else
        self:clear("onRefresh")
        if (isClass(refreshTimer, TimerClass)) then
            self:clear("refreshTimer", true)
        end
    end
end

---@return void
function class:setup()
    local onSetup = self:prop("onSetup")
    if (type(onSetup) == "function") then
        onSetup(self)
    end
end

---@return void
function class:start()
    local onStart = self:onStart()
    if (type(onStart) == "function") then
        onStart(self)
    end
    local onRefresh = self:prop("onRefresh")
    if (type(onRefresh) == "function") then
        onRefresh(self)
        self:prop("refreshTimer", time.setInterval(self:prop("frequency"), function()
            onRefresh(self)
        end))
    end
    self:prop("refreshing", true)
end