fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Niknock HD'
description 'Plate Changer V2.1'
version '2.1.0'

client_script{
	'client.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/*.lua',
}

server_script{
	'@es_extended/locale.lua',
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'locales/*.lua',
	'server.lua',
}

shared_scripts {
	'config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'progressBars',
}
