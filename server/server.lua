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
    exports.kora_core:createUseable(poleItem, function(source)
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

    local currentLevel = (exports.kora_skills:getRep(src, 'fishing') or {}).level or 1

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
    return bestBait, currentLevel
end

local function timeByLevel(rod, bait, currentLevel)
    local pole = Config.poles[rod]
    local baitData = pole and pole.baits[bait]
    if not baitData then return nil end

    local requiredLevel = baitData.level or 1
    local baseTime = baitData.baseTime or 12000
    if currentLevel < requiredLevel then return nil end

    local maxLevel = Config.fishing.maxLevel
    local minTime = Config.fishing.minTime
    if currentLevel >= maxLevel or maxLevel <= requiredLevel then return minTime end

    local progress = (currentLevel - requiredLevel) / (maxLevel - requiredLevel)
    local time = baseTime - ((baseTime - minTime) * progress)
    return math.floor(math.max(minTime, time))
end

Kora.callback.register('qbfishing:server:beginCatch', function(src)
    local fishing = isFishing[src]
    if not fishing then return false, 'You are not currently fishing.' end
    if fishing.pending then return false, 'A catch is already in progress.' end

    local zone, zoneIndex = isInsideZone(src)
    if not zone or zoneIndex ~= fishing.zone then return false, 'You have left the fishing zone.' end
    if not zone.poles[fishing.rod] or not exports['qb-inventory']:HasItem(src, fishing.rod) then
        return false, 'You do not have a usable fishing pole.'
    end

    local bait, level = getBait(src)
    if not bait then return false, 'You have no usable bait for this pole.' end
    local duration = timeByLevel(fishing.rod, bait, level)
    if not duration then return false, 'You do not meet the level requirement for this bait.' end

    local authorization = Kora.minigames.authorizeProof(src, 'fishing')
    fishing.pending = { bait = bait, authorization = authorization, readyAt = GetGameTimer() + duration }
    return { duration = duration, authorization = authorization }
end, { rateLimit = { max = 2, window = 1000 } })

RegisterNetEvent('qbfishing:server:catchFish', function(requestedZone, proof, authorization)
    local src = source
    local fishing = isFishing[src]
    local pending = fishing and fishing.pending
    if not pending or authorization ~= pending.authorization then return end
    if proof == nil then
        fishing.pending = nil
        return
    end
    if type(proof) ~= 'string' or GetGameTimer() < pending.readyAt then return end

    local zone, zoneIndex = isInsideZone(src)
    if not zone or zoneIndex ~= fishing.zone or (requestedZone ~= nil and requestedZone ~= zoneIndex) then return end
    local rod = zone.poles[fishing.rod]
    if not rod or not exports['qb-inventory']:HasItem(src, fishing.rod) then return end
    local bait = rod.baits[pending.bait]
    if not bait or not exports['qb-inventory']:HasItem(src, pending.bait) then return end
    local level = (exports.kora_skills:getRep(src, 'fishing') or {}).level or 1
    if level < (bait.level or 1) then return end
    if not Kora.minigames.consumeProof(src, proof, 'fishing', authorization) then return end

    -- Consume before inventory exports so an in-flight catch cannot be rewarded twice.
    fishing.pending = nil
    if exports['qb-inventory']:RemoveItem(src, pending.bait, 1) then
        local caughtFish = bait.catch[math.random(#bait.catch)]
        exports['qb-inventory']:AddItem(src, caughtFish, 1)
        exports.kora_skills:addRep(src, 'fishing', bait.xp)
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

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    stopFishing(src)
    cooldown[src] = nil
end)