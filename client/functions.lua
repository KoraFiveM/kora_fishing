
function itemData(itemKey)
    local item = exports.qbcore:getShared('items', itemKey)
    if not item then return nil end
    item.image = 'nui://qbinventory/images/' .. item.image
    return item
end