local isNearNPC = false
local npcEntity = nil
local robbing

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
      
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
      
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
      
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function GetAllPeds()
    local peds = {}
    for ped in EnumeratePeds() do
        if DoesEntityExist(ped) and IsEntityAPed(ped) and IsPedHuman(ped) and not IsPedAPlayer(ped) then
            SetBlockingOfNonTemporaryEvents(ped, true)
            table.insert(peds, ped)
        end
    end
    return peds
end

local peds = GetAllPeds()

local Player = PlayerId()
SetPoliceIgnorePlayer(Player, true)
SetEveryoneIgnorePlayer(Player, true)
SetPlayerCanBeHassledByGangs(Player, false)
SetIgnoreLowPriorityShockingEvents(Player, true)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if not isNearNPC then
            Citizen.Wait(2500)
        end
        if robbing then
            Citizen.Wait(Config.cooldown * 1000)
            robbing = false
        end
        isNearNPC = false
        for key, npc in pairs(peds) do
            local dead = false
            if Config.lootDead then
                if IsEntityDead(npc) then
                    dead = true
                end
            else
                if IsEntityDead(npc) then
                    npc = nil
                end
            end
            local npcCoords = GetEntityCoords(npc)
            local distance = #(GetEntityCoords(PlayerPedId()) - npcCoords)
            if distance < 3.0 and not robbing then
                isNearNPC = true
                npcEntity = npc
                Draw3DText(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "Rob [E]")
                if IsControlJustPressed(1, 38) then
                    robbing = true
                    TriggerEvent('lootnpc:robNPC', npcEntity, dead)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4000)
        peds = GetAllPeds()
    end
end)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end


RegisterNetEvent('lootnpc:robNPC')
AddEventHandler('lootnpc:robNPC', function(npcEntity, dead)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local npcCoords = GetEntityCoords(npcEntity)

    if not dead then
        TaskTurnPedToFaceEntity(npcEntity, playerPed, 1000)
    end
    TaskTurnPedToFaceEntity(playerPed, npcEntity, 1000)
    Citizen.Wait(1000)

    if not dead then
        local weaponHash = GetSelectedPedWeapon(playerPed)
        if weaponHash == GetHashKey('WEAPON_UNARMED') then
            Config.Notify(Config.NotifyText['NoWeapon'])
            return
        end

        ClearPedTasksImmediately(npcEntity)
        SetBlockingOfNonTemporaryEvents(npcEntity, true)
        TaskStandStill(npcEntity, -1)

        RequestAnimDict("random@mugging3")
        while not HasAnimDictLoaded("random@mugging3") do
            Citizen.Wait(100)
        end
        TaskPlayAnim(npcEntity, "random@mugging3", "handsup_standing_base", 8.0, -8.0, -1, 49, 0, 0, 0, 0)

        TaskAimGunAtEntity(playerPed, npcEntity, -1, true)

        Citizen.Wait(2000) -- Wait for animation effect

        local dict = "mp_common"
        local anim = "givetake1_a"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(100)
        end

        TaskPlayAnim(npcEntity, dict, anim, 8.0, -8.0, -1, 48, 0, 0, 0, 0)

        local moneyModel = GetHashKey("prop_cash_pile_02")
        RequestModel(moneyModel)
        while not HasModelLoaded(moneyModel) do
            Citizen.Wait(100)
        end
        local moneyProp = CreateObject(moneyModel, 0, 0, 0, true, true, true)
        AttachEntityToEntity(moneyProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

        Citizen.Wait(3000) 

        DeleteObject(moneyProp)
        ClearPedTasksImmediately(npcEntity)
        ClearPedTasks(playerPed)

        TaskGoStraightToCoord(npcEntity, npcCoords.x + math.random(-10, 10), npcCoords.y + math.random(-100, 100), npcCoords.z, 5.0, -1, 0.0, 0.0)
        SetPedAsNoLongerNeeded(npcEntity)
        TriggerServerEvent('lootnpc:giveMoney', NetworkGetNetworkIdFromEntity(npcEntity))
    else
        TaskTurnPedToFaceEntity(playerPed, npcEntity, 1000)
        Citizen.Wait(1000)

        RequestAnimDict("amb@medic@standing@kneel@base")
        while not HasAnimDictLoaded("amb@medic@standing@kneel@base") do
            Citizen.Wait(100)
        end
        RequestAnimDict("anim@gangops@facility@servers@bodysearch@")
        while not HasAnimDictLoaded("anim@gangops@facility@servers@bodysearch@") do
            Citizen.Wait(100)
        end
        TaskPlayAnim(playerPed, "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
        TaskPlayAnim(playerPed, "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )

        Citizen.Wait(5000) 

        ClearPedTasks(playerPed)
        TriggerServerEvent('lootnpc:giveMoney', NetworkGetNetworkIdFromEntity(npcEntity))
    end
end)
