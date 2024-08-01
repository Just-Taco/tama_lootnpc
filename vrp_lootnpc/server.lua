local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "npc_loot_vrp")

RegisterServerEvent('npc_loot_vrp:giveMoney')
AddEventHandler('npc_loot_vrp:giveMoney', function(npcNetId)
    local source = source
    local user_id = vRP.getUserId({source})
    if user_id then
        if npcNetId then
            local moneyAmount = math.random(Config.Money[1], Config.Money[2])
            vRP.giveMoney({user_id, moneyAmount})
            local text = Config.NotifyText['Robbed']:gsub("0amount0", moneyAmount)
            Config.Notify(text, source)
        end
    end
end)
