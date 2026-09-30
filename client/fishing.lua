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
        local begun, reason = QB.callback.trigger('qbfishing:server:beginCatch')
        if type(begun) ~= 'table' then
            QB.notify.send({ title = 'qb-fishing', message = reason or 'Unable to start a catch.', type = 'error' })
            break
        end

        local waitTime = begun.duration
        fishingAnim()
        while waitTime > 0 and isFishing and currentZone and currentRod do
            Wait(1000)
            waitTime = waitTime - 1000
        end

        if isFishing and currentZone and currentRod then
            local played, result = pcall(QB.minigames.play, 'fishing', nil, begun.authorization)
            local proof = played and type(result) == 'table' and result.success and result.proof or nil
            TriggerServerEvent('qbfishing:server:catchFish', currentZone, proof, begun.authorization)
            if not played then
                print(('qbfishing: fishing minigame failed: %s'):format(result))
                QB.notify.send({ title = 'qb-fishing', message = 'Unable to complete fishing. Please try again.', type = 'error' })
                break
            end
        end
    end

    if isFishing then TriggerServerEvent('qbfishing:server:stopFishing') end
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
            if hasFishingPole(zoneData) then
                QB.notify.send({ title = 'qb-fishing', message = 'You have left the fishing zone', type = 'info' })
            end
            if isFishing then TriggerServerEvent('qbfishing:server:stopFishing') end
            currentZone = nil
            isFishing = false
            currentRod = nil
        end,
    })
end