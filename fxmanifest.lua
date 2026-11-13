name "Kora Fishing"
author "Kora"
description " Fishing For The Kora Framework"
fx_version "cerulean"
game "gta5"
version  '0.2.1'

dependency {
	'kora_core',
	'kora_skills',
	'kora_inventory'
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

-- kora_qa: Gherkin test scenarios (converted legacy tests), see [kora]/kora_qa/README.md
qa_feature 'tests/*.feature'

files {
    'locales/*.lua'
}
