Config = {}

Config.Framework = 'vRP' -- vRP | ESX | QBcore (if using vrp unmark the thing in fxmanifest.lua!) | custom: only use 'custom' if you can edit the server.lua by yourself
Config.cooldown = 20 -- secs
Config.lootDead = true
Config.Money = {50, 300}
Config.NotifyText = {
    ['NoWeapon'] = '^1You need to equip a weapon to rob the NPC.',
    ['Robbed'] = "^2You have robbed $ 0amount0 from the NPC." -- 0amount0 -- is the money
}
Config.Notify = function(message, source)
    if not IsDuplicityVersion() then
        TriggerEvent('chatMessage', message)
    else
        TriggerClientEvent('chatMessage', source, message)
    end
end
Config.Weapons = {
    { name = 'WEAPON_PISTOL', label = 'Pistol' },
    { name = 'WEAPON_SMG', label = 'SMG' },
    { name = 'WEAPON_ASSAULTRIFLE', label = 'Assault Rifle' },
}
