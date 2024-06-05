fx_version 'bodacious'
game 'gta5'

name "zhawty-permissions"
description "Permission system synced with database"
author "Zhawty Studio"
version "1.0.0"

lua54 ''

dependencies {
    '/server:7290',
    '/onesync',
    'oxmysql',
    'ox_lib'
}

shared_script {
    '@ox_lib/init.lua',
	'shared/*.lua'
}

client_script {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

files {
    'locales/*'
}