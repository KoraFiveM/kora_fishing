local function hasItem(item)
    -- registerApp builds the menu at load, before the qb-inventory compat export may exist.
    local ok, has = pcall(function() return exports['qb-inventory']:HasItem(item) end)
    return ok and has == true
end
if Config.Locations and Config.Locations.breakdown then
    local breakdown = Config.Locations.breakdown

    if #breakdown.items > 0 and #breakdown.locations > 0 then
        local appId = 'kora_fishing:breakdown'
        local refineAction = 'kora_fishing:refine'
        local currentBreakdownKey = nil

        local function buildRefineItems()
            local items = {}
            for itemKey, item in ipairs(breakdown.items) do
                if hasItem(item.item) then
                    local itemData = itemData(item.item)
                    local label = itemData and itemData.label or item.label or item.item
                    items[#items + 1] = {
                        id = 'refine:' .. itemKey,
                        label = label,
                        description = 'Refine: ' .. label,
                        image = itemData and itemData.image or item.image,
                        action = { id = refineAction, label = 'Refine' },
                    }
                end
            end
            return items
        end

        local function buildNavigation()
            return { {
                id = 'refine',
                label = 'Refine Items',
                icon = 'Fish',
                content = {
                    title = 'Refine your catch',
                    blocks = { { type = 'list', id = 'items', items = buildRefineItems() } },
                },
            } }
        end

        Kora.nui.registerApp({
            id = appId,
            title = 'Refine Menu',
            description = 'Break down salvage for crafting materials.',
            icon = 'Fish',
            layout = 'compact',
            width = 500,
            height = 560,
            placement = 'right',
            footer = 'Press Escape to close',
            navigation = buildNavigation(),
            onAction = function(actionId, context)
                if actionId ~= refineAction then return end

                local itemKey = tonumber((context.itemId or ''):match('^refine:(%d+)$'))
                if not itemKey then return end

                local item = breakdown.items[itemKey]
                if not item then return end

                local sharedItem = not item.label and itemData(item.item)
                local label = item.label or (sharedItem and sharedItem.label) or item.item
                local progress = Kora.progressbar.start({
                    label = 'Refining ' .. label,
                    duration = 5000,
                    useWhileDead = false,
                    canCancel = true,
                    anim = {
                        dict = 'mp_arresting',
                        clip = 'a_uncuff',
                        flag = 17
                    }
                })
                if not progress then return end
                TriggerServerEvent('kora_fishing:server:refineItem', currentBreakdownKey, itemKey)
            end,
        })

        local function openRefineMenu(key)
            local can = Kora.callback.trigger('kora_fishing:server:openRefineMenu', key)
            if not can then return end

            local items = buildRefineItems()
            if #items == 0 then
                Kora.notify.send({ title = "qb-fishing", message = "You do not have any items to refine.", type = "error" })
                return
            end

            currentBreakdownKey = key
            Kora.nui.updateApp(appId, { navigation = buildNavigation() })
            Kora.nui.openApp(appId)
        end

        for key, location in pairs(breakdown.locations) do
            exports.kora_target:addBoxZone({
                coords = location.coords,
                size = vector3(2.0, 2.0, 2.0),
                rotation = 0,
                options = {
                    {
                        icon = 'fas fa-fish',
                        label = 'Open Refine Menu',
                        onSelect = function() openRefineMenu(key) end,
                    }
                }
            })
        end
    end
end
