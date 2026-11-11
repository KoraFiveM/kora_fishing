Config = {}

-- Shop/buyer NPCs ignore temporary events (punched, shot at, shouted at) and stay put.
Config.npcIgnoreTempEvents = true

Config.fishing = {
    maxLevel = 99,
    minTime = 4000,
}

Config.poles = {
    fishing_pole = {
        baits = {
            worm = {
                level = 0,
                baseTime = 1000,
                xp = 8,
                catch = { 'flounder', 'reddrum', 'tuna' },
            },
            plug_bait = {
                level = 15,
                baseTime = 12000,
                xp = 16,
                catch = { 'steelhead', 'blue_fish', 'halibut' },
            },
            soft_plastic_bait = {
                level = 30,
                baseTime = 12000,
                xp = 24,
                catch = { 'catfish', 'white_bass', 'salmon' },
            },
            spinner_bait = {
                level = 45,
                baseTime = 12000,
                xp = 32,
                catch = { 'bass', 'trout' },
            },
        },
    },

    magnet_pole = {
        baits = {
            magnet_2lb = {
                level = 15,
                baseTime = 12000,
                xp = 16,
                catch = {
                    'rusty_usb',
                    'rusty_motherboard',
                    'rusty_scanner',
                    'rusty_antenna',
                    'copper_pipe',
                    'rusty_scrap_metal',
                    'rusty_pistol',
                },
            },
            magnet_5lb = {
                level = 30,
                baseTime = 12000,
                xp = 32,
                catch = {
                    'rusty_sign',
                    'rusty_chain',
                    'rusty_tire',
                    'rusty_box',
                },
            },
            magnet_10lb = {
                level = 45,
                baseTime = 12000,
                xp = 48,
                catch = {
                    'rusty_shotgun',
                    'rusty_ak',
                    'rusty_bike',
                    'rusty_wheelchair',
                },
            },
            magnet_20lb = {
                level = 60,
                baseTime = 12000,
                xp = 64,
                catch = {
                    'closed_safe',
                },
            },
        },
    },
}

local dockPoles = {
    fishing_pole = Config.poles.fishing_pole,
    magnet_pole = Config.poles.magnet_pole,
}

local function blipData(label, sprite, color, scale, shortrange)
    return {
        label = label,
        sprite = sprite,
        color = color,
        scale = scale,
        shortRange = shortrange,
    }
end
Config.Locations = {
    buyer = {
        items = {
            {item = 'flounder', price = 15},
            {item = 'reddrum', price = 15},
            {item = 'tuna', price = 15},
            {item = 'steelhead', price = 30},
            {item = 'blue_fish', price = 30},
            {item = 'halibut', price = 30},
            {item = 'catfish', price = 50},
            {item = 'white_bass', price = 50},
            {item = 'salmon', price = 50},
            {item = 'trout', price = 60},
            {item = 'bass', price = 60},
        },
        locations = {
            {coords = vector4(-1847.20, -1190.31, 13.32, 155.0), model = 'a_m_m_farmer_01', blip = blipData('Fish Buyer', 500, 3, 0.8, true)}
        }
    },
    breakdown = {
        items = {
            {item = 'rusty_usb', rank = 1},
            {item = 'rusty_motherboard', rank = 1},
            {item = 'rusty_scanner', rank = 1},
            {item = 'rusty_antenna', rank = 1},
            {item = 'copper_pipe', rank = 1},
            {item = 'rusty_scrap_metal', rank = 1},
            {item = 'rusty_pistol', rank = 1},
            {item = 'rusty_sign', rank = 2},
            {item = 'rusty_chain', rank = 2},
            {item = 'rusty_tire', rank = 2},
            {item = 'rusty_box', rank = 2},
            {item = 'rusty_shotgun', rank = 3},
            {item = 'rusty_ak', rank = 3},
            {item = 'rusty_bike', rank = 3},
            {item = 'rusty_wheelchair', rank = 3},
            {item = 'closed_safe', rank = 4},
        },
        locations = {
            {coords = vector3(1110.13, -2007.89, 31.05), blip = blipData('Breakdown Location', 867, 3, 0.8, true)}
        },
        receiveItems = {'rubber', 'metalscrap', 'plastic', 'iron', 'copper', 'glass', 'steel'},
        receiveAmounts = {min = 4, max = 10}
    }
}

Config.Shop = {
    blipData = {
        title = 'Fishing Shop',
        color = 3,
        sprite = 374,
        scale = 0.8,
        display = 4,
        shortRange = true,
        category = 'Fishing',
    },
    locations = {
        {coords = vector4(-1600.84, 5204.13, 3.31, 20.0), model = 'a_m_m_farmer_01', blip = true}
    },
    items = {
       {name = 'fishing_pole',      amount = 40, price = 100, level = 1},
       {name = 'magnet_pole',       amount = 20, price = 150, level = 15},
       {name = 'worm',              amount = 50, price = 10, level = 1},
       {name = 'plug_bait',         amount = 50, price = 25, level = 15},
       {name = 'soft_plastic_bait', amount = 50, price = 45, level = 30},
       {name = 'spinner_bait',      amount = 50, price = 55, level = 45},
       {name = 'magnet_2lb',        amount = 10, price = 15, level = 15},
       {name = 'magnet_5lb',        amount = 10, price = 40, level = 30},
       {name = 'magnet_10lb',       amount = 10, price = 60, level = 45},
       {name = 'magnet_20lb',       amount = 10, price = 80, level = 60},
    }
}
local function zoneBlips(label)
    return {
        blipData = {
            title = label,
            color = 3,
            sprite = 356,
            scale = 0.8,
            display = 4,
            shortRange = true,
            category = 'Fishing',
        }
    }
