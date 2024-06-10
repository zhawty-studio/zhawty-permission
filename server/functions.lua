Functions = {}

local Core = exports.qbx_core

function Functions.getUserId(source)
    local player = Core:GetPlayer(source)
    if not player then return end
    return player.PlayerData.citizenid
end

function Functions.giveMoney(userId, amount, reason)
    local player = Core:GetPlayerByCitizenId(userId)
    if not player then return end
    player.Functions.AddMoney('bank', amount, reason)
end

function Functions.getUserJob(userId)
    local player = Core:GetPlayerByCitizenId(userId)
    if not player then return end
    local jobData = player.PlayerData.job
    return jobData.onduty and jobData.name or false
end

function Functions.getUserSource(userId)
    local player = Core:GetPlayerByCitizenId(userId)
    if not player then return end
    return player.PlayerData.source
end

function Functions.canRemovePermission(staffId, userId, index)
    return true
end

function Functions.canChangeLevel(staffId, userId, index, newLevel)
    return true
end

function Functions.canAddPermission(staffId, userId, index, level)
    return true
end

AddEventHandler('zhawty-permissions:reciveSalary', function(userId, index, amount)
    lib.print.info(userId, index, amount)
end)

AddEventHandler('zhawty-permission:suspectPlayer', function(source, reason)
    lib.print.warn(reason, source)
end)