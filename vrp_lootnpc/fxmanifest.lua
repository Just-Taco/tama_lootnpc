fx_version 'cerulean'
games { 'gta5' }
author 'TacoTheDev'

dependency "vrp"

shared_script 'config.lua'
client_script 'client.lua'
server_scripts {
    "@vrp/lib/utils.lua",
    'server.lua'
}