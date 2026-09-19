name "mustache-"
author "mustache_dom"
description " by mustache dom"
fx_version "cerulean"
game "gta5"
version  '1.0.0'

client_scripts {
	'client/**.lua',
}

server_scripts {
	'server/**.lua'
}

shared_scripts {
    '@qblib/init.lua',
	'shared/**.lua',
}

lua54 'yes'
