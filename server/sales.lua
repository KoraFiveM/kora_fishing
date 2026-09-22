QB.callback.register('qbfishing:server:canOpenBuyerMenu', function(source,  key)
    local src = source
    assert(src and key, 'Invalid source or key')
    assert(Config.Locations and Config.Locations.buyer and Config.Locations.buyer.locations[key], 'Invalid buyer location key')
    assert(QB.distance.player(src, Config.Locations.buyer.locations[key].coords, 5), 'Player is too far from the buyer location')
    return true
end)

RegisterServerEvent('qbfishing:server:sellItem', function(key, item, number)
    local src = source
    assert(src and key and item and number, 'Invalid parameters')
    assert(Config.Locations and Config.Locations.buyer and Config.Locations.buyer.locations[key], 'Invalid buyer location key')
    assert(QB.distance.player(src, Config.Locations.buyer.locations[key].coords, 5), 'Player is too far from the buyer location')
    local sellData = Config.Locations.buyer.items[item]
    assert(sellData, 'Invalid item')
    local price = sellData.price
    local Item = sellData.item
    local player = exports['qb-core']:GetPlayer(src)
    local itemData = player.Functions.GetItemByName(Item)

    if exports.qbinventory:removeItem(src, Item, number) then
        player.Functions.AddMoney('cash', price * number)
    end
end)