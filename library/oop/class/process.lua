---@type Process
ProcessCurrent = ProcessCurrent or nil

---@class ProcessClass:Class
local class = Class(ProcessClass)

---@private
function class:construct(options)
    self:prop("name", options.name)
end

---@private
function class:destruct()
    self:over()
end

---@return string
function class:name()
    return self:prop("name")
end

--- 泡影数据
---@return table
function class:bubble()
    return self:prop("bubble")
end

--- 清空泡影数据
---@return table
function class:bubbleClear()
    local bubble = self:bubble()
    if (type(bubble) == "table") then
        for k, v in pairx(bubble) do
            if (isObject(v)) then
                destroy(v)
            end
            bubble[k] = nil
        end
        bubble = nil
    end
end

---@alias ProcessFunc fun(this:Process)
---@param modify ProcessFunc|nil
---@return self|ProcessFunc
function class:onStart(modify)
    return self:prop("onStart", modify)
end

---@param modify ProcessFunc|nil
---@return self|ProcessFunc
function class:onOver(modify)
    return self:prop("onOver", modify)
end

---@param modify Process|nil
---@return self|Process
function class:prev(modify)
    return self:prop("prev", modify)
end

---@type fun():void
function class:start()
    if (ProcessCurrent) then
        ProcessCurrent:over()
    end
    ProcessCurrent = self
    self:prop("bubble", {})
    local onStart = self:onStart()
    if (type(onStart) == "function") then
        onStart(self)
    end
end

---@return void
function class:restart()
    self:over()
    self:start()
end

---@param nextStageName string
---@return void
function class:next(nextStageName)
    self:over()
    if (nextStageName ~= nil) then
        local n = Process(nextStageName)
        if (n) then
            n:prev(self)
            n:start()
        end
    end
end

---@return void
function class:over()
    if (self == ProcessCurrent) then
        local onOver = self:onOver()
        if (type(onOver) == "function") then
            onOver(self)
        end
        self:bubbleClear()
        self:clear("bubble")
        ProcessCurrent = nil
    end
end
