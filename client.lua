ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        if Config.ESX == 'old' then
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        elseif Config.ESX == 'new' then
            ESX = exports["es_extended"]:getSharedObject()
        else
            print('Wrong ESX Type!')
        end
    end
end)

RegisterNetEvent('nkhd_changePlate:receivePlateSwitcherData')
AddEventHandler('nkhd_changePlate:receivePlateSwitcherData', function(data)

    for _, row in ipairs(data) do
        identifiern = row.identifier
        platen = row.plate
        modeln = row.model

    end
end)

local identifiert = {}

RegisterNetEvent('nkhd_changePlate:receiveIdentifier')
AddEventHandler('nkhd_changePlate:receiveIdentifier', function(identifier)
    identifiert = identifier
end)

local taped = false

RegisterNetEvent('nkhd_changePlate:applyTape')
AddEventHandler('nkhd_changePlate:applyTape', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        local lastVehicle = GetVehiclePedIsIn(playerPed, true)
        
        if lastVehicle and IsVehicleStopped(lastVehicle) then
            local playerCoords = GetEntityCoords(playerPed)
            local vehicleCoords = GetEntityCoords(lastVehicle)

            if #(playerCoords - vehicleCoords) < 3.0 then
                local vehiclesave = GetEntityModel(lastVehicle)
                local plate = GetVehicleNumberPlateText(lastVehicle)
                taped = true
                TriggerServerEvent('nkhd_changePlate:savePlateData', source, plate, vehiclesave)
                SetVehicleNumberPlateText(lastVehicle, " ") -- If you want to change the Numberplate, you can set it here
                makePlateInvisible(lastVehicle)
                TriggerServerEvent('nkhd_changePlate:removeTapeItem')

                playAnimation()  -- Starts the Animation and the ProgressBar

            else
                ESX.ShowNotification(_U('closer')) 
            end
        else
            ESX.ShowNotification(_U('noveh')) 
        end
    else
        ESX.ShowNotification(_U('outofveh')) 
    end
end)

RegisterNetEvent('nkhd_changePlate:removeTape')
AddEventHandler('nkhd_changePlate:removeTape', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, true)
    local lastVehicle = GetVehiclePedIsIn(playerPed, true)

    if vehicle then
        local playerCoords = GetEntityCoords(playerPed)
        local vehicleCoords = GetEntityCoords(vehicle)

        if taped == true then
            if #(playerCoords - vehicleCoords) < 3.0 then
                if identifiert == identifiern then
                    SetVehicleNumberPlateText(lastVehicle, platen)
                    SetVehicleNumberPlateTextIndex(vehicle, 0) -- Set here your Numberplate ID, which you want to have, when it got scraped off
                    playAnimationab(false)
                    taped = false
                    local platenn = platen
                    local modelnn = modeln
                    TriggerServerEvent('nkhd_changePlate:deletePlateData', platenn, modelnn)
                else
                    ESX.ShowNotification(_U('noveh'))
                end 
                else
             ESX.ShowNotification(_U('closer'))
            end
        else
            ESX.ShowNotification(_U('noveh'))
        end 
    else
        ESX.ShowNotification(_U('noveh'))
    end 
end)


function makePlateInvisible(vehicle)
    SetVehicleNumberPlateTextIndex(vehicle, 5) -- Set here your Numberplate ID
end

function playAnimation()
    local playerPed = PlayerPedId()
    local animDict = "mini@repair" -- Edit your Animation here
    local animName = "fixing_a_ped"
    local duration = 5000 -- Duration of the Animation, Currently 5 Seconds

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

    exports['progressBars']:startUI(duration, _U('applying')) -- If you want to use your own ProgressBar, and your own Translation

    Citizen.Wait(duration)
    ClearPedTasks(playerPed)
end

function playAnimationab()
    local playerPed = PlayerPedId()
    local animDict = "mini@repair" -- Edit your Animation here
    local animName = "fixing_a_ped"
    local duration = 5000 -- Duration of the Animation, Currently 5 Seconds

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

    exports['progressBars']:startUI(duration, _U('scraping_off')) -- If you want to use your own ProgressBar

    Citizen.Wait(duration)
    ClearPedTasks(playerPed)
end

function IsVehicleWithUndercoverPlate(vehicle)
    if originalPlates[vehicle] then
        return true
    else
        return false
    end
end

while true do
    TriggerServerEvent('nkhd_changePlate:getIdentifier')
    TriggerServerEvent('nkhd_changePlate:getPlateData')
    Citizen.Wait(100)
end

exports('IsVehicleWithUndercoverPlate', IsVehicleWithUndercoverPlate)
