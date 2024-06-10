local Permissions = {
    cache = {},
    config = Config.Permissions,
    timer = {}
}

local Main = {
    prepares = {}
}

function Main:Prepare(index, execute)
    self.prepares[index] = execute
end

function Main:Query(index, params)
    local wait = promise.new()
    local command = self.prepares[index]
    if not command then
        wait:resolve({ })
        return Citizen.Await(wait)
    end
    exports["oxmysql"]:execute(command, (params or {}), function(result)
        wait:resolve(result)
    end)
    return Citizen.Await(wait)
end

Main:Prepare('Get', 'SELECT * FROM `player_permissions` WHERE citizenid = @userId')
Main:Prepare('GetAll', 'SELECT citizenid, hierarchy FROM `player_permissions` WHERE `index` = @index')
Main:Prepare('Add', 'INSERT INTO `player_permissions` (citizenid, `index`, hierarchy) VALUES (@userId, @index, @hierarchy)')
Main:Prepare('Remove', 'DELETE FROM `player_permissions` WHERE citizenid = @userId AND `index` = @index')
Main:Prepare('Update', 'UPDATE `player_permissions` SET hierarchy = @hierarchy WHERE citizenid = @userId AND `index` = @index')

function Permissions:Add(userId, index, hierarchy)
    local source = Functions.getUserSource(userId)
    local permissions = self:Get(userId)

    if not permissions[index] then
        Main:Query('Add', {
            userId = userId,
            index = index,
            hierarchy = hierarchy
        })
    else
        self:Update(userId, index, hierarchy)
    end

    permissions[index] = { 
        hierarchy = tonumber(hierarchy),
        status = true, 
        salary = (tonumber(hierarchy) and ((self.config[index] or {}).salarys or {})[tostring(hierarchy)] or false)
    }
    
    if source then
        lib.addPrincipal('player.'..source, 'group.'..index)
        TriggerClientEvent('zhawty-permissions:update', source, permissions)
    end
end

function Permissions:Remove(userId, index)
    local source = Functions.getUserSource(userId)
    local permissions = self:Get(userId)
    permissions[index] = nil

    Main:Query('Remove', {
        userId = userId,
        index = index
    })

    if source then
        lib.removePrincipal('player.'..source, 'group.'..index)
        TriggerClientEvent('zhawty-permissions:update', source, permissions)
    end
end

function Permissions:Update(userId, index, hierarchy)
    local source = Functions.getUserSource(userId)
    local permissions = self:Get(userId)

    if permissions[index] then 
        Main:Query('Update', {
            userId = userId,
            index = index,
            hierarchy = hierarchy
        })
        permissions[index].hierarchy = hierarchy
        permissions[index].salary = (tonumber(hierarchy) and ((self.config[index] or {}).salarys or {})[tostring(hierarchy)] or false)
    end

    if source then
        TriggerClientEvent('zhawty-permissions:update', source, permissions)
    end
end

function Permissions:Get(userId, index)
    if not self.cache[tostring(userId)] then
        local source = Functions.getUserSource(userId)
        local rows = Main:Query('Get', {
            userId = userId
        })

        self.cache[tostring(userId)] = {}

        for _, v in pairs(rows) do
            self.cache[tostring(userId)][v.index] =  { 
                hierarchy = tonumber(v.hierarchy),
                status = true, 
                salary = (tonumber(v.hierarchy) and ((self.config[v.index] or {}).salarys or {})[tostring(v.hierarchy)] or false)
            }

            if source then
                lib.addPrincipal('player.'..source, 'group.'..v.index) 
            end
        end
        if source then
            TriggerClientEvent('zhawty-permissions:update', source, self.cache[tostring(userId)])
        end
    end
    return index and self.cache[tostring(userId)][index] or self.cache[tostring(userId)]
end

function Permissions:Reload(userId)
    local source = Functions.getUserSource(userId)

    self.cache[tostring(userId)] = nil 
    self:Get(userId)

    if source then
        TriggerClientEvent('zhawty-permissions:update', source, self.cache[tostring(userId)])
    end
end

function Permissions:Has(userId, index, hierarchy)
    local source = Functions.getUserSource(userId)
    local permission = self:Get(userId, index)
    local hasPermission = permission and ((permission.hierarchy or -1) >= (hierarchy or 0)) 
    local hasParent = false
    if self.config[index] then 
        local parents = self.config[index].parents or {}
        for indexParent in pairs(parents) do 
            if self:Get(userId, index) then
                hasParent = true
                break
            end
        end
    end
    return hasPermission or hasParent or (source and IsPlayerAceAllowed(source, index))
end

function Permissions:Payday(source)
    local userId = Functions.getUserId(source)
    local permissions = self:Get(userId)

    if self.timer[tostring(userId)] then 
        if os.time() < self.timer[tostring(userId)] then TriggerEvent('zhawty-permission:suspectPlayer', source, locale('executing_event')) return end
    end

    self.timer[tostring(userId)] = (os.time() + ((Config.Payday.Timer or 10) * 60))

    for index, v in pairs(permissions) do 
        if v.salary then 
            Functions.giveMoney(userId, v.salary, 'payday '..index)
            TriggerClientEvent('zhawty-permissions:notify', source, locale('notify_title'), locale('recive_payday', v.salary), 'info')
            TriggerEvent('zhawty-permissions:reciveSalary', userId, index, v.salary)
        end
    end 
