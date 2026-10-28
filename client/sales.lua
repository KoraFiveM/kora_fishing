local function hasItem(item)
    return exports['qb-inventory']:HasItem(item)
end

local appId = 'qbfishing:buyer'
local sellAction = 'qbfishing:sell'
local currentBuyerKey = nil
local function buildBuyerItems()
    local items = {}
    for itemKey, item in ipairs( Config.Locations.buyer.items) do
        if hasItem(item.item) then
            local itemInfo = itemData(item.item)
            items[#items + 1] = {
                id = 'buyer:' .. itemKey,
                label = itemInfo and itemInfo.label or item.label,
                description = 'Sell Price: ' .. item.price,
                image = itemInfo and itemInfo.image or item.image,
                action = {
                    id = sellAction,
                    label = 'Sell',
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
        id = 'sell',
        label = 'Sell Catch',
        icon = 'Fish',
        content = {
            title = 'Sell your catch',
            blocks = { { type = 'list', id = 'items', items = buildBuyerItems() } },
        },
    } }
end

QB.nui.registerApp({
    id = appId,
    title = 'Fish Buyer',
    description = 'Sell fish and other catches for cash.',
    icon = 'Fish',
    layout = 'compact',
    width = 500,
    height = 560,
    placement = 'right',
    footer = 'Press Escape to close',
    navigation = buildNavigation(),
    onAction = function(actionId, context)
        if actionId ~= sellAction then return end
        local itemKey = tonumber((context.itemId or ''):match('^buyer:(%d+)$'))
        local amount = context.value and tonumber(context.value.amount)
        if not itemKey or not amount or amount <= 0 then
            return { notice = { tone = 'destructive', message = 'Enter a valid amount.' } }
        end
        TriggerServerEvent('qbfishing:server:sellItem', currentBuyerKey, itemKey, amount)
    end,
})

local function openBuyerMenu(key)
    local can = QB.callback.trigger('qbfishing:server:canOpenBuyerMenu', key)
    if not can then return end
    local items = buildBuyerItems()
    if #items == 0 then
        QB.notify.send({ title = "qb-fishing", message = "You do not have any items to sell.", type = "error" })
        return
    end
    currentBuyerKey = key
    QB.nui.updateApp(appId, { navigation = buildNavigation() })
    QB.nui.openApp(appId)
end

for key, location in pairs(Config.Locations.buyer.locations) do
    local ped = QB.entities.create(location.model, location.coords, { freeze = true, invincible = true })
    SetEntityHeading(ped, location.coords.w)
    exports.kora_target:addEntity(ped, {
        {
            icon = 'fas fa-fish',
            label = 'Open Buyer Menu',
            onSelect = function() openBuyerMenu(key) end,
        }
    })
end

