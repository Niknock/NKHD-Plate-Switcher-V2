ESX = nil

if Config.ESX == 'old' then
     TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.ESX == 'new' then
    ESX = exports["es_extended"]:getSharedObject()
else
    print('Wrong ESX Type!')
end

ESX.RegisterUsableItem('tape', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('nkhd_changePlate:applyTape', source)
end)

ESX.RegisterUsableItem('tape_remover', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('nkhd_changePlate:removeTape', source)
end)

RegisterServerEvent('nkhd_changePlate:removeTapeItem')
AddEventHandler('nkhd_changePlate:removeTapeItem', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        xPlayer.removeInventoryItem('tape', 1)
    else
        if Config.Debug == true then
            print("Error: Player not found - player ID: " .. _source)
        end
    end
end)

RegisterServerEvent('nkhd_changePlate:getIdentifier')
AddEventHandler('nkhd_changePlate:getIdentifier', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier
    TriggerClientEvent('nkhd_changePlate:receiveIdentifier', _source, identifier)
end)

local oxmysql = exports.oxmysql

RegisterServerEvent('nkhd_changePlate:savePlateData')
AddEventHandler('nkhd_changePlate:savePlateData', function(identifier, plate, model)
    local _source = source
    local xTarget = nil

    if xTarget == nil then
        xTarget = ESX.GetPlayerFromId(_source)
    end

    if oxmysql then
        MySQL.insert('INSERT INTO plateswitcher (identifier, plate, model) VALUES (?, ?, ?)', {xTarget.identifier, plate, model}
        )          
    end
end)

RegisterServerEvent('nkhd_changePlate:deletePlateData')
AddEventHandler('nkhd_changePlate:deletePlateData', function(platenn, modelnn)
    local _source = source
    local xTarget = ESX.GetPlayerFromId(_source)
    local plate = platenn
    local model = modelnn

    if oxmysql then
        MySQL.Async.execute(
            'DELETE FROM plateswitcher WHERE identifier = @identifier AND plate = @plate AND model = @model',
            {
                ['@identifier'] = xTarget.identifier,
                ['@plate'] = plate,
                ['@model'] = model
            },
            function(rowsChanged)
                if Config.Debug == true then
                    print('Deleted rows: ' .. rowsChanged)
                end
            end
        )
    end
end)


RegisterServerEvent('nkhd_changePlate:getPlateData')
AddEventHandler('nkhd_changePlate:getPlateData', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT identifier, plate, model FROM plateswitcher", {}, function(result)

        TriggerClientEvent('nkhd_changePlate:receivePlateSwitcherData', source, result)
    end)
end)
