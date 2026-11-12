# kora_fishing agent guide

`kora_fishing` is a Kora fishing and magnet-fishing resource: players use poles in configured dock zones, play a `kora_lib` minigame for catches and XP (`kora_skills`), buy gear, sell fish, and refine salvage. Layout: `fxmanifest.lua`, `shared/config.lua` (all config), `client/` (fishing loop and zones, shop, buyer and refine NUI apps, catalog and `/fishcatalog`, blips), `server/` (catch authority, shop, buyer, refine), `images/` (item icons), `readme.md` (item definitions) and `tests/` (Lua regression scripts and kora_qa feature file).

## Documentation

User-facing documentation lives in `docs/` (Markdown, published via the Kora Docusaurus site, kora_docs_next). Read `docs/index.md` first for an overview of features, configuration, commands, exports, events and database usage.

Docs layout: `docs/index.md` (overview, features and documentation map), `docs/installation.md` (requirements, server.cfg order, setup checklist, tests), `docs/how-to-use.md` (fishing, bait, timing, shop, buyer, refine), `docs/commands.md` (`/fishcatalog`), `docs/api/` (`index.md` and `configuration.md`: every `Config` option; the resource has no exports) and topic pages `events.md`, `items.md`, `database.md`, `troubleshooting.md`. Update the page that matches the change.

When you add, change, or remove a feature, config option, command, export, event, item, permission, or database table/column, update the matching page in `docs/` in the same change. Keep docs accurate to the code; do not document behaviour that does not exist.

Docs rules: plain Markdown with `title`/`sidebar_position` front matter (no `id`/`slug`), relative links only between docs pages, assets inside `docs/`, fenced code blocks with a language, and no raw `<`, `>`, `{`, `}` outside code (pages are parsed as MDX). The release version comes from `fxmanifest.lua`'s `version` field.
