-- Run from the resource root: lua tests/shops.lua
-- Shop purchase amount (F#216) and server breakdown refine (F#217) with inert host boundaries.
local resource = arg[1] or '.'
local checks = 0
local function eq(actual, expected, why)
    checks = checks + 1
    assert(actual == expected, why .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local function load(path, state)
    local env = {}; for k, v in pairs(_G) do env[k] = v end
    env._G = env
    env.vector3 = function(x, y, z) return { x = x, y = y, z = z } end
    env.vector4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
    env.Kora = { util = {}, compat = {}, callback = { register = function() end }, distance = { player = function() return true end } }
    assert(loadfile(resource .. '/../kora_lib/modules/util/shared.lua', 't', env))()
    env.RegisterNetEvent = function(n, f) state.events[n] = f end
    env.RegisterServerEvent = env.RegisterNetEvent
    env.Wait = function() error('Wait must not be called') end
    env.exports = {
        kora_skills = { getRep = function() return { level = 99 } end },
        kora_core = {
            removeMoney = function(_, _, _, amt) state.paid = state.paid + amt; return true end,
            addMoney = function(_, _, _, amt) state.paid = state.paid - amt; return true end,
        },
        kora_inventory = {
            addItem = function(_, _, item, amt)
                if state.failAdd and state.adds >= state.failAdd and item ~= state.input then return false end
                state.adds = state.adds + 1; state.inv[item] = (state.inv[item] or 0) + amt; return true
            end,
            removeItem = function(_, _, item, amt)
                if (state.inv[item] or 0) < amt then return false end
                state.inv[item] = state.inv[item] - amt; return true
            end,
        },
    }
    assert(loadfile(resource .. '/shared/config.lua', 't', env))()
    assert(loadfile(resource .. path, 't', env))()
    return env
end

-- shop
local st = { events = {}, paid = 0, adds = 0, inv = {} }
local env = load('/server/shops.lua', st)
local buy = st.events['qbfishing:server:purchaseItem']
local itemKey = next(env.Config.Shop.items)
local shopKey = next(env.Config.Shop.locations)
for _, bad in ipairs({ 0, -1, 0.5, 1.5, '2', true, 0 / 0, math.huge, 101 }) do
    st.paid, st.adds = 0, 0; env.source = 3
    local ok = pcall(buy, shopKey, itemKey, bad)
    eq(ok, false, 'rejects ' .. tostring(bad)); eq(st.paid, 0, 'no charge for ' .. tostring(bad)); eq(st.adds, 0, 'no item for ' .. tostring(bad))
end
st.paid = 0; env.source = 3
eq(pcall(buy, shopKey, itemKey, 2), true, 'whole amount ok')
eq(st.paid, env.Config.Shop.items[itemKey].price * 2, 'charged price*amount')

-- refine
local rs = { events = {}, adds = 0, inv = {} }
local renv = load('/server/breakdown.lua', rs)
local refine = rs.events['qbfishing:server:refineItem']
local bd = renv.Config.Locations.breakdown
local key = next(bd.locations)
local itemName, refineData
for name, data in pairs(bd.items) do if data.rank > 1 then itemName, refineData = name, data break end end
renv.source = 3
eq(pcall(refine, key, 'no_such_item'), false, 'unknown refine key rejected cleanly')
rs.inv[refineData.item] = 1
eq(pcall(refine, key, itemName), true, 'refine ok without yielding')
eq(rs.inv[refineData.item], 0, 'input consumed')
eq(rs.adds, refineData.rank, 'one grant per rank')
-- failure mid-grant refunds input and rolls back rewards
rs.input = refineData.item
rs.inv, rs.adds, rs.failAdd = { [refineData.item] = 1 }, 0, 1
refine(key, itemName)
eq(rs.inv[refineData.item], 1, 'input refunded on failed grant')
for item, n in pairs(rs.inv) do if item ~= refineData.item then eq(n, 0, 'reward rolled back ' .. item) end end
print(('shops: %d checks passed'):format(checks))
