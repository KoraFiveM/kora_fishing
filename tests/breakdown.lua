-- Run from qbfishing: lua tests/breakdown.lua [breakdown-source] [resource-root]
-- Actual config, shared item catalogue, item resolver and registered target/app callbacks; host boundaries are inert.
local resource = arg[2] or '.'
local sourcePath = arg[1] or resource .. '/client/breakdown.lua'
local checks = 0
local function eq(actual, expected, why)
    checks = checks + 1
    assert(actual == expected, why .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local function setup(edit)
    local env = {}; for key, value in pairs(_G) do env[key] = value end
    env._G, env.QBCoreSeed = env, nil
    env.vector3 = function(x, y, z) return { x = x, y = y, z = z } end
    env.vector4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
    local state = { owned = {}, definitions = {}, targets = {}, updates = {}, opened = {}, progress = {}, events = {}, notices = {}, lookups = 0, allowed = true, result = true }
    env.exports = {
        kora_inventory = { HasItem = function(_, name) return state.owned[name] == true end },
        kora_core = { getShared = function(_, kind, name)
            assert(kind == 'items'); state.lookups = state.lookups + 1
            local record = state.definitions[name]
            if not record then return nil end
            -- The export stand-in returns a fresh record; actual itemData owns image rewriting.
            local copy = {}; for key, value in pairs(record) do copy[key] = value end; return copy
        end },
        kora_target = { addBoxZone = function(_, definition) state.targets[#state.targets + 1] = definition end },
    }
    env.Kora = {
        nui = {
            registerApp = function(app) state.app = app end,
            updateApp = function(id, update) state.updates[#state.updates + 1] = { id = id, update = update } end,
            openApp = function(id) state.opened[#state.opened + 1] = id end,
        },
        callback = { trigger = function(name, key) assert(name == 'qbfishing:server:openRefineMenu'); state.lastKey = key; return state.allowed end },
        notify = { send = function(notice) state.notices[#state.notices + 1] = notice end },
        progressbar = { start = function(payload) state.progress[#state.progress + 1] = payload; return state.result end },
    }
    env.TriggerServerEvent = function(name, ...) state.events[#state.events + 1] = { name = name, args = table.pack(...) } end
    assert(loadfile(resource .. '/../kora_core/shared/items.lua', 't', env))()
    for _, definition in ipairs(env.QBCoreSeed.items) do state.definitions[definition.name] = definition end
    assert(loadfile(resource .. '/shared/config.lua', 't', env))()
    for _, item in ipairs(env.Config.Locations.breakdown.items) do state.owned[item.item] = true end
    if edit then edit(env, state) end
    assert(loadfile(resource .. '/client/functions.lua', 't', env))()
    assert(loadfile(sourcePath, 't', env))()
    state.env = env
    return state
end
local function menuItems(state)
    return state.app.navigation[1].content.blocks[1].items
end
local function selectItem(state, key, action)
    return state.app.onAction(action or 'qbfishing:refine', { itemId = 'refine:' .. key })
end

local state = setup()
eq(state.app.id, 'qbfishing:breakdown', 'registered app id')
eq(#menuItems(state), 16, 'all shipped salvage entries are present')
eq(#state.targets, #state.env.Config.Locations.breakdown.locations, 'one existing target per configured location')
state.targets[1].options[1].onSelect()
eq(state.lastKey, 1, 'target selection requests existing server authorization')
eq(state.opened[1], 'qbfishing:breakdown', 'authorized target opens existing app')
eq(state.updates[1].id, 'qbfishing:breakdown', 'existing app update id')
for key, item in ipairs(state.env.Config.Locations.breakdown.items) do
    local definition = state.definitions[item.item]
    eq(item.label, nil, 'stock config has no bespoke action label')
    eq(menuItems(state)[key].label, definition.label, 'stock list uses the shared label')
    eq(menuItems(state)[key].description, 'Refine: ' .. definition.label, 'stock list description')
    eq(menuItems(state)[key].image, 'nui://kora_inventory/images/' .. definition.image, 'existing image resolver stays unchanged')
    local before = state.lookups
    eq(selectItem(state, key), nil, 'successful action return stays nil')
    eq(state.lookups - before, 1, 'stock action resolves shared item once')
    local progress = state.progress[#state.progress]
    eq(progress.label, 'Refining ' .. definition.label, 'stock action uses a valid shared label')
    eq(progress.duration, 5000, 'existing duration'); eq(progress.canCancel, true, 'existing cancellation option')
    eq(progress.useWhileDead, false, 'existing death option')
    eq(progress.anim.dict, 'mp_arresting', 'existing animation dict'); eq(progress.anim.clip, 'a_uncuff', 'existing animation clip')
    eq(progress.anim.flag, 17, 'existing animation flag')
    local event = state.events[#state.events]
    eq(event.name, 'qbfishing:server:refineItem', 'existing event name')
    eq(event.args[1], 1, 'selected location key'); eq(event.args[2], key, 'selected original item key'); eq(event.args.n, 2, 'existing event arity')
end
for _, result in ipairs({ false, 'nil' }) do
    if result == 'nil' then state.result = nil else state.result = result end
    local before = #state.events
    eq(selectItem(state, 1), nil, 'cancelled action return stays nil')
    eq(#state.events, before, 'false or nil cancellation sends no refine event')
end
state.result = true
local before = #state.progress
state.app.onAction('other', { itemId = 'refine:1' })
for _, id in ipairs({ '', 'item:1', 'refine:x', 'refine:999' }) do state.app.onAction('qbfishing:refine', { itemId = id }) end
eq(#state.progress, before, 'unknown action/item controls do not start progress')
state.allowed = false; before = #state.opened; state.targets[1].options[1].onSelect()
eq(#state.opened, before, 'server denial does not open the app')
state.allowed = nil; state.targets[1].options[1].onSelect()
eq(#state.opened, before, 'nil server result does not open the app')
state.allowed = true
for name in pairs(state.owned) do state.owned[name] = false end
state.targets[1].options[1].onSelect()
eq(#state.opened, before, 'empty inventory does not open the app')
eq(state.notices[#state.notices].message, 'You do not have any items to refine.', 'existing empty-inventory notice')

state = setup(function(env) env.Config.Locations.breakdown.items[1].label = 'Configured salvage' end)
state.targets[1].options[1].onSelect(); before = state.lookups
selectItem(state, 1)
eq(state.progress[1].label, 'Refining Configured salvage', 'existing configured action label keeps priority')
eq(state.lookups, before, 'configured action label needs no shared lookup')
eq(menuItems(state)[1].label, state.definitions.rusty_usb.label, 'list keeps its existing shared-label priority')

for _, configured in ipairs({ true, false }) do
    state = setup(function(env, fixture)
        fixture.definitions.rusty_usb = nil
        env.Config.Locations.breakdown.items[1].image = 'configured.png'
        if configured then env.Config.Locations.breakdown.items[1].label = 'Configured salvage' end
    end)
    local label = configured and 'Configured salvage' or 'rusty_usb'
    eq(menuItems(state)[1].label, label, 'missing shared item uses configured label or raw name')
    eq(menuItems(state)[1].description, 'Refine: ' .. label, 'fallback description is safe')
    eq(menuItems(state)[1].image, 'configured.png', 'existing configured image fallback is preserved')
    state.targets[1].options[1].onSelect(); selectItem(state, 1)
    eq(state.progress[1].label, 'Refining ' .. label, 'action fallback is safe without shared data')
end
state = setup(function(env, fixture)
    local copy = {}; for key, value in pairs(fixture.definitions.rusty_usb) do copy[key] = value end
    copy.label = nil; fixture.definitions.rusty_usb = copy
    env.Config.Locations.breakdown.locations[2] = { coords = env.vector3(1, 2, 3) }
end)
eq(menuItems(state)[1].label, 'rusty_usb', 'existing shared record without label uses raw name')
state.targets[2].options[1].onSelect(); selectItem(state, 1)
eq(state.progress[1].label, 'Refining rusty_usb', 'unlabelled shared item action fallback')
eq(state.events[1].args[1], 2, 'target selection retains a second configured location key')
print(('breakdown: %d checks passed'):format(checks))