end

RegisterNetEvent('zhawty-permissions:payday', function()
    local source = source
    Permissions:Payday(source)
end)

SetTimeout(0, function()
    lib.locale()
end)

lib.callback.register('zhawty-permissions:getPermissionsConfig', function(source)
    return Permissions.config
end)

lib.callback.register('zhawty-permissions:getUserPermissions', function(source, userId)
    if not Config.Commands.manageUser.canExecute(source) then return {} end
    local permissions = Permissions:Get(userId) or {}
    return permissions
end)

lib.callback.register('zhawty-permissions:getUsersByPermission', function(source, index)
    if not Config.Commands.panel.canExecute(source) then return {} end
    local users = Main:Query('GetAll', {
        index = index or 'null'
    })
    local formated = {}
    for _, user in pairs(users) do 
        local isOnline = Functions.getUserSource(user.citizenid)
        formated[#formated + 1] = {
            citizenid = user.citizenid,
            status = isOnline,
            text = (isOnline and '🟢 Source: '..isOnline or '🔴 Source: offline')..' | Id: '..user.citizenid..' | Level: '..user.hierarchy
        }
    end
    return formated
end)

RegisterNetEvent('zhawty-permissions:remove', function(data)
    local source = source 
    local staffId = Functions.getUserId(source)

    if not staffId then return end
    if not Config.Commands.remPermission.canExecute(source) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    local userId, index = data.userId, data.index
    if not (userId or index) then return end

    if not Functions.canRemovePermission(staffId, userId, index) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    Permissions:Remove(userId, index)
    TriggerClientEvent('zhawty-permissions:notify', source, 'Sucess', locale('removed'), 'info')
end)

RegisterNetEvent('zhawty-permissions:reload', function(data)
    local source = source 
    local staffId = Functions.getUserId(source)

    if not staffId then return end
    if not Config.Commands.panel.canExecute(source) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    local userId = data.userId
    if not (userId) then return end

    Permissions:Reload(userId)
    TriggerClientEvent('zhawty-permissions:notify', source, 'Sucess', locale('reloaded'), 'info')
end)

RegisterNetEvent('zhawty-permissions:change', function(userId, index, newLevel)
    local source = source
    local staffId = Functions.getUserId(source)

    if not staffId then return end
    if not Config.Commands.addPermission.canExecute(source) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    if not (userId or index or newLevel) then return end

    if not Functions.canChangeLevel(staffId, userId, index) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    Permissions:Update(userId, index, newLevel)
    TriggerClientEvent('zhawty-permissions:notify', source, 'Sucess', locale('changed'), 'info')
end)

RegisterNetEvent('zhawty-permissions:add', function(userId, index, level)
    local source = source
    local staffId = Functions.getUserId(source)

    if not staffId then return end
    if not Config.Commands.addPermission.canExecute(source) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    if not (userId or index or level) then return end

    if not Functions.canAddPermission(staffId, userId, index) then TriggerClientEvent('zhawty-permissions:notify', source, 'Error', locale('cant_execute'), 'error') return end

    Permissions:Add(userId, index, level)
    TriggerClientEvent('zhawty-permissions:notify', source, 'Sucess', locale('added'), 'info')
end)

RegisterCommand('teste', function(source)
    local userId = Functions.getUserId(source)
    Permissions:Add(userId, 'teste', 0)
    Wait(1000)
    Permissions:Payday(source)
end)

if Config.Commands.panel then
    RegisterCommand(Config.Commands.panel.name, function(source)
        if not Config.Commands.panel.canExecute(source) then return end
        TriggerClientEvent('zhawty-permissions:openPanel', source)
    end)
end

if Config.Commands.addPermission then
    RegisterCommand(Config.Commands.addPermission.name, function(source)
        if not Config.Commands.addPermission.canExecute(source) then return end
        TriggerClientEvent('zhawty-permissions:openPanel', source, 'addPermission')
    end)
end

if Config.Commands.remPermission then
    RegisterCommand(Config.Commands.remPermission.name, function(source)
        if not Config.Commands.remPermission.canExecute(source) then return end
        TriggerClientEvent('zhawty-permissions:openPanel', source, 'remPermission')
    end)
end

if Config.Commands.manageUser then
    RegisterCommand(Config.Commands.manageUser.name, function(source, args)
        local userId = tonumber(args[1])
        if not Config.Commands.manageUser.canExecute(source) then return end
        TriggerClientEvent('zhawty-permissions:openPanel', source, 'manageUser', userId)
    end)
end

exports('Has', function(userId, index, hierarchy)
    return Permissions:Has(userId, index, hierarchy)
end)