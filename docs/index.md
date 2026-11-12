---
title: kora_fishing
sidebar_position: 1
---

# kora_fishing

`kora_fishing` adds fishing and magnet fishing to Kora servers. Players use a pole item inside a configured dock zone, wait for a level-dependent timer, play the `kora_lib` fishing minigame and receive a fish or salvage item plus fishing XP. They can buy gear from a shop NPC, sell fish to a buyer NPC for cash, and break salvage down into crafting materials at a refine spot. The server decides zones, bait, timing, rewards and prices; the client only supplies the minigame proof.

Current version: see `version` in `fxmanifest.lua`.

## Features

- **Fishing zones** - `Config.zones` are polygons with a height padding. A pole only works inside a zone whose `poles` table lists it. Entering a zone with a usable pole shows a notice, leaving it stops fishing. See [Fishing](./fishing.md).
- **Bait and levels** - each pole has baits with a required fishing level, base time, XP and a catch list. Higher level means shorter wait. See [Fishing](./fishing.md).
- **Magnet fishing** - `magnet_pole` with `magnet_2lb` to `magnet_20lb` pulls up rusty salvage instead of fish.
- **Fishing Shop** - a ped sells poles, baits and magnets for cash, gated by fishing level.
- **Fish Buyer** - a ped buys fish (cash only) at fixed prices.
- **Refine spot** - a box zone where salvage items are broken down into random materials.
- **Fishing Catalog** - the `/fishcatalog` command opens a panel listing poles, baits, unlock levels and possible catches. See [Commands](./commands.md).
- **Blips** - shop, buyer, refine spot and named zones get short-range map blips.

## Requirements

Declared as `dependency` in `fxmanifest.lua`:

| Resource | Used for |
| --- | --- |
| `kora_core` | Shared items (`getShared`), usable items (`createUseable`), money (`addMoney`, `removeMoney`) |
| `kora_skills` | The `fishing` skill: `getRep` (level) and `addRep` (XP) |
| `kora_inventory` | `addItem`, `removeItem` exports and the `qb-inventory` compatibility export (`HasItem`, `RemoveItem`, `AddItem`) |

Used but not declared as a dependency:

| Resource | Used for |
| --- | --- |
| `kora_lib` | Loaded through `@kora_lib/init.lua` in `shared_scripts`: NUI apps, callbacks, minigames (`Kora.minigames`), zones, blips, notifications, progress bar, entities, distance checks |
| `kora_target` | `addEntity` for the shop and buyer peds, `addBoxZone` for the refine spot (client) |

## Installation

1. Place the resource in your resources folder.
2. Ensure it after its dependencies in `server.cfg`:

   ```cfg
   ensure kora_lib
   ensure kora_core
   ensure kora_skills
   ensure kora_inventory
   ensure kora_target
   ensure kora_fishing
   ```

3. No SQL import is needed, the resource has no tables of its own (see [Database](./database.md)).
4. Every item the config names must exist in the `kora_core` shared items list, including the refine rewards. The fishing items are listed in [Items](./items.md). Item images are loaded from `nui://kora_inventory/images/`; copies are also in this resource's `images/` folder.
5. Make sure `kora_lib` has a `fishing` minigame configured, and `kora_skills` has the `fishing` skill (it ships in its default `skillOrder`).
6. Adjust [Configuration](./configuration.md).

## Testing

- `tests/run.sh` runs `tests/catches.lua` (catch authority, timing, proof binding, replay, client lifecycle, shop eligibility) and `tests/breakdown.lua` (refine app) with the system `lua`. `tests/breakdown.lua` reads `../kora_core/shared/items.lua`, so `kora_core` must be checked out next to this resource.
- `tests/checklist-jobs.feature` holds manual QA scenarios for `kora_qa` (registered with `qa_feature` in `fxmanifest.lua`).

## Pages

- [Fishing](./fishing.md) - how fishing, bait, timing, shop, buyer and refining work
- [Configuration](./configuration.md) - every `Config` option
- [Commands](./commands.md) - the `/fishcatalog` command
- [Events](./events.md) - net events and callbacks
- [Items](./items.md) - items used and their roles
- [Database](./database.md) - database use
- [Troubleshooting](./troubleshooting.md) - caveats and common problems

This resource exposes no exports. It defines no ACE permissions.
