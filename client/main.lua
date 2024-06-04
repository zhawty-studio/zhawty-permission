RegisterNUICallback("exampleData", function(data, callback)
    local exampleData = "random data sent by back-end to front-end"

    callback(exampleData)
end)

RegisterCommand("openUI", function()
    SendNUIMessage({action = "setVisible", data = true})

    SetNuiFocus(true, true)
end, false)

RegisterCommand("closeUI", function()
    SendNUIMessage({action = "setVisible", data = false})

    SetNuiFocus(false, false)
end, false)

RegisterNUICallback("hideFrame", function()
    SendNUIMessage({action = "setVisible", data = false})
    SetNuiFocus(false, false)
end)
