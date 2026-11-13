local appId = 'kora_fishing:shop'
local purchaseAction = 'kora_fishing:purchase'
local currentShopKey = nil

local function buildShopItems()
    local level = (exports.kora_skills:getRep('fishing') or {}).level or 1
    local items = {}
    for itemKey, item in ipairs(Config.Shop.items) do
        if not item.level or level >= item.level then
            local itemInfo = itemData(item.name)
            items[#items + 1] = {
                id = 'shop:' .. itemKey,
                label = (itemInfo and itemInfo.label) or item.label or item.name,
                description = Kora.lang('Shop.stock_price', item.amount, item.price),
                image = itemInfo and itemInfo.image or item.image,
                action = {
                    id = purchaseAction,
                    label = Kora.lang('Shop.buy'),
                    fields = {
                        { id = 'amount', label = Kora.lang('Shop.amount'), type = 'number', min = 1, required = true },
                    },
                },
            }
        end
    end
    return items
end

local function buildNavigation()
    return { {
        id = 'shop',
        label = Kora.lang('Shop.title'),
        icon = 'Fish',
        content = {
            title = Kora.lang('Shop.title'),
            blocks = {
                { type = 'list', id = 'items', label = Kora.lang('Shop.available_items'), empty = Kora.lang('Shop.empty'), items = buildShopItems() },
            },
        },
    } }
end

Kora.nui.registerApp({
    id = appId,
    title = Kora.lang('Shop.title'),
    description = Kora.lang('Shop.description'),
    icon = 'Fish',
    layout = 'compact',
    width = 500,
    height = 560,
    placement = 'right',
    footer = Kora.lang('Shop.close'),
    navigation = buildNavigation(),
    onAction = function(actionId, context)
        if actionId ~= purchaseAction then return end
        local itemKey = tonumber((context.itemId or ''):match('^shop:(%d+)$'))
        local amount = context.value and tonumber(context.value.amount)
        if not itemKey or not amount or amount <= 0 then
            return { notice = { tone = 'destructive', message = Kora.lang('Shop.invalid_amount') } }
        end
        TriggerServerEvent('kora_fishing:server:purchaseItem', currentShopKey, itemKey, amount)
    end,
})

local function openShop(key)
    local confirm = Kora.callback.trigger('kora_fishing:client:confirmOpenShop', key)
    if not confirm then return end
    currentShopKey = key
    Kora.nui.updateApp(appId, { navigation = buildNavigation() })
    Kora.nui.openApp(appId)
end

for key, shopData in ipairs(Config.Shop.locations) do
    local ped = Kora.entities.create(shopData.model, shopData.coords, { freeze = true, invincible = true })
    SetEntityHeading(ped, 20.0)
    hardenNpcPed(ped)
    exports.kora_target:addEntity(ped, {
        {
            icon = 'fas fa-fish',
            label = Kora.lang('Shop.open'),
            onSelect = function() openShop(key) end,
        }
    })
end