ESX = nil
local PlayerData = {}
local usedGarage
-- ESX
Citizen.CreateThread(function()
    while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(0) end
    while ESX.GetPlayerData().job == nil do Citizen.Wait(0) end
    PlayerData = ESX.GetPlayerData()
end)
-- Create Blips
Citizen.CreateThread(function()
    if DLRMS.ShowBlips then 
            for k,v in pairs(DLRMS.Garages) do
            local blip = AddBlipForCoord(v.x, v.y)
            SetBlipSprite(blip, v.sprite)
            SetBlipScale(blip, v.scale)
            SetBlipColour(blip, v.colour)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.text)
            EndTextCommandSetBlipName(blip)
        end
    end
end)
-- Create PED
Citizen.CreateThread(function()
    for k,v in pairs(DLRMS.Garages) do
        RequestModel(0x3B96F23E)
        while not HasModelLoaded(0x3B96F23E) do
            Citizen.Wait(1)
        end
        local ped = CreatePed(4, 0x3B96F23E, v.x, v.y, v.z - 1, v.h, false, true)
        SetEntityHeading(ped, v.h)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end
end)
-- isPlayerNearGarage
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        for k,v in pairs(DLRMS.Garages) do
            local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.x, v.y, v.z, false)
            if distance <= 1.0 then
                sleep = 65
                ShowHelpNotification('Garaja erişmek için ~INPUT_PICKUP~ tuşuna basın!')
                if IsControlPressed(0, DLRMS.AccessKey) then
                    ui = not ui
                    usedGarage = k
                    SetDisplay(true)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
-- Close NUI
RegisterNUICallback('dlrms_garage:close', function()
    SetDisplay(false)
end)
-- Take the car menu
RegisterNUICallback('dlrms_garage:takeTheCar', function(data, cb)
    ESX.TriggerServerCallback('dlrms_garage:loadVehicles', function(ownedCars)
        if #ownedCars == 0 then
            ESX.ShowNotification("Garajda hiç aracınız yok")
        else
            for k,v in pairs(ownedCars) do
                local hashModel = v.vehicle.model
                local aheadVehicleName = GetDisplayNameFromVehicleModel(hashModel)
                local vehicleName = GetLabelText(aheadVehicleName)
                local plate = v.plate
                AddCar(plate, vehicleName)
            end
        end
    end)
    cb('ok')
end)
-- Park the car menu
RegisterNUICallback('dlrms_garage:parkTheCar', function(data, cb)
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(-1)), 25.0)
    for k,v in pairs(vehicles) do
        ESX.TriggerServerCallback('dlrms_garage:isOwned', function(owned)
			if owned then
                AddCar(GetVehicleNumberPlateText(v), GetDisplayNameFromVehicleModel(GetEntityModel(v)))
            end
        end, GetVehicleNumberPlateText(v))
    end
    cb('ok')
end)
-- Take car
RegisterNUICallback('dlrms_garage:takeCar', function(data, cb)
    ESX.TriggerServerCallback('dlrms_garage:loadVehicle', function(vehicle)
        local spawnX = DLRMS.Garages[usedGarage].spawnX
        local spawnY = DLRMS.Garages[usedGarage].spawnY
        local spawnZ = DLRMS.Garages[usedGarage].spawnZ
        local spawnH = DLRMS.Garages[usedGarage].spawnH
        local props = json.decode(vehicle[1].vehicle)
        ESX.Game.SpawnVehicle(props.model, {
            x = spawnX,
            y = spawnY,
            z = spawnZ + 1
        }, spawnH, function(callback_vehicle)
            ESX.Game.SetVehicleProperties(callback_vehicle, props)
            SetVehRadioStation(callback_vehicle, "OFF")
            ESX.ShowNotification("Aracınız hazır")
            -- TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
        end)
    end, data.plate)
    TriggerServerEvent('dlrms_garage:changeState', data.plate, 0)
    cb('ok')
end)
-- Park car
RegisterNUICallback('dlrms_garage:parkCar', function(data, cb)
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(-1)), 25.0)
    for k,v in pairs(vehicles) do
        if GetVehicleNumberPlateText(v) == data.plate then
            TriggerServerEvent('dlrms_garage:saveProps', data.plate, ESX.Game.GetVehicleProperties(v))
            TriggerServerEvent('dlrms_garage:changeState', data.plate, 1)
            ESX.ShowNotification("Aracınız garaja koyuldu")
            ESX.Game.DeleteVehicle(v)
        end
    end
    cb('ok')
end)