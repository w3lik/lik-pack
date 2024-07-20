---@class destructable
destructable = destructable or {}

---@param id string
---@return table
function destructable.slk(id)
    must(type(id) == "string")
    local v = slk.i2v(id)
    if (v) then
        v = v.slk
    else
        v = J.Slk["destructable"][id]
    end
    must(v ~= nil)
    return v
end

---@param whichDest number
function destructable.kill(whichDest)
    if (type(whichDest) == "number") then
        J.KillDestructable(whichDest)
    end
end

---@param whichDest number
---@param hasAnimate boolean
function destructable.reborn(whichDest, hasAnimate)
    if (type(whichDest) == "number") then
        J.DestructableRestoreLife(whichDest, J.GetDestructableMaxLife(whichDest), hasAnimate or false)
    end
end