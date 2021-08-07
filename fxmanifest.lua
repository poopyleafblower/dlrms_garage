fx_version 'adamant'
game 'gta5'
version '1.0'
description 'Delarmuss Garage Script' 
author 'https://github.com/Delarmuss'
client_scripts {
    'client/client.lua',
    'client/functions.lua',
    'config.lua'
}
server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}
ui_page 'ui/ui.html'
files {
    'ui/*.html',
    'ui/css/*.css',
    'ui/font/*.ttf',
    'ui/js/*.js'
}