local isFishing = {}

local function isPointInPoly(x, y, points)
    local inside = false
    local j = #points
    for i = 1, #points do
        local xi, yi = points[i].x, points[i].y
        local xj, yj = points[j].x, points[j].y
        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi + 0.0) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function getZoneHeightRange(zone)
    local minZ, maxZ = math.huge, -math.huge
    for _, point in ipairs(zone.points) do
        if point.z < minZ then minZ = point.z end
        if point.z > maxZ then maxZ = point.z end
    end

    local pad = zone.thickness or 0
    return minZ - pad, maxZ + pad
end

local function isInsideZone(src)
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    for index, zone in ipairs(Config.zones) do
        if isPointInPoly(pCoords.x, pCoords.y, zone.points) then
            local minZ, maxZ = getZoneHeightRange(zone)
            if pCoords.z >= minZ and pCoords.z <= maxZ then
                return zone, index
            end
        end
    end
    return false
end

local cooldown = {}

local function startCooldown(src)
    if cooldown[src] then
        return false
    end
    CreateThread(function()
        cooldown[src] = true
        Wait(2000)
        cooldown[src] = nil
    end)
    return true
end

local function startFishing(src, rod, zoneIndex)
    isFishing[src] = {
        rod = rod,
        zone = zoneIndex,
    }
end

local function stopFishing(src)
    isFishing[src] = nil
end

local poles = { 'fishing_pole', 'magnet_pole' }

for _, poleItem in ipairs(poles) do
    exports['qb-core']:CreateUseableItem(poleItem, function(source)
        if isFishing[source] then
            stopFishing(source)
            TriggerClientEvent('qbfishing:client:stopFishing', source)
            TriggerClientEvent('QBCore:Notify', source, 'You reel in your line.', 'success')
            return
        end

        if cooldown[source] then
            TriggerClientEvent('QBCore:Notify', source, 'You must wait before fishing again.', 'error')
            return
        end

        local zone, zoneIndex = isInsideZone(source)
        if zone and zone.poles[poleItem] then
            startFishing(source, poleItem, zoneIndex)
            startCooldown(source)
            TriggerClientEvent('qbfishing:client:goFish', source, poleItem)
        else
            TriggerClientEvent('QBCore:Notify', source, 'You are not in a fishing zone.', 'error')
        end
    end)
end

local function getBait(src)
    local rod = isFishing[src] and isFishing[src].rod
    if not rod then return nil end

    local zoneIndex = isFishing[src] and isFishing[src].zone
    if not zoneIndex then return nil end

    local zone = Config.zones[zoneIndex]
    if not zone then return nil end

    local rodData = zone.poles[rod]
    if not rodData then return nil end

    local currentLevel = (exports.qbskills:getRep(src, 'fishing') or {}).level or 1

    local bestBait, bestLevel = nil, math.huge
    for bait, baitData in pairs(rodData.baits) do
        local requiredLevel = baitData.level or 1
        if requiredLevel < bestLevel
            and currentLevel >= requiredLevel
            and exports['qb-inventory']:HasItem(src, bait)
        then
            bestBait, bestLevel = bait, requiredLevel
        end
    end
    return bestBait
end

RegisterNetEvent('qbfishing:server:catchFish', function()
    local src = source
    local zone, zoneIndex = isInsideZone(src)
    assert(zone and zoneIndex, 'You are not inside a fishing zone')
    assert(isFishing[src], 'You are not currently fishing')
    assert(isFishing[src].zone == zoneIndex, 'You are not in the correct fishing zone')
    local pole = isFishing[src].rod
    local zoneData = Config.zones[zoneIndex]
    local confirmRod = zoneData.poles[pole]
    assert(confirmRod, 'This rod cannot be used in this zone')
    local bait = getBait(src)
    local confirmBait = confirmRod.baits[bait]
    assert(confirmBait, 'This bait cannot be used with the current rod in this zone')
    if exports['qb-inventory']:RemoveItem(src, bait, 1) then
        local caughtFish = confirmBait.catch[math.random(#confirmBait.catch)]
        exports['qb-inventory']:AddItem(src, caughtFish, 1)
        exports.qbskills:addRep(src, 'fishing', confirmBait.xp)
    end
end)

RegisterNetEvent('qbfishing:server:stopFishing', function()
    local src = source
    stopFishing(src)
    TriggerClientEvent('qbfishing:client:stopFishing', src)
end)

AddEventHandler('playerDropped', function()
    stopFishing(source)
    cooldown[source] = nil
end)