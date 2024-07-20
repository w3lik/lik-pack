local isCustom = function(path)
    local l = #path - 3
    if (l < 2) then
        return false
    end
    local s = string.sub(path, l, l)
    return s == '.'
end

---@private
---@alias noteSlkUnit {modelAlias,Name,Description,Tip,Ubertip,Hotkey,level,race,type,goldcost,lumbercost,manaN,regenMana,mana0,HP,regenHP,regenType,fmade,fused,stockStart,stockRegen,stockMax,sight,nsight,collision,modelScale,file,fileVerFlags,scaleBull,scale,selZ,selCircOnWater,red,green,blue,occH,maxPitch,maxRoll,impactZ,impactSwimZ,launchX,launchY,launchZ,launchSwimZ,unitSound,RandomSoundLabel,MovementSoundLabel,LoopingSoundFadeOut,LoopingSoundFadeIn,auto,abilList,Sellitems,Sellunits,Markitems,Builds,Buttonpos_1,Buttonpos_2,Art,Specialart,unitShadow,buildingShadow,shadowH,shadowW,shadowX,shadowY,shadowOnWater,death,deathType,movetp,moveHeight,moveFloor,spd,maxSpd,minSpd,turnRate,acquire,minRange,weapsOn,Missileart_1,Missilespeed_1,Missilearc_1,MissileHoming_1,targs1,atkType1,weapTp1,weapType1,spillRadius1,spillDist1,damageLoss1,showUI1,backSw1,dmgpt1,rangeN1,RngBuff1,dmgplus1,dmgUp1,sides1,dice1,splashTargs1,cool1,Farea1,targCount1,Qfact1,Qarea1,Hfact1,Harea1,Missileart_2,Missilespeed_2,Missilearc_2,MissileHoming_2,targs2,atkType2,weapTp2,weapType2,spillRadius2,spillDist2,damageLoss2,showUI2,backSw2,dmgpt2,rangeN2,RngBuff2,dmgplus2,dmgUp2,sides2,dice2,splashTargs2,cool2,Farea2,targCount2,Qfact2,Qarea2,Hfact2,Harea2,defType,defUp,def,armor,targType,Propernames,nameCount,Awakentip,Revivetip,Primary,STR,STRplus,AGI,AGIplus,INT,INTplus,heroAbilList,hideHeroMinimap,hideHeroBar,hideHeroDeathMsg,Requiresacount,Requires1,Requires2,Requires3,Requires4,Requires5,Requires6,Requires7,Requires8,Reviveat,buffRadius,buffType,Revive,Trains,Upgrade,requirePlace,preventPlace,requireWaterRadius,pathTex,uberSplat,nbrandom,nbmmlcon,canBuildOn,isBuildOn,tilesets,special,campaign,inEditor,dropItems,hostilePal,useClickHelper,tilesetSpecific,Requires,Requiresamount,DependencyOr,Researches,upgrades,EditorSuffix,Casterupgradename,Casterupgradetip,Castrerupgradeart,ScoreScreenIcon,animProps,Attachmentanimprops,Attachmentlinkprops,Boneprops,castpt,castbsw,blend,run,walk,propWin,orientInterp,teamColor,customTeamColor,elevPts,elevRad,fogRad,fatLOS,repulse,repulsePrio,repulseParam,repulseGroup,isbldg,bldtm,bountyplus,bountysides,bountydice,goldRep,lumberRep,reptm,lumberbountyplus,lumberbountysides,lumberbountydice,cargoSize,hideOnMinimap,points,prio,formation,canFlee,canSleep,_id_force,_class,_type,_parent,_attr}
---@return {_id:string}
function slk_unit(_v)
    FRAMEWORK_SETTING(_SLK_UNIT(_v))
end

---@private
---@return {_id:string}
function slk_ability(_v)
    FRAMEWORK_SETTING(_SLK_ABILITY(_v))
end

---@private
---@return {_id:string}
function slk_destructable(_v)
    FRAMEWORK_SETTING(_SLK_DESTRUCTABLE(_v))
end

--- 只支持组件包
---@param typeName string
---@return void
function assets_selection(typeName) end

--- 只支持ttf
---@param ttfName string
---@return void
function assets_font(ttfName) end

--- 只支持tga
---@param tga string
---@return void
function assets_loading(tga) end

--- 只支持tga
---@param tga string
---@return void
function assets_preview(tga) end

--- assets外置资源必不带后缀名
--- 自定义（包括原生）必带后缀名（不限制tga）
--- 只支持tga
---@param path string
---@param alias string|nil
---@return void
function assets_icon(path, alias)
    if (type(path) == "string") then
        path = string.trim(path)
        alias = alias or path
        if (alias ~= path or false == isCustom(path)) then
            FRAMEWORK_ALIAS.icon[alias] = path
        end
    end
end

--- assets外置资源必不带后缀名
--- 自定义（包括原生）必带后缀名（一般为mdl）
--- 只支持mdx文件,自动贴图路径必须war3mapTextures开头，文件放入assets/war3mapTextures内
---@param path string
---@param alias string|nil
---@return void
function assets_model(path, alias)
    if (type(path) == "string") then
        path = string.trim(path)
        alias = alias or path
        if (alias ~= path or false == isCustom(path)) then
            FRAMEWORK_ALIAS.model[alias] = path
        end
    end
end

--- assets外置资源必不带后缀名，只支持mp3
--- 自定义（包括原生）必带后缀名（一般为wav、mp3）
--- 音效建议使用：48000HZ 192K 单通道
--- 音乐建议使用：48000HZ 320K
---@param path string
---@param alias string|nil
---@param soundType string | "vcm"| "v3d" | "bgm" | "vwp"
---@return void
function assets_sound(path, alias, soundType)
    if (type(path) == "string") then
        path = string.trim(path)
        alias = alias or path
        if (alias ~= path or false == isCustom(path)) then
            FRAMEWORK_ALIAS[soundType][alias] = path
        end
    end
end

--- 只支持UI套件
--- UI套件需按要求写好才能被正确调用！
---@type fun(kit:string):void
function assets_ui(kit) end

--- 只支持Plugins插件
--- Plugins插件需按要求写好才能被正确调用！
---@type fun(kit:string):void
function assets_plugins(kit) end

---@param _v noteSlkUnit
---@return noteSlkUnit
function assets_speech_extra(_v)
    return _v
end

--- 只支持原生单位语音(无别称)
---@param name string
---@param extra table<string,noteSlkUnit>
---@return void
function assets_speech(name, extra)
    if (nil ~= name) then
        name = string.trim(name)
        slk_unit({})
        FRAMEWORK_SPEECH[name] = true
        if (type(extra) == "table") then
            for _, e in pairx(extra) do
                if (type(e) == "table") then
                    slk_unit({})
                end
            end
        end
    end
end