end
Config.zones = {
    {
        zone = 'poly',
        thickness = 5.5,
        poles = dockPoles,
        blip = zoneBlips('Sandy Bay Dock'),
        points = {
            vector3(1308.29, 4281.04, 31.91),
            vector3(1295.78, 4215.35, 31.91),
            vector3(1302.49, 4214.46, 32.08),
            vector3(1305.35, 4229.78, 31.89),
            vector3(1312.43, 4228.50, 31.92),
            vector3(1340.84, 4222.71, 31.93),
            vector3(1341.96, 4226.89, 31.92),
            vector3(1327.59, 4230.17, 31.88),
            vector3(1306.22, 4234.09, 31.92),
            vector3(1308.98, 4249.05, 31.91),
            vector3(1311.85, 4263.31, 31.90),
            vector3(1315.05, 4279.83, 31.89),
        },
    },
    {
        zone = 'poly',
        thickness = 5.5,
        poles = dockPoles,
        points = {
            vector3(-1662.44, -1155.45, 11.52),
            vector3(-1661.16, -1156.08, 11.59),
            vector3(-1675.49, -1173.18, 11.72),
            vector3(-1675.77, -1173.15, 11.55),
            vector3(-1677.32, -1171.84, 11.60),
            vector3(-1735.23, -1123.26, 11.68),
            vector3(-1738.92, -1127.53, 11.60),
            vector3(-1757.04, -1149.12, 11.59),
            vector3(-1791.59, -1190.33, 11.65),
            vector3(-1781.59, -1198.78, 11.66),
            vector3(-1812.70, -1236.03, 11.65),
            vector3(-1813.90, -1234.97, 11.52),
            vector3(-1783.97, -1200.01, 11.52),
            vector3(-1783.80, -1198.79, 11.52),
            vector3(-1793.85, -1190.37, 11.52),
            vector3(-1785.96, -1180.46, 11.52),
            vector3(-1735.27, -1120.78, 11.52),
            vector3(-1676.74, -1169.77, 11.52),
            vector3(-1676.30, -1170.32, 11.52),
        },
    },

    {
        zone = 'poly',
        thickness = 5.5,
        poles = dockPoles,
        points = {
            vector3(-1737.01, -1096.46, 11.13),
            vector3(-1805.77, -1178.40, 11.09),
            vector3(-1832.16, -1156.33, 11.10),
            vector3(-1880.21, -1213.45, 11.10),
            vector3(-1860.28, -1230.24, 11.10),
            vector3(-1859.30, -1227.82, 11.02),
            vector3(-1877.67, -1213.21, 11.02),
            vector3(-1856.35, -1187.52, 11.02),
            vector3(-1832.30, -1159.18, 11.02),
            vector3(-1806.84, -1179.80, 11.02),
            vector3(-1806.16, -1180.42, 11.02),
            vector3(-1805.52, -1180.93, 11.02),
            vector3(-1736.00, -1097.79, 11.02),
            vector3(-1735.55, -1097.49, 11.02),
            vector3(-1735.36, -1097.34, 11.02),
        },
    },

    {
        zone = 'poly',
        thickness = 5.5,
        blip = zoneBlips('Pier Lower Dock'),
        poles = dockPoles,
        points = {
            vector3(-1860.42, -1230.68, 7.26),
            vector3(-1866.19, -1237.67, 7.38),
            vector3(-1826.36, -1271.14, 7.28),
            vector3(-1801.59, -1241.65, 7.25),
            vector3(-1806.25, -1237.64, 7.22),
            vector3(-1807.16, -1238.38, 7.12),
            vector3(-1803.35, -1241.54, 7.12),
            vector3(-1808.11, -1246.97, 7.12),
            vector3(-1812.85, -1253.06, 7.12),
            vector3(-1826.57, -1268.72, 7.12),
            vector3(-1864.23, -1237.69, 7.12),
            vector3(-1864.58, -1237.50, 7.12),
            vector3(-1859.44, -1231.65, 7.18),
        },
    },

    {
        zone = 'poly',
        thickness = 3.5,
        poles = dockPoles,
        points = {
            vector3(-1662.44, -1155.45, 11.52),
            vector3(-1661.16, -1156.08, 11.59),
            vector3(-1675.49, -1173.18, 11.72),
            vector3(-1675.77, -1173.15, 11.55),
            vector3(-1677.32, -1171.84, 11.60),
            vector3(-1735.23, -1123.26, 11.68),
            vector3(-1738.92, -1127.53, 11.60),
            vector3(-1757.04, -1149.12, 11.59),
            vector3(-1791.59, -1190.33, 11.65),
            vector3(-1781.59, -1198.78, 11.66),
            vector3(-1812.70, -1236.03, 11.65),
            vector3(-1813.90, -1234.97, 11.52),
            vector3(-1783.97, -1200.01, 11.52),
            vector3(-1783.80, -1198.79, 11.52),
            vector3(-1793.85, -1190.37, 11.52),
            vector3(-1785.96, -1180.46, 11.52),
            vector3(-1735.27, -1120.78, 11.52),
            vector3(-1676.74, -1169.77, 11.52),
            vector3(-1676.30, -1170.32, 11.52),
        },
    },
    {
        zone = 'poly',
        thickness = 4.0,
        blip = zoneBlips('Highway Dock'),
        poles = dockPoles,
        points = {
            vector3(-3351.5510, 963.5696, 7.4297),
            vector3(-3408.0774, 963.5692, 7.5094),
            vector3(-3408.3340, 951.5104, 7.4082),
            vector3(-3428.6963, 951.2784, 7.2065),
            vector3(-3428.8657, 978.8679, 7.2160),
            vector3(-3428.7227, 983.8123, 7.3858),
            vector3(-3420.3435, 983.8123, 7.5764),
            vector3(-3416.8298, 983.8123, 7.5478),
            vector3(-3412.5522, 983.8123, 7.4895),
            vector3(-3408.4307, 983.8123, 7.5374),
            vector3(-3408.3335, 971.5737, 7.4041),
            vector3(-3345.8154, 971.4990, 7.3240),
            vector3(-3346.1653, 969.3766, 7.2965),
            vector3(-3360.5078, 969.6113, 7.2965),
            vector3(-3376.3914, 969.6355, 7.2965),
            vector3(-3398.2307, 969.6752, 7.4983),
            vector3(-3406.7749, 969.8685, 7.4911),
            vector3(-3409.4902, 969.7586, 7.3517),
            vector3(-3409.5403, 981.5486, 7.3517),
            vector3(-3412.7427, 981.5636, 7.4802),
            vector3(-3427.3916, 980.7371, 7.3517),
            vector3(-3427.3555, 977.6072, 7.3517),
            vector3(-3427.0715, 971.3098, 7.3517),
            vector3(-3426.8979, 966.7854, 7.3517),
            vector3(-3427.0564, 963.9075, 7.3517),
            vector3(-3427.0122, 953.6696, 7.3517),
            vector3(-3409.8965, 953.3080, 7.3517),
            vector3(-3409.7300, 964.0236, 7.3517),
            vector3(-3409.5669, 965.1011, 7.3517),
            vector3(-3401.3171, 965.4185, 7.2965),
            vector3(-3382.5383, 965.4432, 7.7061),
            vector3(-3363.7981, 965.4250, 7.7147),
            vector3(-3345.0012, 965.5070, 7.6679),
        },
    },
    {
        zone = 'poly',
        thickness = 4.0,
        blip = zoneBlips('Right Side Dock'),
        poles = dockPoles,
        points = {
            vector3(-1602.52, 5189.63, 3.41),
            vector3(-1609.04, 5203.92, 3.44),
            vector3(-1593.35, 5211.10, 2.99),
            vector3(-1616.45, 5261.26, 3.05),
            vector3(-1607.55, 5265.52, 3.29),
            vector3(-1606.66, 5263.55, 3.09),
            vector3(-1608.38, 5262.57, 3.21),
            vector3(-1605.56, 5256.45, 3.10),
            vector3(-1603.30, 5251.55, 3.11),
            vector3(-1581.23, 5203.58, 3.08),
            vector3(-1583.25, 5202.94, 2.99),
            vector3(-1608.29, 5260.05, 2.98),
            vector3(-1608.65, 5260.78, 2.98),
            vector3(-1609.83, 5262.29, 2.98),
            vector3(-1614.37, 5260.15, 2.98),
            vector3(-1612.82, 5256.70, 2.98),
            vector3(-1612.33, 5256.37, 2.98),
            vector3(-1607.78, 5247.13, 2.98),
            vector3(-1602.89, 5236.43, 2.98),
            vector3(-1598.22, 5226.79, 2.98),
            vector3(-1594.88, 5218.30, 2.98),
            vector3(-1592.04, 5211.51, 3.01),
            vector3(-1596.92, 5207.79, 3.32),
            vector3(-1607.16, 5204.05, 3.32),
            vector3(-1607.27, 5203.72, 3.32),
            vector3(-1602.29, 5191.31, 3.32),
            vector3(-1602.03, 5190.87, 3.32),
        },
    },

    {
        zone = 'poly',
        thickness = 4.0,
        blip = zoneBlips('New Area'),
        poles = dockPoles,
        points = {
            vector3(-286.87, 6627.67, 6.08),
            vector3(-288.50, 6629.08, 7.29),
            vector3(-288.47, 6628.89, 6.12),
            vector3(-269.23, 6647.60, 6.44),
            vector3(-268.28, 6646.43, 6.70),
            vector3(-269.92, 6644.79, 6.40),
        },
    },
}