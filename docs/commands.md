---
title: Commands
sidebar_position: 4
---

# Commands

| Command | Who | Description |
| --- | --- | --- |
| `/fishcatalog` | Any player (registered with restricted `false`, no ACE needed) | Opens the Fishing Catalog panel |

The catalog has one tab per pole in `Config.poles` (sorted by item name). Each tab shows the player's fishing level and `Config.fishing.maxLevel`, then each bait with "Unlocked at level N" or "Locked - requires level N" and the fish or salvage it can produce. It is built on the client from `Config.poles` and the player's `fishing` level, and is not zone dependent. Running the command while the panel is open does nothing; the panel also closes when the character unloads.

The resource registers no other commands.
