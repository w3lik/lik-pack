--- 音效播放
---@param v Vcm|V3d|Bgm
---@param whichPlayer Player|nil
---@param optCall fun(this:Vcm|V3d|Bgm):void
---@return void
function audio(v, whichPlayer, optCall)
    local f = function()
        if (inClass(v, VcmClass, V3dClass, VwpClass)) then
            if (type(optCall) == "function") then
                optCall(v)
            else
                v:volume(100)
            end
            v:play()
        end
    end
    if (isClass(whichPlayer, PlayerClass)) then
        async.call(whichPlayer, f)
    else
        f()
    end
end
