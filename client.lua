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

-- Ox Stuff

local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetEntityBonePosition_2 = GetEntityBonePosition_2
local GetVehicleDoorLockStatus = GetVehicleDoorLockStatus

local bones = {
    [0] = 'dside_f',
    [1] = 'pside_f',
    [2] = 'dside_r',
    [3] = 'pside_r'
}

---@param vehicle number
---@param door number
local function toggleDoor(vehicle, door)
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then
        if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
            SetVehicleDoorShut(vehicle, door, false)
        else
            SetVehicleDoorOpen(vehicle, door, false, false)
        end
    end
end

---@param entity number
---@param coords vector3
---@param door number
---@param useOffset boolean?
---@return boolean?
local function canInteractWithDoor(entity, coords, door, useOffset)
    if not GetIsDoorValid(entity, door) or GetVehicleDoorLockStatus(entity) > 1 or IsVehicleDoorDamaged(entity, door) then return end

    if useOffset then return true end

    local boneName = bones[door]

    if not boneName then return false end

    boneId = GetEntityBoneIndexByName(entity, 'door_' .. boneName)

    if boneId ~= -1 then
        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 0.5 or
            #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_' .. boneName))) < 0.72
    end
end

local function onSelectDoor(data, door)
    local entity = data.entity

    if NetworkGetEntityOwner(entity) == cache.playerId then
        return toggleDoor(entity, door)
    end

    TriggerServerEvent('ox_target:toggleEntityDoor', VehToNet(entity), door)
end

RegisterNetEvent('ox_target:toggleEntityDoor', function(netId, door)
    local entity = NetToVeh(netId)
    toggleDoor(entity, door)
end)

if Config.OxTarget then
    exports.ox_target:addGlobalVehicle({
    {
        name = 'nkhd_changePlate:apply',
        icon = 'fa-solid fa-car-rear',
        label = 'Apply Tape',                               -- Change to your Speech
        offset = vec3(0.5, 0, 0.5),
        distance = 2,
        canInteract = function(entity, distance, coords, name)
            return canInteractWithDoor(entity, coords, 5, true)
        end,
        onSelect = function(data)
            TriggerEvent('nkhd_changePlate:applyTape', source)
        end
    },
    {
        name = 'nkhd_changePlate:remove',
        icon = 'fa-solid fa-car-rear',
        label = 'Remove Tape',                               -- Change to your Speech
        offset = vec3(0.5, 0, 0.5),
        distance = 2,
        canInteract = function(entity, distance, coords, name)
            return canInteractWithDoor(entity, coords, 5, true)
        end,
        onSelect = function(data)
            TriggerEvent('nkhd_changePlate:removeTape', source)
        end
    }
    })
end


-- Main

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
