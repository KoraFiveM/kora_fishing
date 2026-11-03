Kora.callback.register('qbfishing:server:canOpenBuyerMenu', function(source,  key)
    local src = source
    assert(src and key, 'Invalid source or key')
    assert(Config.Locations and Config.Locations.buyer and Config.Locations.buyer.locations[key], 'Invalid buyer location key')
    assert(Kora.distance.player(src, Config.Locations.buyer.locations[key].coords, 5), 'Player is too far from the buyer location')
    return true
end)

RegisterServerEvent('qbfishing:server:sellItem', function(key, item, number)
    local src = source
    assert(src and key and item and number, 'Invalid parameters')
    assert(Config.Locations and Config.Locations.buyer and Config.Locations.buyer.locations[key], 'Invalid buyer location key')
    assert(Kora.distance.player(src, Config.Locations.buyer.locations[key].coords, 5), 'Player is too far from the buyer location')
    local sellData = Config.Locations.buyer.items[item]
    assert(sellData, 'Invalid item')
    -- One transaction: the client amount must be a whole number (1-1000), and items and cash move together.
    exports.kora_core:sellItem(src, {
        item = sellData.item, amount = number, unitPrice = sellData.price, reason = 'qbfishing:sell',
    })
end)