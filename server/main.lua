local Permissions = {
    cache = {},
    config = {},
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

Main:Prepare('Permissions:GetConfig', 'SELECT * FROM zhawty_permissions')
function Permissions:LoadConfig()
    self.config = {}
    local rows = Main:Query('Permissions:GetConfig')
    for k, v in pairs(rows) do 
        self.config[v.index] = {
            salarys = json.decode(v.salarys) or {},
            parents = json.decode(v.parents) or {}
        }
    end
    lib.print.info('Permissions loaded:', #rows)
end

function Permissions:Add(userId, index, hierarchy)
    local source = Functions.getUserSource(userId)
    local permissions = self:Get(userId)
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
    if source then
        lib.removePrincipal('player.'..source, 'group.'..index)
        TriggerClientEvent('zhawty-permissions:update', source, permissions)
    end
end

function Permissions:Update(userId, index, hierarchy)
    local source = Functions.getUserSource(userId)
    local permissions = self:Get(userId)

    if permissions[index] then 
        permissions[index].hierarchy = hierarchy
        permissions[index].salary = (tonumber(hierarchy) and ((self.config[index] or {}).salarys or {})[tostring(hierarchy)] or false)
    end

    if source then
        TriggerClientEvent('zhawty-permissions:update', source, permissions)
    end
end

function Permissions:Get(userId, index)
    if not self.cache[tostring(userId)] then
        self.cache[tostring(userId)] = {}
    end
    return index and self.cache[tostring(userId)][index] or self.cache[tostring(userId)]
end

function Permissions:Reload(userId)
    local source = Functions.getUserSource(userId)
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
    Permissions:LoadConfig()  
end)

lib.callback.register('zhawty-permissions:getPermissionsConfig', function(source)
    return Permissions.config
end)

RegisterCommand('teste', function(source)
    local userId = Functions.getUserId(source)
    Permissions:Add(userId, 'teste', 0)
    Wait(1000)
    Permissions:Payday(source)
end)

RegisterCommand(Config.Commands.panel.name, function(source)
    if not Config.Commands.panel.canExecute(source) then return end
    TriggerClientEvent('zhawty-permissions:openPanel', source)
end)

exports('Has', function(userId, index, hierarchy)
    return Permissions:Has(userId, index, hierarchy)
end)