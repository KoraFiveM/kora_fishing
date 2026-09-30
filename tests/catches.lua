local root = debug.getinfo(1, 'S').source:sub(2):match('(.*/)') .. '../'
local clientPath = arg[1] or root .. 'client/fishing.lua'
local function noop() end
local function vector(x, y, z, w) return { x = x, y = y, z = z, w = w } end

local function setup()
    local state = {
        now = 0, fish = 0, xp = 0, removed = 0, serial = 0, level = 1,
        items = { [1] = { fishing_pole = 1, worm = 20 }, [2] = { fishing_pole = 1, worm = 20 } },
        positions = { [1] = vector(1309.3, 4264, 31.9), [2] = vector(1309.3, 4264, 31.9) },
        events = {}, callbacks = {}, callbackOptions = {}, hooks = {}, useables = {}, authorizations = {}, proofs = {}, threads = {},
    }
    local env = setmetatable({
        source = 1, vector3 = vector, vector4 = vector,
        GetPlayerPed = function(src) return src end,
        GetEntityCoords = function(entity) return state.positions[entity] end,
        GetGameTimer = function() return state.now end,
        TriggerClientEvent = noop,
        RegisterNetEvent = function(name, fn) state.events[name] = fn end,
        AddEventHandler = function(name, fn) state.hooks[name] = fn end,
        CreateThread = function(fn)
            local thread = coroutine.create(fn)
            local ok, delay = coroutine.resume(thread)
            assert(ok, delay)
            if coroutine.status(thread) ~= 'dead' then
                state.threads[#state.threads + 1] = { thread = thread, wakeAt = state.now + delay }
            end
        end,
        Wait = coroutine.yield,
        QB = {
            callback = { register = function(name, fn, options)
                state.callbacks[name], state.callbackOptions[name] = fn, options
            end },
            minigames = {
                authorizeProof = function(src, kind)
                    assert(kind == 'fishing')
                    state.serial = state.serial + 1
                    local authorization = ('a%031d'):format(state.serial)
                    state.authorizations[authorization] = src
                    return authorization
                end,
                consumeProof = function(src, proof, kind, authorization)
                    local issued = state.proofs[proof]
                    if kind ~= 'fishing' or not issued or issued.src ~= src or issued.authorization ~= authorization then
                        return false
                    end
                    state.proofs[proof] = nil
                    return true
                end,
            },
        },
        exports = {
            ['qb-core'] = { CreateUseableItem = function(_, name, fn) state.useables[name] = fn end },
            ['qb-inventory'] = {
                HasItem = function(_, src, item)
                    if item == nil then src, item = 1, src end
                    return (state.items[src][item] or 0) > 0
                end,
                RemoveItem = function(_, src, item, amount)
                    if (state.items[src][item] or 0) < amount then return false end
                    state.items[src][item] = state.items[src][item] - amount
                    state.removed = state.removed + amount
                    if state.reenter then state.reenter() end
                    return true
                end,
                AddItem = function(_, _, _, amount) state.fish = state.fish + amount; return true end,
            },
            qbskills = {
                getRep = function() return { level = state.level } end,
                addRep = function(_, _, skill, amount) assert(skill == 'fishing'); state.xp = state.xp + amount end,
            },
        },
        math = setmetatable({ random = function() return 1 end }, { __index = math }),
    }, { __index = _G })
    assert(loadfile(root .. 'shared/config.lua', 't', env))()
    assert(loadfile(root .. 'server/server.lua', 't', env))()
    state.env = env
    return state
end

local function advance(state, duration)
    state.now = state.now + duration
    for index = #state.threads, 1, -1 do
        local timer = state.threads[index]
        if state.now >= timer.wakeAt then
            assert(coroutine.resume(timer.thread))
            assert(coroutine.status(timer.thread) == 'dead')
            table.remove(state.threads, index)
        end
    end
end

local function proofFor(state, begun, src)
    local proof = 'p' .. begun.authorization:sub(2)
    state.proofs[proof] = { src = src or 1, authorization = begun.authorization }
    return proof
end

local state = setup()
state.useables.fishing_pole(1)
local catch = state.events['qbfishing:server:catchFish']
for _ = 1, 3 do catch(1) end
assert(state.fish == 0 and state.xp == 0 and state.removed == 0, 'raw catch spam must not grant rewards or consume bait')
local begin = assert(state.callbacks['qbfishing:server:beginCatch'])
local quota = assert(state.callbackOptions['qbfishing:server:beginCatch']).rateLimit
assert(quota.max == 2 and quota.window == 1000, 'catch authorizations must have a bounded allocation rate')
local begun = assert(begin(1))
catch(1)
assert(begun.duration == state.env.Config.fishing.minTime and begin(1) == false, 'a raw event must not cancel an authorized catch')
local proof = proofFor(state, begun)
catch(1, proof, begun.authorization)
assert(state.fish == 0 and state.proofs[proof], 'a valid proof cannot bypass the server ready time')
advance(state, begun.duration)
state.useables.fishing_pole(2)
local other = assert(begin(2))
state.env.source = 2
catch(1, proof, begun.authorization)
advance(state, other.duration)
catch(1, proof, other.authorization)
catch(1, nil, other.authorization)
state.env.source = 1
catch(1, proof, 'wrong-authorization')
catch(2, proof, begun.authorization)
assert(state.fish == 0 and state.proofs[proof], 'other players, authorizations and zones cannot consume a valid catch')
state.positions[1] = vector(0, 0, 0)
catch(1, proof, begun.authorization)
assert(state.fish == 0 and state.proofs[proof])
state.positions[1] = vector(1309.3, 4264, 31.9)
state.reenter = function() catch(1, proof, begun.authorization) end
catch(1, proof, begun.authorization)
assert(state.fish == 1 and state.removed == 1 and state.xp == 8 and not state.proofs[proof])
catch(1, proof, begun.authorization)
assert(state.fish == 1 and state.removed == 1, 'reentrant calls and replays cannot redeem a catch again')
state.reenter = nil

for _, item in ipairs({ 'fishing_pole', 'worm' }) do
    begun = assert(begin(1))
    proof = proofFor(state, begun)
    advance(state, begun.duration)
    local count = state.items[1][item]
    state.items[1][item] = 0
    catch(1, proof, begun.authorization)
    assert(state.fish == 1 and state.removed == 1, 'rod and bait ownership must be fresh at completion')
    catch(1, nil, begun.authorization)
    assert(begin(1) == false, 'missing rod or bait also prevents beginning another catch')
    state.items[1][item] = count
end

begun = assert(begin(1))
advance(state, begun.duration)
catch(1, 'unissued-proof', begun.authorization)
assert(state.fish == 1)
catch(1, nil, begun.authorization)
begun = assert(begin(1))
catch(1, nil, begun.authorization)
assert(state.fish == 1, 'failed and cancelled minigames release their pending catch without rewards')

state.items[1].worm, state.items[1].plug_bait, state.level = 0, 10, 30
begun = assert(begin(1))
assert(begun.duration == 10571, 'preserve the original level-scaled bait timing formula')
catch(1, nil, begun.authorization)
state.level = 99
state.items[1].worm = 10
begun = assert(begin(1))
proof = proofFor(state, begun)
advance(state, begun.duration)
catch(1, proof, begun.authorization)
assert(state.items[1].worm == 9 and state.items[1].plug_bait == 10, 'keep the existing lowest-level bait selection')

for _, clear in ipairs({ 'stop', 'disconnect', 'unload' }) do
    local s = setup()
    s.useables.fishing_pole(1)
    local pending = assert(s.callbacks['qbfishing:server:beginCatch'](1))
    local oldProof = proofFor(s, pending)
    if clear == 'stop' then s.events['qbfishing:server:stopFishing']()
    elseif clear == 'disconnect' then s.hooks.playerDropped()
    else s.hooks['QBCore:Server:OnPlayerUnload'](1) end
    assert(s.callbacks['qbfishing:server:beginCatch'](1) == false)
    s.useables.fishing_pole(1)
    if clear == 'stop' then
        assert(s.callbacks['qbfishing:server:beginCatch'](1) == false, 'ordinary stop preserves the existing start cooldown')
        advance(s, 2000)
        s.useables.fishing_pole(1)
    end
    assert(s.callbacks['qbfishing:server:beginCatch'](1), 'disconnect and unload clear cooldown; normal stop waits for its timer')
    s.events['qbfishing:server:stopFishing']()
    advance(s, pending.duration)
    s.events['qbfishing:server:catchFish'](1, oldProof, pending.authorization)
    assert(s.fish == 0 and s.removed == 0, 'lifecycle cleanup invalidates old catch authorization')
end

for _, outcome in ipairs({ 'success', 'failed', 'cancelled', 'error', 'exit' }) do
    local s = setup()
    s.useables.fishing_pole(1)
    local clientEvents, zones, requests, beginCount, authorizedDuration = {}, {}, {}, 0, nil
    local client = setmetatable({
        source = 65535,
        RegisterNetEvent = function(name, fn) clientEvents[name] = fn end,
        PlayerPedId = function() return 1 end,
        TaskStartScenarioInPlace = noop, ClearPedTasks = noop,
        Wait = coroutine.yield,
        QB = {
            callback = { trigger = function(name)
                assert(name == 'qbfishing:server:beginCatch')
                beginCount = beginCount + 1
                local result = s.callbacks[name](1)
                assert(type(result) == 'table', 'previous minigame completion must release its pending catch')
                if beginCount > 1 then return false, 'Test loop complete.' end
                authorizedDuration = result.duration
                return result
            end },
            minigames = { play = function(kind, opts, authorization)
                assert(kind == 'fishing' and opts == nil and s.authorizations[authorization] == 1)
                assert(s.now >= authorizedDuration, 'client waits for the authorized server duration')
                coroutine.yield(250)
                if outcome == 'error' then error('controlled minigame transport failure') end
                if outcome == 'success' then return { success = true, proof = proofFor(s, { authorization = authorization }) } end
                return { success = false, cancelled = outcome == 'cancelled' }
            end },
            zones = { poly = function(zone) zones[#zones + 1] = zone end },
            notify = { send = noop },
            closest = { object = function() return nil end },
        },
        TriggerServerEvent = function(name, ...)
            requests[#requests + 1] = { name = name, args = table.pack(...) }
            s.events[name](...)
        end,
    }, { __index = s.env })
    assert(loadfile(clientPath, 't', client))()
    zones[1].onEnter()
    local thread = coroutine.create(function() clientEvents['qbfishing:client:goFish']('fishing_pole') end)
    local ok, wait = coroutine.resume(thread)
    assert(ok and wait == 1000)
    if outcome == 'exit' then zones[1].onExit() end
    while coroutine.status(thread) ~= 'dead' do
        advance(s, wait)
        ok, wait = coroutine.resume(thread)
        assert(ok, wait)
    end
    assert(requests[#requests].name == 'qbfishing:server:stopFishing')
    assert(s.callbacks['qbfishing:server:beginCatch'](1) == false, 'client shutdown clears the server session')
    if outcome == 'success' then
        assert(s.fish == 1 and requests[1].args[1] == 1 and type(requests[1].args[2]) == 'string')
    else
        assert(s.fish == 0 and s.removed == 0, 'failure, cancellation, transport errors and zone exit cannot grant catches')
    end
end
print('qbfishing: catch authority, timing, proof binding, replay, inventory and client lifecycle regression passed')
