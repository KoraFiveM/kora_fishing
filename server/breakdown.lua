Kora.callback.register('qbfishing:server:openRefineMenu', function(source, key)
    local src = source
    assert(src and key, 'Invalid source or key')
    assert(Config.Locations and Config.Locations.breakdown and Config.Locations.breakdown.locations[key], 'Invalid breakdown location key')
    assert(Kora.distance.player(src, Config.Locations.breakdown.locations[key].coords, 5), 'Player is too far from the breakdown location')
    return true
end)

RegisterServerEvent('qbfishing:server:refineItem', function(key, item)
    local src = source
    assert(src and key and item, 'Invalid parameters')
    assert(Config.Locations and Config.Locations.breakdown and Config.Locations.breakdown.locations[key], 'Invalid breakdown location key')
    assert(Kora.distance.player(src, Config.Locations.breakdown.locations[key].coords, 5), 'Player is too far from the breakdown location')
    local bd = Config.Locations.breakdown
    local refineData = bd.items[item]
    assert(type(refineData) == 'table' and refineData.item and Kora.util.isInteger(refineData.rank) and refineData.rank > 0, 'Invalid refine item')
    local input, rank = refineData.item, refineData.rank
    local give = {}
    for _ = 1, rank do
        give[#give + 1] = {
            item = bd.receiveItems[math.random(#bd.receiveItems)],
            amount = math.random(bd.receiveAmounts.min, bd.receiveAmounts.max),
        }
    end
    if not exports.kora_inventory:removeItem(src, input, 1) then return end
    local granted = {}
    for _, itemData in ipairs(give) do
        if not exports.kora_inventory:addItem(src, itemData.item, itemData.amount) then
            -- Roll back so a full inventory never costs the player the input.
            for _, done in ipairs(granted) do exports.kora_inventory:removeItem(src, done.item, done.amount) end
            exports.kora_inventory:addItem(src, input, 1)
            return
        end
        granted[#granted + 1] = itemData
    end
end)
