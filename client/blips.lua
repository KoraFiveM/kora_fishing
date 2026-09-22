
if Config.Locations then
    if Config.Locations.buyer then
        for _, location in ipairs(Config.Locations.buyer.locations) do
            if location.blip then
               QB.blips.create(location.coords, {
                label = location.blip.label,
                sprite = location.blip.sprite,
                color = location.blip.color,
                scale = location.blip.scale,
                shortRange = location.blip.shortRange,
               })
            end
        end
    end
    if Config.Locations.breakdown then
        for _, location in ipairs(Config.Locations.breakdown.locations) do
            if location.blip then
               QB.blips.create(location.coords, {
                label = location.blip.label,
                sprite = location.blip.sprite,
                color = location.blip.color,
                scale = location.blip.scale,
                shortRange = location.blip.shortRange,
               })
            end
        end
    end
end

if Config.Shop then
    for _, location in ipairs(Config.Shop.locations) do
        if location.blip then
           QB.blips.create(location.coords, {
            label = Config.Shop.blipData.title,
            sprite = Config.Shop.blipData.sprite,
            color = Config.Shop.blipData.color,
            scale = Config.Shop.blipData.scale,
            shortRange = Config.Shop.blipData.shortRange,
           })
        end
    end
end

if Config.zones then
    for _, zone in ipairs(Config.zones) do
        if zone.blip and zone.blip.blipData then
           QB.blips.create(zone.points[1], {
            label = zone.blip.blipData.title,
            sprite = zone.blip.blipData.sprite,
            color = zone.blip.blipData.color,
            scale = zone.blip.blipData.scale,
            shortRange = zone.blip.blipData.shortRange,
           })
        end
    end
end