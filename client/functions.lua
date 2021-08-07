local ui = false
function SetDisplay(bool)
    ui = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = 'menu',
        ui = bool
    })
end

function AddCar(plate, model)
    SendNUIMessage({
        type = 'add',
        plate = plate,
        model = model
    }) 
end

function ShowHelpNotification(string)
    SetTextComponentFormat("STRING")
	AddTextComponentString(string)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

