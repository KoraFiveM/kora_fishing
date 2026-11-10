local isFishing, currentRod, currentZone = false, nil, nil

local function acceptablePole(zoneIndex, rod)
    local zone = Config.zones[zoneIndex]
    if not zone then return false end
    return zone.poles[rod] ~= nil
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
        local begun, reason = Kora.callback.trigger('kora_fishing:server:beginCatch')
        if type(begun) ~= 'table' then
            Kora.notify.send({ title = 'qb-fishing', message = reason or 'Unable to start a catch.', type = 'error' })
            break
        end

        local waitTime = begun.duration
        fishingAnim()
        while waitTime > 0 and isFishing and currentZone and currentRod do
            Wait(1000)
            waitTime = waitTime - 1000
        end

        if not isFishing or not currentZone or not currentRod then break end
        local played, result = pcall(Kora.minigames.play, 'fishing', nil, begun.authorization)
        local proof = played and type(result) == 'table' and result.success and result.proof or nil
        TriggerServerEvent('kora_fishing:server:catchFish', currentZone, proof, begun.authorization)
        if not played then
            print(('kora_fishing: fishing minigame failed: %s'):format(result))
            Kora.notify.send({ title = 'qb-fishing', message = 'Unable to complete fishing. Please try again.', type = 'error' })
            break
        end
    end

    if isFishing then TriggerServerEvent('kora_fishing:server:stopFishing') end
    isFishing = false
    currentRod = nil
    stopFishingAnim()
end

RegisterNetEvent('kora_fishing:client:goFish', function(rod)
    if source ~= 65535 then return end

    if not currentZone then return end

    if not acceptablePole(currentZone, rod) then
        Kora.notify.send({ title = 'qb-fishing', message = 'You cannot use that pole here', type = 'error' })
        return
    end

    if not exports['qb-inventory']:HasItem(rod) then
        Kora.notify.send({ title = 'qb-fishing', message = 'You do not have that pole', type = 'error' })
        return
    end
    currentRod = rod
    isFishing = true
    fish()
end)

RegisterNetEvent('kora_fishing:client:stopFishing', function()
    isFishing = false
    currentRod = nil
    stopFishingAnim()

    local objRod = Kora.closest.object(GetEntityCoords(PlayerPedId()))
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
    Kora.zones.poly({
        points = zoneData.points,
        thickness = zoneData.thickness,
        debug = false,
        onEnter = function()
            if hasFishingPole(zoneData) then
                Kora.notify.send({ title = 'qb-fishing', message = 'You can use your fishing pole here', type = 'success' })
            end
            currentZone = key
        end,
        onExit = function()
            if hasFishingPole(zoneData) then
                Kora.notify.send({ title = 'qb-fishing', message = 'You have left the fishing zone', type = 'info' })
            end
            if isFishing then TriggerServerEvent('kora_fishing:server:stopFishing') end
            currentZone = nil
            isFishing = false
            currentRod = nil
        end,
    })
end
