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
            print("Error: Player not found - player ID: " .. _source) -- Debug
        end
    end
end)

RegisterServerEvent('nkhd_changePlate:iden')
AddEventHandler('nkhd_changePlate:iden', function(identifier)
    local _source = source
    local xTarget = ESX.GetPlayerFromId(_source)

    identifiernn = xTarget.identifier

    TriggerClientEvent('nkhd_changePlate:returniden', source, identifiernn)
end)


local oxmysql = exports.oxmysql

RegisterServerEvent('nkhd_changePlate:savePlateData')
AddEventHandler('nkhd_changePlate:savePlateData', function(identifier, plate, model)
    local _source = source
    local xTarget = ESX.GetPlayerFromId(_source)

    if oxmysql then
        MySQL.insert('INSERT INTO plateswitcher (identifier, plate, model) VALUES (?, ?, ?)', {xTarget.identifier, plate, model}
        )          
    else
        print("Fehler: oxmysql ist nil oder nicht initialisiert.")
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