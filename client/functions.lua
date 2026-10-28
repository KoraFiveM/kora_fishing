
function itemData(itemKey)
    local item = exports.kora_core:getShared('items', itemKey)
    if not item then return nil end
    item.image = 'nui://kora_inventory/images/' .. item.image
    return item
end