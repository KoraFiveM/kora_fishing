
for key, shopData in ipairs(Config.Shop.locations) do
    local ped = QB.entities.create(shopData.model, shopData.coords, {freeze = true, invincible = true})
    exports.qbtarget:addEntity(ped, {
            {
                icon = 'fas fa-fish',
                label = 'Open Fishing Shop',
                onSelect = function()
                    local confirm = QB.callback.trigger('qbfishing:client:confirmOpenShop', key)
                    if not confirm then return end
                    local items = {}
                    local level = exports.qbskills:getRep(source, 'fishing').level or 1
                    for itemKey, item in ipairs(Config.Shop.items) do
                        QB.print.debug(item)
                        if not item.level or level >= item.level then
                            items[#items + 1] = {
                                header = item.label,
                                icon = item.image,
                                txt = 'In Stock: ' .. item.amount .. ' Price: ' .. item.price,
                                action = function()
                                    local input = exports['qb-input']:ShowInput({
                                        header = 'Purchase ' .. item.name,
                                        submitText = 'Buy',
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
                                        TriggerServerEvent('qbfishing:server:purchaseItem', key, itemKey, tonumber(input.amount))
                                    end
                                end
                            }
                        end
                    end
                    exports['qb-menu']:openMenu(items)
                end
            }
        }
    )
end