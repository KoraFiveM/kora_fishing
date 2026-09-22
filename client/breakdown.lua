local function hasItem(item)
   return exports['qb-inventory']:HasItem(item)
end

if Config.Locations and Config.Locations.breakdown then
    local buyer = Config.Locations.breakdown
    if #buyer.items > 0 and #buyer.locations > 0 then
        for key, buyer in pairs(buyer.locations) do
            exports.qbtarget:addBoxZone({
                coords = buyer.coords,
                size = vector3(2.0, 2.0, 2.0),
                rotation = 0,
                options = {
                    {
                        icon = 'fas fa-fish',
                        label = 'Open Refine Menu',
                        onSelect = function()
                            local can = QB.callback.trigger('qbfishing:server:openRefineMenu', key)
                            if not can then return end
                            local hasItems = {}
                            for itemKey, item in ipairs(Config.Locations.breakdown.items) do
                                if not hasItem(item.item) then
                                    goto continue
                                end
                                hasItems[#hasItems + 1] = {
                                    header = item.label,
                                    icon = item.image,
                                    txt = 'Refine: ' .. item.label,
                                    action = function()
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
                                        TriggerServerEvent('qbfishing:server:refineItem', key, itemKey)
                                    end
                                }
                                ::continue::
                            end
                            exports['qb-menu']:openMenu(hasItems)
                        end
                    }
                }
            })
        end
    end
end
