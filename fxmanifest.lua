fx_version 'bodacious'
game 'gta5'

name "zhawty_studio_boilerplate"
description "Zhawty Studio Resource Boilerplate"
author "Zhawty & Snow"
version "1.0.0"

ui_page 'web/build/index.html'

lua54 ''

shared_script {
	'shared/*.lua'
}

client_script {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

files {
	'web/build/*',
	'web/build/**/*',
}