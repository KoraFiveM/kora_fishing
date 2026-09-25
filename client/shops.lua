if Config.Shop and Config.Shop.locations and Config.Shop.items then
    local appId = 'qbfishing:shop'
    local purchaseAction = 'qbfishing:purchase'
    local currentShopKey = nil
    
    local function buildShopItems()
        local level = (exports.qbskills:getRep('fishing') or {}).level or 1
        local items = {}
        for itemKey, item in ipairs(Config.Shop.items) do
            if not item.level or level >= item.level then
                items[#items + 1] = {
                    id = 'shop:' .. itemKey,
                    label = item.label,
                    description = 'In Stock: ' .. item.amount .. ' Price: ' .. item.price,
                    image = item.image,
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
                    { type = 'list', id = 'items', empty = 'Nothing available at your current level.', items = buildShopItems() },
                },
            },
        } }
    end

    QB.nui.registerApp({
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
        local confirm = QB.callback.trigger('qbfishing:client:confirmOpenShop', key)
        if not confirm then return end

        currentShopKey = key
        QB.nui.updateApp(appId, { navigation = buildNavigation() })
        QB.nui.openApp(appId)
    end

    for key, shopData in ipairs(Config.Shop.locations) do
        local ped = QB.entities.create(shopData.model, shopData.coords, { freeze = true, invincible = true })
        exports.qbtarget:addEntity(ped, {
            {
                icon = 'fas fa-fish',
                label = 'Open Fishing Shop',
                onSelect = function() openShop(key) end,
            }
        })
    end
end
