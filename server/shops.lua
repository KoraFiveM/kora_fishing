QB.callback.register('qbfishing:client:confirmOpenShop', function(source, shopKey)
    local src = source
    assert(shopKey, 'Invalid shop key')
    assert(Config.Shop and Config.Shop.locations and Config.Shop.locations[shopKey], 'Shop does not exist')
    assert(QB.distance.player(src, Config.Shop.locations[shopKey].coords, 5.0), 'You are too far from the shop')
    return true
end)

RegisterNetEvent('qbfishing:server:purchaseItem', function(shopKey, itemKey, amount)
    local src = source
    assert(shopKey, 'Invalid shop key')
    assert(itemKey, 'Invalid item key')
    assert(amount and amount > 0, 'Invalid amount')
    assert(Config.Shop and Config.Shop.locations and Config.Shop.locations[shopKey], 'Shop does not exist')
    assert(Config.Shop.items[itemKey], 'Item does not exist')
    local data = Config.Shop.items[itemKey]
    if data.level then
        local level = (exports.qbskills:getRep(src, 'fishing') or {}).level or 1
        assert(level >= data.level, 'Your fishing level is too low to purchase this item')
    end
    assert(QB.distance.player(src, Config.Shop.locations[shopKey].coords, 5.0), 'You are too far from the shop')
    local price, item = data.price, data.name
    local totalPrice = price * amount
    assert(totalPrice > 0, 'Invalid total price')
    if exports.qbcore:removeMoney(src, 'cash', totalPrice) then
        exports.qbinventory:addItem(src, item, amount)
    end
end)