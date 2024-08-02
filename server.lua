if Config.Framework == 'vRP' then
    local Tunnel = module("vrp", "lib/Tunnel")
    local Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP", "npc_loot_vrp")

    function User(source)
        local user_id = vRP.getUserId({source})
        return user_id
    end

    function GiveCash(user_id, moneyAmount)
        vRP.giveMoney({user_id, moneyAmount})
    end

elseif Config.Framework == 'ESX' then
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

    function User(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer 
    end

    function GiveCash(xPlayer, moneyAmount)
        xPlayer.addAccountMoney('money', moneyAmount)
    end

elseif Config.Framework == 'QBcore' then
    QBCore = exports['qb-core']:GetCoreObject()

    function User(source)
        local Player = QBCore.Functions.GetPlayer(source)
        return Player
    end

    function GiveCash(Player, moneyAmount)
        Player.Functions.AddMoney('cash', moneyAmount)
    end

elseif Config.Framework == 'custom' then
    -- custom code
    Custom = {} -- Assuming you have some custom framework setup here

    function User(source)
        return Custom.getUserId(source)
    end

    function GiveCash(user_id, moneyAmount)
        Custom.giveMoney(user_id, moneyAmount)
    end

else
    error('Framework not set correct!')
end

RegisterServerEvent('lootnpc:giveMoney')
AddEventHandler('lootnpc:giveMoney', function(npcNetId)
    local source = source
    local user = User(source)
    if user then
        if npcNetId then
            local moneyAmount = math.random(Config.Money[1], Config.Money[2])
            GiveCash(user, moneyAmount)
            local text = Config.NotifyText['Robbed']:gsub("0amount0", moneyAmount)
            Config.Notify(text, source)
        end
    end
end)
