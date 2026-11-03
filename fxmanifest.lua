name "kora_fishing"
-- Keep the legacy resource name resolvable for exports['qbfishing'] callers.
provide 'qbfishing'
author "mustache_dom"
description "Fishing, fish buyers, tackle shops and item breakdown for Kora"
fx_version "cerulean"
game "gta5"
version  '1.0.0'

dependency {
	'kora_lib',
	'kora_core',
	'kora_inventory',
	'kora_target',
	'kora_skills'
}
client_scripts {
	'client/functions.lua',
	'client/blips.lua',
	'client/breakdown.lua',
	'client/client_catalog.lua',
	'client/fishing.lua',
	'client/sales.lua',
	'client/shops.lua',
}

server_scripts {
	'server/**.lua'
}

shared_scripts {
    '@kora_lib/init.lua',
	'@kora_core/init.lua',
	'shared/**.lua',
}

lua54 'yes'
