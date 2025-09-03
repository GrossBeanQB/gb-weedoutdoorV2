fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GrossBean'
version '1.1.0'

client_scripts {
    'config.lua',
    'client/main.lua',
    'client/weedtables.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu'
}
