
local IMAGE_BASE = 'nui://qbinventory/images/'
local appId = 'qb-fishing:catalog'

local ITEMS = {
    bass                = { label = 'Bass',                image = 'bass.png',                description = 'A feisty freshwater bass, hooked fresh from the water.' },
    blue_fish           = { label = 'Blue Fish',           image = 'blue_fish.png',           description = 'A slick, silvery bluefish with a sharp bite.' },
    catfish             = { label = 'Catfish',             image = 'catfish.png',             description = 'A whiskered bottom-feeder pulled up from the murky depths.' },
    closed_safe         = { label = 'Closed Safe',         image = 'closed_safe.png',         description = 'A heavy, rusted safe, still sealed shut. Who knows what is inside.' },
    copper_pipe         = { label = 'Copper Pipe',         image = 'copper_pipe.png',         description = 'A length of tarnished copper piping, worth a bit of scrap value.' },
    fishing_pole        = { label = 'Fishing Pole',        image = 'fishing_pole.png',        description = 'A sturdy pole for casting a line and reeling in a catch.' },
    flounder            = { label = 'Flounder',            image = 'flounder.png',            description = 'A flat-bodied fish plucked from the shallows.' },
    halibut             = { label = 'Halibut',             image = 'halibut.png',             description = 'A large, meaty flatfish prized by anglers.' },
    magnet_2lb          = { label = 'Magnet 2lb',          image = 'magnet_2lb.png',          description = 'A lightweight 2lb fishing magnet, only strong enough for small, light objects.' },
    magnet_5lb          = { label = 'Magnet 5lb',          image = 'magnet_5lb.png',          description = 'A 5lb fishing magnet with enough pull for mid-weight junk.' },
    magnet_10lb         = { label = 'Magnet 10lb',         image = 'magnet_10lb.png',         description = 'A 10lb fishing magnet, strong enough to drag up heavier items.' },
    magnet_20lb         = { label = 'Magnet 20lb',         image = 'magnet_20lb.png',         description = 'A powerful 20lb fishing magnet capable of hauling up the heaviest finds.' },
    magnet_pole         = { label = 'Magnet Pole',         image = 'fishing_pole.png',        description = 'A rugged pole rigged for magnet fishing, used to lower and retrieve a magnet.' },
    plug_bait           = { label = 'Plug Bait',           image = 'plug_bait.png',           description = 'A hard-bodied lure that mimics an injured baitfish.' },
    reddrum             = { label = 'Reddrum',             image = 'reddrum.png',             description = 'A coppery red drum fish, a solid catch for any angler.' },
    rusty_ak            = { label = 'Rusty Ak',            image = 'rusty_ak.png',            description = 'A corroded AK-pattern rifle, long since abandoned in the water.' },
    rusty_antenna       = { label = 'Rusty Antenna',       image = 'rusty_antenna.png',       description = 'A bent, rust-covered antenna pulled up on your magnet.' },
    rusty_bike          = { label = 'Rusty Bike',          image = 'rusty_bike.png',          description = 'An old bicycle frame, eaten away by rust after years underwater.' },
    rusty_box           = { label = 'Rusty Box',           image = 'rusty_box.png',           description = 'A dented metal box, rusted shut from years submerged.' },
    rusty_chain         = { label = 'Rusty Chain',         image = 'rusty_chain.png',         description = 'A length of heavy chain, caked in rust.' },
    rusty_pistol        = { label = 'Rusty Pistol',        image = 'rusty_pistol.png',        description = 'A corroded handgun, likely dumped to hide the evidence.' },
    rusty_motherboard   = { label = 'Rusty Motherboard',   image = 'rusty_motherboard.png',   description = 'A water-damaged circuit board, barely recognizable under the rust and grime.' },
    rusty_scanner       = { label = 'Rusty Scanner',       image = 'rusty_scanner.png',       description = 'An old barcode scanner, corroded from its time underwater.' },
    rusty_scrap_metal   = { label = 'Rusty Scrap Metal',   image = 'rusty_scrap_metal.png',   description = 'A twisted chunk of scrap metal, good for melting down.' },
    rusty_shotgun       = { label = 'Rusty Shotgun',       image = 'rusty_shotgun.png',       description = 'A rust-caked shotgun, its barrel clogged with silt.' },
    rusty_sign          = { label = 'Rusty Sign',          image = 'rusty_sign.png',          description = 'A faded, rusted street sign fished up from the bottom.' },
    rusty_tire          = { label = 'Rusty Tire',          image = 'rusty_tire.png',          description = 'An old tire with a rusted rim, dumped long ago.' },
    rusty_usb           = { label = 'Rusty Usb',           image = 'rusty_usb.png',           description = 'A tiny corroded USB drive, its contents long lost to water damage.' },
    rusty_wheelchair    = { label = 'Rusty Wheelchair',    image = 'rusty_wheelchair.png',    description = 'A rusted wheelchair frame, heavy and awkward to reel in.' },
    salmon              = { label = 'Salmon',              image = 'salmon.png',              description = 'A prized pink-fleshed salmon, fresh off the line.' },
    soft_plastic_bait   = { label = 'Soft Plastic Bait',   image = 'soft_plastic_bait.png',   description = 'A flexible plastic lure shaped to imitate live prey.' },
    spinner_bait        = { label = 'Spinner Bait',        image = 'spinner_bait.png',        description = 'A flashy lure with spinning blades that attract predatory fish.' },
    steelhead           = { label = 'Steelhead',           image = 'steelhead.png',           description = 'A muscular steelhead trout, a rewarding catch for any angler.' },
    trout               = { label = 'Trout',               image = 'trout.png',               description = 'A speckled trout, freshly reeled in.' },
    tuna                = { label = 'Tuna',                image = 'tuna.png',                description = 'A sizeable tuna, prized for its rich, meaty flesh.' },
    white_bass          = { label = 'White Bass',          image = 'white_bass.png',          description = 'A silvery white bass caught from open water.' },
    worm                = { label = 'Worm',                image = 'worm.png',                description = 'A wriggling worm, perfect for baiting a hook.' },
}

local POLE_ICONS = {
    fishing_pole = IMAGE_BASE .. 'fishing_pole.png',
    magnet_pole  = IMAGE_BASE .. 'fishing_pole.png',
}

local function itemImage(name)
    local item = ITEMS[name]
    return item and (IMAGE_BASE .. item.image) or nil
end

local function itemLabel(name)
    local item = ITEMS[name]
    return (item and item.label) or name
end

local function currentFishingLevel()
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

local function buildFishItems(catchList, unlocked)
    local fishItems = {}
    for i = 1, #catchList do
        local fishName = catchList[i]
        fishItems[#fishItems + 1] = {
            id = 'fish:' .. fishName,
            label = itemLabel(fishName),
            description = ITEMS[fishName] and ITEMS[fishName].description or nil,
            image = itemImage(fishName),
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
            label = itemLabel(baitName),
            description = unlocked
                and (('Unlocked at level %d'):format(requiredLevel))
                or (('Locked - requires level %d'):format(requiredLevel)),
            image = itemImage(baitName),
            tone = unlocked and 'success' or 'destructive',
            children = buildFishItems(baitData.catch, unlocked),
        }
    end
    return baitItems
end

local function buildPoleView(poleName, poleData, level)
    return {
        id = poleName,
        label = itemLabel(poleName),
        icon = POLE_ICONS[poleName],
        content = {
            title = itemLabel(poleName),
            description = ITEMS[poleName] and ITEMS[poleName].description or nil,
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
