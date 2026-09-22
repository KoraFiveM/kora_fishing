local function hasItem(item)
    return exports['qb-inventory']:HasItem(item)
end
if Config.Locations and Config.Locations.breakdown then
    local breakdown = Config.Locations.breakdown

    if #breakdown.items > 0 and #breakdown.locations > 0 then
        local appId = 'qbfishing:breakdown'
        local refineAction = 'qbfishing:refine'
        local currentBreakdownKey = nil

        local function buildRefineItems()
            local items = {}
            for itemKey, item in ipairs(breakdown.items) do
                if hasItem(item.item) then
                    items[#items + 1] = {
                        id = 'refine:' .. itemKey,
                        label = item.label,
                        description = 'Refine: ' .. item.label,
                        image = item.image,
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

        QB.nui.registerApp({
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

                local progress = QB.progressbar.start({
                    label = 'Refining ' .. item.label,
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
                TriggerServerEvent('qbfishing:server:refineItem', currentBreakdownKey, itemKey)
            end,
        })

        local function openRefineMenu(key)
            local can = QB.callback.trigger('qbfishing:server:openRefineMenu', key)
            if not can then return end

            local items = buildRefineItems()
            if #items == 0 then
                QB.notify.send({ title = "qb-fishing", message = "You do not have any items to refine.", type = "error" })
                return
            end

            currentBreakdownKey = key
            QB.nui.updateApp(appId, { navigation = buildNavigation() })
            QB.nui.openApp(appId)
        end

        for key, location in pairs(breakdown.locations) do
            exports.qbtarget:addBoxZone({
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
