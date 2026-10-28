QB.callback.register('qbfishing:server:openRefineMenu', function(source, key)
    local src = source
    assert(src and key, 'Invalid source or key')
    assert(Config.Locations and Config.Locations.breakdown and Config.Locations.breakdown.locations[key], 'Invalid breakdown location key')
    assert(QB.distance.player(src, Config.Locations.breakdown.locations[key].coords, 5), 'Player is too far from the breakdown location')
    return true
end)

RegisterServerEvent('qbfishing:server:refineItem', function(key, item)
    local src = source
    assert(src and key and item, 'Invalid parameters')
    assert(Config.Locations and Config.Locations.breakdown and Config.Locations.breakdown.locations[key], 'Invalid breakdown location key')
    assert(QB.distance.player(src, Config.Locations.breakdown.locations[key].coords, 5), 'Player is too far from the breakdown location')
    local bd = Config.Locations.breakdown
    local refineData = bd.items[item]
    local item, rank = refineData.item, refineData.rank
    local give = {}
    if not exports.kora_inventory:removeItem(src, item, 1) then return end
    repeat
        Wait(0)
        rank = rank - 1
        local giveItem = bd.receiveItems[math.random(#bd.receiveItems)]
        local amount = math.random(bd.receiveAmounts.min, bd.receiveAmounts.max)
        give[#give + 1] = {item = giveItem, amount = amount}
    until rank == 0
    for _, itemData in ipairs(give) do
        exports.kora_inventory:addItem(src, itemData.item, itemData.amount )
    end
end)