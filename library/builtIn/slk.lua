---@private
function _SLK_UNIT(_v)
    _v._class = "unit"
    if (_v._parent == nil) then
        _v._parent = "hpea"
    end
    return _v
end

---@private
function _SLK_ABILITY(_v)
    _v._class = "ability"
    if (_v._parent == nil) then
        _v._parent = "ANcl"
    end
    return _v
end

---@private
function _SLK_DESTRUCTABLE(_v)
    _v._class = "destructable"
    if (_v._parent == nil) then
        _v._parent = "BTsc"
    end
    return _v
end
