
local IMAGE_BASE = 'nui://qbinventory/images/'
local appId = 'qb-fishing:catalog'
local inited = false

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if QB.nui.isAppOpen(appId) then
        QB.nui.closeApp(appId)
    end
end)

local function currentFishingLevel()
    if not inited then
        return 1
    end
    return (exports.qbskills:getRep('fishing') or {}).level or 1
end

local function sortedBaitNames(poleData)
    local names = {}
    for baitName in pairs(poleData.baits) do
        names[#names + 1] = baitName
    end
    table.sort(names, function(a, b)
        return (poleData.baits[a].level or 0) < (poleData.baits[b].level or 0)
    end)
    return names
end

local Items = exports['qb-core']:GetShared('Items')

local function buildFishItems(catchList, unlocked)
    local fishItems = {}
    for i = 1, #catchList do
        local fishName = catchList[i]
        fishItems[#fishItems + 1] = {
            id = 'fish:' .. fishName,
            label = Items[fishName] and Items[fishName].label or fishName,
            description = Items[fishName] and Items[fishName].description or nil,
            image = Items[fishName] and (IMAGE_BASE .. Items[fishName].image) or nil,
            tone = unlocked and 'success' or 'neutral',
        }
    end
    return fishItems
end

local function buildBaitItems(poleName, poleData, level)
    local baitItems = {}
    local baitNames = sortedBaitNames(poleData)
    for i = 1, #baitNames do
        local baitName = baitNames[i]
        local baitData = poleData.baits[baitName]
        local requiredLevel = baitData.level or 0
        local unlocked = level >= requiredLevel

        baitItems[#baitItems + 1] = {
            id = poleName .. ':' .. baitName,
            label = Items[baitName] and Items[baitName].label or baitName,
            description = unlocked
                and (('Unlocked at level %d'):format(requiredLevel))
                or (('Locked - requires level %d'):format(requiredLevel)),
            image = Items[baitName] and (IMAGE_BASE .. Items[baitName].image) or nil,
            tone = unlocked and 'success' or 'destructive',
            children = buildFishItems(baitData.catch, unlocked),
        }
    end
    return baitItems
end

local function buildPoleView(poleName, poleData, level)
    return {
        id = poleName,
        label = Items[poleName] and Items[poleName].label or poleName,
        icon = Items[poleName] and (IMAGE_BASE .. Items[poleName].image) or nil,
        content = {
            title = Items[poleName] and Items[poleName].label or poleName,
            description = Items[poleName] and Items[poleName].description or nil,
            blocks = {
                {
                    type = 'stats',
                    items = {
                        { label = 'Your Level',  value = level,                     icon = 'Star' },
                        { label = 'Max Level',   value = Config.fishing.maxLevel,   icon = 'Trophy' },
                    },
                },
                {
                    type = 'list',
                    id = 'baits',
                    layout = 'list',
                    empty = 'No baits configured for this pole.',
                    items = buildBaitItems(poleName, poleData, level),
                },
            },
        },
    }
end

local function buildNavigation()
    local level = currentFishingLevel()
    local nav = {}
    for poleName, poleData in pairs(Config.poles) do
        nav[#nav + 1] = buildPoleView(poleName, poleData, level)
    end
    table.sort(nav, function(a, b) return a.id < b.id end)
    return nav
end

QB.nui.registerApp({
    id = appId,
    title = 'Fishing Catalog',
    description = 'Poles, baits, and fish unlocked at your current fishing level.',
    icon = 'Fish',
    layout = 'standard',
    width = 900,
    height = 640,
    footer = 'Press Escape to close',
    navigation = buildNavigation(),
})

local function openFishingCatalog()
    if QB.nui.isAppOpen(appId) then return end

    QB.nui.updateApp(appId, { navigation = buildNavigation() })
    QB.nui.openApp(appId)
end

RegisterCommand('fishcatalog', function()
    openFishingCatalog()
end, false)
inited = true