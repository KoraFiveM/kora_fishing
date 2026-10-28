name "mustache-"
-- Keep the legacy resource name resolvable for exports['qbfishing'] callers.
provide 'qbfishing'
author "mustache_dom"
description " by mustache dom"
fx_version "cerulean"
game "gta5"
version  '1.0.0'

dependency {
	'kora_core',
	'kora_skills'
}
client_scripts {
	'client/functions.lua',
	'client/**.lua',
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
