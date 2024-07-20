---@class StoreClass:Class
local class = Class(StoreClass)

---@private
function class:construct(options)
    self:prop("key", options.key)
    self:prop("name", options.key)
    self:prop("icon", "Framework\\ui\\default.tga")
    self:prop("salesGoods", Array()) -- Array 售卖的数据，卖什么都行，常见TPL
    self:prop("salesPlayers", {}) -- int[] 玩家索引限定（只有这些玩家索引可买）
end

---@private
function class:destruct()
    self:clear("salesGoods", true)
end

--- 店铺名称
---@param modify string|nil
---@return self|string
function class:name(modify)
    return self:prop("name", modify)
end

--- 店铺图标
---@param modify string|nil
---@return self|string
function class:icon(modify)
    return self:prop("icon", modify)
end

--- 描述体
---@alias noteStoreDescriptionFunc fun(obj:Store):string[]
---@param modify nil|string[]|string|noteStoreDescriptionFunc
---@return self|string[]
function class:description(modify)
    local mType = type(modify)
    if (mType == "string" or mType == "table" or mType == "function") then
        return self:prop("description", modify)
    end
    local desc = {}
    local d = self:prop("description")
    if (type(d) == "string") then
        desc[#desc + 1] = d
    elseif (type(d) == "table") then
        for _, v in ipairs(d) do
            desc[#desc + 1] = v
        end
    elseif (type(d) == "function") then
        desc = d(self)
    end
    return desc
end

--- 限制玩家可买（只控制索引）
---@param modify:number[]|nil
---@return self|number[]
function class:salesPlayers(modify)
    if (modify ~= nil) then
        if (type(modify) ~= "table") then
            return self
        end
        self:prop("salesPlayers", modify)
    end
    return self:prop("salesPlayers")
end

--- 在售商品数组
---@return Array
function class:salesGoods()
    return self:prop("salesGoods")
end

--- 遍历在售商品
---@alias nodeSalesGoods {goods:ItemTpl|AbilityTpl|UnitTpl,worth:table,stock:number,period:number,delay:number,periodTimer:Timer|nil}
---@param actionFunc fun(enumGoods:nodeSalesGoods)
---@return void
function class:forEach(actionFunc)
    local goods = self:salesGoods()
    goods:forEach(function(key, value)
        J.Promise(actionFunc, nil, nil, key, value)
    end)
end

--- 插入（覆盖）售卖的商品，data填什么数据都行，常见填入TPL
---@see worth 价值
---@see stock 最大库存数量
---@see period 补货周期，默认0，0表示不会缺货也不会自动补货，大于0则按周期补货，小于0不补货
---@see delay 允许售卖延后时间，默认0
---@see enable 是否允许售卖延后时间，默认0
---@alias goodsOptions {goods:ItemTpl|AbilityTpl|UnitTpl,worth:nil|{gold:number},stock:number,period:number,delay:number,enable:boolean}
---@param goods ItemTpl|AbilityTpl|UnitTpl
---@param options goodsOptions
---@return void
function class:insert(goods, options)
    local id = goods:id()
    options = options or {}
    if (options.worth == nil and isClass(goods, ItemTplClass)) then
        options.worth = goods:worth()
    end
    options.stock = math.floor(options.stock or 1)
    if (options.stock < 1) then
        options.stock = 1
    end
    options.qty = options.qty or options.stock
    options.period = options.period or 0
    options.delay = options.delay or 0
    if (type(options.enable) ~= "boolean") then
        options.enable = true
    end
    options.goods = goods
    ---@type Array
    local salesGoods = self:prop("salesGoods")
    salesGoods:set(id, options)
end

--- 获取第index个商品的属性
---@param index number
---@return void
function class:get(index)
    must(type(index) == "number")
    ---@type Array
    local salesGoods = self:prop("salesGoods")
    local key = salesGoods:keys()[index]
    return salesGoods:get(key)
end

--- 设置某个TPL商品的属性
---@param goods ItemTpl|AbilityTpl|UnitTpl
---@param key string
---@param value any
---@return void
function class:set(goods, key, value)
    must(type(key) == "string")
    local id = goods:id()
    ---@type Array
    local salesGoods = self:prop("salesGoods")
    local v = salesGoods:get(id)
    if (type(v) == "table") then
        v[key] = value
    end
end

--- 删除某个商品
---@param goods ItemTpl|AbilityTpl|UnitTpl
---@return void
function class:remove(goods)
    local id = goods:id()
    ---@type Array
    local salesGoods = self:prop("salesGoods")
    salesGoods:set(id, nil)
end

--- 设置物品数量
---@param goods ItemTpl|AbilityTpl|UnitTpl
---@param variety number|string|nil
---@return void
function class:qty(goods, variety)
    local id = goods:id()
    ---@type Array
    local salesGoods = self:prop("salesGoods")
    local data = salesGoods:get(id)
    if (data ~= nil) then
        data.qty = math.cale(variety, data.qty)
        salesGoods:set(id, data)
        -- 只有自动补货需要补数量
        if (data.periodTimer == nil) then
            if (data.qty < data.stock and data.period > 0) then
                data.periodTimer = time.setInterval(data.period, function(curTimer)
                    if (data.qty >= data.stock) then
                        destroy(curTimer)
                        data.periodTimer = nil
                        return
                    end
                    data.qty = data.qty + 1
                end)
            end
        end
    end
end

--- 售出
---@param goods ItemTpl|AbilityTpl|UnitTpl
---@param qty number
---@param buyUnit Unit 购买单位
---@return void
function class:sell(goods, qty, buyUnit)
    qty = math.floor(qty or 1)
    must(qty >= 1)
    must(isClass(buyUnit, UnitClass))
    local id = goods:id()
    ---@type Array
    local salesGoods = self:prop("salesGoods")
    local data = salesGoods:get(id)
    if (data == nil) then
        return
    end
    if (data.qty < qty) then
        alerter.message(bu:owner(), true, "可售数量不足")
        return
    end
    if (data.worth ~= nil) then
        if (Game():worthCompare(buyUnit:owner():worth(), data.worth) ~= true) then
            alerter.message(buyUnit:owner(), true, "财力不足")
            return
        end
        -- 只有无限供应和自动补货需要扣数量
        if (data.period ~= 0) then
            self:qty("-=" .. qty)
        end
        buyUnit:owner():worth(data.worth, true)
    end
    event.syncTrigger(self, EVENT.Store.Sell, { triggerUnit = buyUnit, qty = qty })
end