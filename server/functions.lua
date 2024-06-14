Functions = {}

--[[
    Lista de exports disponiveis:

    ---@param userId number
    ---@param index string
    ---@param hierarchy? number
    ---@return boolean
    exports['zhawty-permission']:Has(userId, index, hierarchy)

    ---@param userId number
    ---@param index? string
    ---@return table
    exports['zhawty-permission']:Get(userId, index)

    ---@param userId number
    ---@param index string
    ---@param hierarchy? number
    ---@return boolean
    exports['zhawty-permission']:Add(userId, index, hiearchy)

    ---@param userId number
    ---@param index string 
    ---@return boolean
    exports['zhawty-permission']:Remove(userId, index)

    ---@param userId number
    ---@param index string 
    ---@param hierarchy number
    ---@return boolean
    exports['zhawty-permission']:Update(userId, index, hierarchy)
]]

local Core = exports.qbx_core

---@param source number
---@return number
function Functions.getUserId(source)
    local player = Core:GetPlayer(source)
    if not player then return end
    return player.PlayerData.citizenid
end

---@param userId string | number
---@param amount amount
---@param reason string
---@return boolean
function Functions.giveMoney(userId, amount, reason)
    local player = Core:GetPlayerByCitizenId(userId)
    if not player then return end
    player.Functions.AddMoney('bank', amount, reason)
    return true
end

---@param userId string | number
---@return string | nil
function Functions.getUserJob(userId)
    local player = Core:GetPlayerByCitizenId(userId)
    if not player then return end
    local jobData = player.PlayerData.job
    return jobData.onduty and jobData.name or false
end

---@param userId string | number
---@return number | nil
function Functions.getUserSource(userId)
    local player = Core:GetPlayerByCitizenId(userId)
    if not player then return end
    return player.PlayerData.source
end

---@param staffId number
---@param userId number
---@param index string
---@return boolean
function Functions.canRemovePermission(staffId, userId, index)
    return true
end

---@param staffId number
---@param userId number
---@param index string
---@param newLevel number
---@return boolean
function Functions.canChangeLevel(staffId, userId, index, newLevel)
    return true
end

---@param staffId number
---@param userId number
---@param index string
---@param level number
---@return boolean
function Functions.canAddPermission(staffId, userId, index, level)
    return true
end

AddEventHandler('zhawty-permissions:reciveSalary', function(userId, index, amount)
    lib.print.info(userId, index, amount)
end)

AddEventHandler('zhawty-permission:suspectPlayer', function(source, reason)
    lib.print.warn(reason, source)
end)