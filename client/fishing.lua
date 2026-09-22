local isFishing, currentRod, currentZone = false, nil, nil

local function acceptablePole(zoneIndex, rod)
    local zone = Config.zones[zoneIndex]
    if not zone then return false end
    return zone.poles[rod] ~= nil
end

local function hasRod(rod)
    return exports['qb-inventory']:HasItem(rod)
end

local function hasFishingPole(zoneData)
    for pole in pairs(zoneData.poles) do
        if exports['qb-inventory']:HasItem(pole) then
            return true
        end
    end
    return false
end

local function timeByLevel(bait)
    if not currentRod or not bait then return nil end

    local rod = Config.poles[currentRod]
    local baitData = rod and rod.baits[bait]
    if not baitData then return nil end

    local requiredLevel = baitData.level or 1
    local baseTime = baitData.baseTime or 12000
    local currentLevel = (exports.qbskills:getRep('fishing') or {}).level or 1

    if currentLevel < requiredLevel then
        return nil
    end

    local maxLevel = Config.fishing.maxLevel
    local minTime = Config.fishing.minTime

    if currentLevel >= maxLevel then
        return minTime
    end

    local progress = (currentLevel - requiredLevel) / (maxLevel - requiredLevel)
    local time = baseTime - ((baseTime - minTime) * progress)

    return math.floor(math.max(minTime, time))
end

local function getBait()
    local zone = Config.zones[currentZone]
    if not zone or not currentRod then return nil end

    local poleZoneData = zone.poles[currentRod]
    if not poleZoneData then return nil end

    local currentLevel = (exports.qbskills:getRep('fishing') or {}).level or 1

    local bestBait, bestLevel = nil, math.huge
    for bait, baitData in pairs(poleZoneData.baits) do
        local requiredLevel = baitData.level or 1
        if requiredLevel < bestLevel
            and exports['qb-inventory']:HasItem(bait)
            and currentLevel >= requiredLevel
        then
            bestBait, bestLevel = bait, requiredLevel
        end
    end

    return bestBait
end

local inAnim = false
local function fishingAnim()
    if inAnim then return end
    inAnim = true
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_STAND_FISHING', 0, true)
end

local function stopFishingAnim()
    if not inAnim then return end
    ClearPedTasks(PlayerPedId())
    inAnim = false
end

local function fish()
    while isFishing and currentZone and currentRod do
        local bait = getBait()
        if not bait then
            QB.notify.send({ title = 'qb-fishing', message = 'You have no usable bait for this pole', type = 'error' })
            break
        end

        local waitTime = timeByLevel(bait)
        if not waitTime then
            QB.notify.send({ title = 'qb-fishing', message = 'You do not meet the level requirement for this bait', type = 'error' })
            break
        end

        fishingAnim()

        while waitTime > 0 and isFishing and currentZone and currentRod do
            Wait(1000)
            waitTime = waitTime - 1000
        end

        if isFishing and currentZone and currentRod then
            local minigame = QB.minigames.play('fishing')
            if minigame.success then
                TriggerServerEvent('qbfishing:server:catchFish', currentZone)
            end
        end
    end

    isFishing = false
    currentRod = nil
    stopFishingAnim()
end

RegisterNetEvent('qbfishing:client:goFish', function(rod)
    if source ~= 65535 then return end

    if not currentZone then return end

    if not acceptablePole(currentZone, rod) then
        QB.notify.send({ title = 'qb-fishing', message = 'You cannot use that pole here', type = 'error' })
        return
    end

    if not hasRod(rod) then
        QB.notify.send({ title = 'qb-fishing', message = 'You do not have that pole', type = 'error' })
        return
    end
    currentRod = rod
    isFishing = true
    fish()
end)

RegisterNetEvent('qbfishing:client:stopFishing', function()
    isFishing = false
    currentRod = nil
    stopFishingAnim()
 
    local objRod = QB.closest.object(GetEntityCoords(PlayerPedId()))
    if not objRod or not objRod.id or not DoesEntityExist(objRod.id) then return end
 
    local entity = objRod.id
    local hash = GetEntityModel(entity)
    if hash ~= GetHashKey('prop_fishing_rod_01') then return end
    if NetworkGetEntityIsNetworked(entity) then
        NetworkRequestControlOfEntity(entity)
        local timeout = GetGameTimer() + 1000
        while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
            Wait(0)
        end
        if not NetworkHasControlOfEntity(entity) then
            print('Failed to gain network control of rod entity, cannot delete')
            return
        end
    end
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
end)


for key, zoneData in ipairs(Config.zones) do
    QB.zones.poly({
        points = zoneData.points,
        thickness = zoneData.thickness,
        debug = false,
        onEnter = function()
            if hasFishingPole(zoneData) then
                QB.notify.send({ title = 'qb-fishing', message = 'You can use your fishing pole here', type = 'success' })
            end
            currentZone = key
        end,
        onExit = function()
            QB.notify.send({ title = 'qb-fishing', message = 'You have left the fishing zone', type = 'info' })
            currentZone = nil
            isFishing = false
            currentRod = nil
        end,
    })
end