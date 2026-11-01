local function createBlip(coords, label, blip)
    Kora.blips.create(coords, {
        label = label,
        sprite = blip.sprite,
        color = blip.color,
        scale = blip.scale,
        shortRange = blip.shortRange,
    })
end

if Config.Locations then
    for _, section in ipairs({ 'buyer', 'breakdown' }) do
        if Config.Locations[section] then
            for _, location in ipairs(Config.Locations[section].locations) do
                if location.blip then
                    createBlip(location.coords, location.blip.label, location.blip)
                end
            end
        end
    end
end

if Config.Shop then
    for _, location in ipairs(Config.Shop.locations) do
        if location.blip then
            createBlip(location.coords, Config.Shop.blipData.title, Config.Shop.blipData)
        end
    end
end

if Config.zones then
    for _, zone in ipairs(Config.zones) do
        if zone.blip and zone.blip.blipData then
            createBlip(zone.points[1], zone.blip.blipData.title, zone.blip.blipData)
        end
    end
end
