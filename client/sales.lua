local function hasItem(item)
   return exports['qb-inventory']:HasItem(item)
end

if Config.Locations and Config.Locations.buyer then
    local buyer = Config.Locations.buyer
    if #buyer.items > 0 and #buyer.locations > 0 then
        for key, buyer in pairs(buyer.locations) do
            local ped = QB.entities.create(buyer.model, buyer.coords, {freeze = true, invincible = true})
            exports.qbtarget:addEntity(ped, {
                {
                    icon = 'fas fa-fish',
                    label = 'Open Buyer Menu',
                    onSelect = function()
                        local can = QB.callback.trigger('qbfishing:server:canOpenBuyerMenu', key)
                        if not can then return end
                        local hasItems = {}
                        for itemKey, item in ipairs(Config.Locations.buyer.items) do
                            if not hasItem(item.item) then
                                goto continue
                            end
                            hasItems[#hasItems + 1] = {
                                header = item.label,
                                icon = item.image,
                                txt = 'Sell Price: ' .. item.price,
                                action = function()
                                    local input = exports['qb-input']:ShowInput({
                                        header = 'Sell ' .. item.item,
                                        submitText = 'Sell',
                                        inputs = {
                                            {
                                                type = 'number',
                                                isRequired = true,
                                                name = 'amount',
                                                text = 'Amount'
                                            }
                                        }
                                    })
                                    if input and input.amount then
                                        TriggerServerEvent('qbfishing:server:sellItem', key, itemKey, tonumber(input.amount))
                                    end
                                end
                            }
                            ::continue::
                        end
                        exports['qb-menu']:openMenu(hasItems)
                    end
                }
            })
        end
    end
end
