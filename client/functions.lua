
function itemData(itemKey)
    local item = exports.kora_core:getShared('items', itemKey)
    if not item then return nil end
    item.image = 'nui://kora_inventory/images/' .. item.image
    return item
end

function hardenNpcPed(ped)
    if not Config.npcIgnoreTempEvents then return end
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)
    SetPedCanRagdoll(ped, false)
end
