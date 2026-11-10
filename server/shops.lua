Kora.callback.register('kora_fishing:client:confirmOpenShop', function(source, shopKey)
    local src = source
    assert(shopKey, 'Invalid shop key')
    assert(Config.Shop and Config.Shop.locations and Config.Shop.locations[shopKey], 'Shop does not exist')
    assert(Kora.distance.player(src, Config.Shop.locations[shopKey].coords, 5.0), 'You are too far from the shop')
    return true
end)

RegisterNetEvent('kora_fishing:server:purchaseItem', function(shopKey, itemKey, amount)
    local src = source
    assert(shopKey, 'Invalid shop key')
    assert(itemKey, 'Invalid item key')
    assert(type(amount) == 'number' and amount > 0 and amount == math.floor(amount), 'Invalid amount')
    assert(Config.Shop and Config.Shop.locations and Config.Shop.locations[shopKey], 'Shop does not exist')
    assert(Config.Shop.items[itemKey], 'Item does not exist')
    local data = Config.Shop.items[itemKey]
    if data.level then
        local level = (exports.kora_skills:getRep(src, 'fishing') or {}).level or 1
        assert(level >= data.level, 'Your fishing level is too low to purchase this item')
    end
    assert(Kora.distance.player(src, Config.Shop.locations[shopKey].coords, 5.0), 'You are too far from the shop')
    local price, item = data.price, data.name
    local totalPrice = price * amount
    assert(totalPrice > 0, 'Invalid total price')
    if not exports.kora_core:removeMoney(src, 'cash', totalPrice) then return end
    if exports.kora_inventory:addItem(src, item, amount) then return end
    local refunded, refundError = exports.kora_core:addMoney(src, 'cash', totalPrice, 'kora_fishing-purchase-refund', true)
    if not refunded then
        print(('kora_fishing: purchase refund failed for player %s: %s'):format(src, tostring(refundError)))
    end
end)