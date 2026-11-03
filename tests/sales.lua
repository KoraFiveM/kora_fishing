-- Run from qbfishing: lua tests/sales.lua [sales-source] [resource-root]
-- Fish buyer sale (F#215): the client amount must be a whole number before anything is removed or paid.
-- Actual config and kora_lib Kora.util.toAmount; kora_core sellItem is a stand-in following its documented contract.
local resource = arg[2] or '.'
local sourcePath = arg[1] or resource .. '/server/sales.lua'
local checks = 0
local function eq(actual, expected, why)
    checks = checks + 1
    assert(actual == expected, why .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end

local env = {}; for key, value in pairs(_G) do env[key] = value end
env._G = env
env.vector3 = function(x, y, z) return { x = x, y = y, z = z } end
env.vector4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
local state = { fish = 10, cash = 0, near = true, events = {}, sales = {}, legacy = 0 }
env.Kora = {
    util = {}, compat = {},
    callback = { register = function() end },
    distance = { player = function() return state.near end },
}
assert(loadfile(resource .. '/../kora_lib/modules/util/shared.lua', 't', env))()
env.exports = {
    -- The legacy split path floored the item leg and paid the raw amount.
    kora_inventory = { removeItem = function(_, _, _, amount)
        state.legacy = state.legacy + 1
        amount = math.floor(amount)
        if amount < 1 or amount > state.fish then return false end
        state.fish = state.fish - amount; return true
    end },
    kora_core = {
        addMoney = function(_, _, _, amount) state.legacy = state.legacy + 1; state.cash = state.cash + amount; return true end,
        sellItem = function(_, src, spec)
            state.sales[#state.sales + 1] = { src = src, spec = spec }
            local count, reason = env.Kora.util.toAmount(spec.amount, { max = spec.maxAmount or 1000 })
            if not count then return false, reason end
            if count > state.fish then return false, 'not enough of item: ' .. spec.item end
            local total = math.floor(spec.unitPrice * count)
            state.fish = state.fish - count; state.cash = state.cash + total
            return true, { amount = count, total = total }
        end,
    },
}
env.RegisterServerEvent = function(name, fn) state.events[name] = fn end
assert(loadfile(resource .. '/shared/config.lua', 't', env))()
assert(loadfile(sourcePath, 't', env))()

local sell = state.events['qbfishing:server:sellItem']
assert(sell, 'legacy sell event is registered')
local buyer = env.Config.Locations.buyer
local price = buyer.items[1].price
local function reset() state.fish, state.cash, state.near, state.legacy = 10, 0, true, 0 end
local function run(...)
    env.source = 7
    return pcall(sell, ...)
end

reset(); run(1, 1, 1.999)
eq(state.cash, 0, 'fractional amount pays nothing')
eq(state.fish, 10, 'fractional amount removes nothing')
eq(state.legacy, 0, 'sale never uses the split remove/addMoney path')

for _, bad in ipairs({ 0, -1, 0.5, 2.5, 0 / 0, math.huge, 1001, '2', true }) do
    reset(); run(1, 1, bad)
    eq(state.cash, 0, 'invalid amount ' .. tostring(bad) .. ' pays nothing')
    eq(state.fish, 10, 'invalid amount ' .. tostring(bad) .. ' removes nothing')
end

reset(); run(1, 1, 3)
eq(state.fish, 7, 'whole amount removes that many items')
eq(state.cash, price * 3, 'whole amount pays the configured price')
local sale = state.sales[#state.sales]
eq(sale.src, 7, 'sale uses the event source')
eq(sale.spec.item, buyer.items[1].item, 'sale uses the server-side item name')
eq(sale.spec.unitPrice, price, 'sale uses the server-side price')
eq(sale.spec.amount, 3, 'raw client amount goes to the validated helper')
eq(type(sale.spec.reason) == 'string' and sale.spec.reason ~= '', true, 'sale passes a money reason')

reset(); run(1, 1, 3.0)
eq(state.cash, price * 3, 'integral float amount from msgpack still sells')

reset(); run(1, 1, 11)
eq(state.cash, 0, 'selling more than owned pays nothing')
eq(state.fish, 10, 'selling more than owned removes nothing')

reset(); state.near = false; local ok = run(1, 1, 1)
eq(ok, false, 'existing distance check still rejects')
eq(state.cash, 0, 'far player is not paid')

reset(); ok = run(1, #buyer.items + 1, 1)
eq(ok, false, 'unknown buyer item still rejects')
eq(#state.sales, 13,'only validated requests reach the sale helper')

print(('sales: %d checks passed'):format(checks))
