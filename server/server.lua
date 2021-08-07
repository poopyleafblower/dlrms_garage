ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('dlrms_garage:loadVehicles', function(source, cb)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	local ownedCars = {}
	MySQL.Async.fetchAll('SELECT * FROM `owned_vehicles` WHERE `owner` = @owner AND `stored` = 1', {
        ['@owner'] = x.identifier
    }, function(vehicles)
		for k,v in pairs(vehicles) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
		end
		cb(ownedCars)
	end)
end)

ESX.RegisterServerCallback('dlrms_garage:loadVehicle', function(source, cb, plate)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	MySQL.Async.fetchAll('SELECT * FROM `owned_vehicles` WHERE `plate` = @plate', {
        ['@plate'] = plate
    }, function(vehicle)
		cb(vehicle)
	end)
end)

ESX.RegisterServerCallback('dlrms_garage:isOwned', function(source, cb, plate)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	MySQL.Async.fetchAll('SELECT `vehicle` FROM `owned_vehicles` WHERE `plate` = @plate AND `owner` = @owner', {
        ['@plate'] = plate, 
		['@owner'] = x.identifier
    }, function(vehicle)
		if next(vehicle) then
			cb(true)
		else
			cb(false)
		end
	end)
end)

RegisterNetEvent('dlrms_garage:changeState')
AddEventHandler('dlrms_garage:changeState', function(plate, state)
	MySQL.Sync.execute("UPDATE `owned_vehicles` SET `stored` = @state WHERE `plate` = @plate", {
        ['@state'] = state, ['@plate'] = plate
    })
end)

RegisterNetEvent('dlrms_garage:saveProps')
AddEventHandler('dlrms_garage:saveProps', function(plate, props)
	local xProps = json.encode(props)
	MySQL.Sync.execute("UPDATE `owned_vehicles` SET `vehicle` = @props WHERE `plate` = @plate", {
        ['@plate'] = plate, ['@props'] = xProps
    })
end)

MySQL.ready(function()
	MySQL.Async.execute('UPDATE `owned_vehicles` SET `stored` = true WHERE `stored` = @stored', {
		['@stored'] = false
	}, function(rowsChanged)
		if rowsChanged > 0 then
			print(('dlrms_garage: %s vehicle(s) have been stored!'):format(rowsChanged))
		end
	end)
end)