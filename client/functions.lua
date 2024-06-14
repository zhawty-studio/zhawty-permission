Functions = {}

---@param title string | nil
---@param description string | nil  
---@param type string | nil
function Functions.notify(title, description, type)
    lib.notify({
        -- title = title,
        description = description,
        type = type
    })
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('zhawty-permissions:loadPlayer')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('zhawty-permissions:unloadPlayer')
end) 

CreateThread(function()
    if not LocalPlayer.state['isLoggedIn'] then return end
    TriggerEvent('zhawty-permissions:loadPlayer')
end)