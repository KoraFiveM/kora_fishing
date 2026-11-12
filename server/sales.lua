Kora.callback.register('kora_fishing:server:canOpenBuyerMenu', function(source,  key)
    local src = source
    assert(src and key, 'Invalid source or key')
    assert(Config.Locations and Config.Locations.buyer and Config.Locations.buyer.locations[key], 'Invalid buyer location key')
    assert(Kora.distance.player(src, Config.Locations.buyer.locations[key].coords, 5), 'Player is too far from the buyer location')
    return true
end)

RegisterServerEvent('kora_fishing:server:sellItem', function(key, item, number)
    local src = source
    assert(src and key and item and number, 'Invalid parameters')
    assert(type(number) == 'number' and number > 0 and number == math.floor(number), 'Invalid amount')
    assert(Config.Locations and Config.Locations.buyer and Config.Locations.buyer.locations[key], 'Invalid buyer location key')
    assert(Kora.distance.player(src, Config.Locations.buyer.locations[key].coords, 5), 'Player is too far from the buyer location')
    local sellData = Config.Locations.buyer.items[item]
    assert(sellData, 'Invalid item')
    local price = sellData.price
    local Item = sellData.item

    if exports.kora_inventory:removeItem(src, Item, number) then
        exports.kora_core:addMoney(src, 'cash', price * number)
    end
end)