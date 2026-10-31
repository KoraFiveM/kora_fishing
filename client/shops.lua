local appId = 'qbfishing:shop'
local purchaseAction = 'qbfishing:purchase'
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
                description = 'In Stock: ' .. item.amount .. ' Price: ' .. item.price,
                image = itemInfo and itemInfo.image or item.image,
                action = {
                    id = purchaseAction,
                    label = 'Buy',
                    fields = {
                        { id = 'amount', label = 'Amount', type = 'number', min = 1, required = true },
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
        label = 'Fishing Shop',
        icon = 'Fish',
        content = {
            title = 'Fishing Shop',
            blocks = {
                { type = 'list', id = 'items', label = 'Available Items', empty = 'Nothing available at your current level.', items = buildShopItems() },
            },
        },
    } }
end

Kora.nui.registerApp({
    id = appId,
    title = 'Fishing Shop',
    description = 'Buy poles, bait, and gear for fishing.',
    icon = 'Fish',
    layout = 'compact',
    width = 500,
    height = 560,
    placement = 'right',
    footer = 'Press Escape to close',
    navigation = buildNavigation(),
    onAction = function(actionId, context)
        if actionId ~= purchaseAction then return end
        local itemKey = tonumber((context.itemId or ''):match('^shop:(%d+)$'))
        local amount = context.value and tonumber(context.value.amount)
        if not itemKey or not amount or amount <= 0 then
            return { notice = { tone = 'destructive', message = 'Enter a valid amount.' } }
        end
        TriggerServerEvent('qbfishing:server:purchaseItem', currentShopKey, itemKey, amount)
    end,
})

local function openShop(key)
    local confirm = Kora.callback.trigger('qbfishing:client:confirmOpenShop', key)
    if not confirm then return end
    currentShopKey = key
    Kora.nui.updateApp(appId, { navigation = buildNavigation() })
    Kora.nui.openApp(appId)
end

for key, shopData in ipairs(Config.Shop.locations) do
    local ped = Kora.entities.create(shopData.model, shopData.coords, { freeze = true, invincible = true })
    SetEntityHeading(ped, 20.0)
    exports.kora_target:addEntity(ped, {
        {
            icon = 'fas fa-fish',
            label = 'Open Fishing Shop',
            onSelect = function() openShop(key) end,
        }
    })
end