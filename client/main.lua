local User = {
    permissions = {}
}

function User:Load()
    if self.status then return end
    self.status = true
    CreateThread(function()
        while self.status do 
            Wait((Config.PaydayTimer or 10) * 60 * 1000)
            TriggerServerEvent('zhawty-permissions:payday')
        end
    end)
end

function User:Unload()
    self.status = false
end

AddEventHandler('zhawty-permissions:loadPlayer', function()
    lib.locale()
    User:Load()
end)

AddEventHandler('zhawty-permissions:unloadPlayer', function()
    User:Unload()
end)

RegisterNetEvent('zhawty-permissions:notify', function(title, description, type)
    Functions.notify(title, description, type)
end)

RegisterNetEvent('zhawty-permissions:update', function(data)
    User.permissions = data
end)

function User:ManageUser(userId)
    local id = 'manage_user_'..userId
    local permissions = lib.callback.await('zhawty-permissions:getUserPermissions', 100, userId)
    local permissionsOptions = {}
    
    for index, v in pairs(permissions) do 
        permissionsOptions[#permissionsOptions + 1] = {
            title = index,
            arrow = true,
            onSelect = function()
                User:ManageMenu(index, userId, locale('ugroup_command_header')..': '..index, id..'_view')
            end
        }
    end

    local options = { 
        {
            title = locale('reload'),
            icon = 'arrows-rotate',
            serverEvent = 'zhawty-permissions:reload',
            args = { userId = userId }
        },
        {
            title = locale('remove_permission'),
            icon = 'trash',
            onSelect = function()
                User:RemovePermissionMenu(permissions, userId)
            end
        },
        {
            title = locale('add_permission'),
            icon = 'plus',
            onSelect = function()
                User:AddPermissionMenu(userId)
            end
        },
        {
            title = locale('view_permissions'),
            icon = 'eye',
            onSelect = function()
                lib.registerContext({
                    id = id..'_view',
                    title = locale('ugroup_command_header'), 
                    menu = id,
                    options = permissionsOptions
                })
                lib.showContext(id..'_view')
            end
        },
    }

    lib.registerContext({
        id = id,
        title = locale('ugroup_command_header')..' | '..locale('userId')..': '..userId, 
        options = options
    })
    lib.showContext(id)
end

function User:AddPermissionMenu(userId)
    local options = {
        permissions = {},
        levels = {},
        input = {}
    }

    for index in pairs(Config.Permissions) do
        options.permissions[#options.permissions + 1] = { 
            value = index
        }
    end

    options.input[#options.input + 1] = { type = 'select', label = locale('permission'), options = options.permissions, required = true, searchable = true, icon = 'user-edit' }
    if not userId then 
        options.input[#options.input + 1] = { type = 'number', label = locale('userId'), required = true, icon = 'hashtag' }
    end

    local results = (lib.inputDialog(locale('group_command_header'), options.input) or {}) 

    local index, userId = results[1], results[2] or userId
    if not (userId or index) then return end

    local configSalarys = (Config.Permissions[index] or {}).salarys or {}
    for level, salary in pairs(configSalarys) do 
        options.levels[#options.levels + 1] = { value = level, label = 'Level: '..level..' '..locale('salary')..' : '..locale('money_symbol')..salary }
    end

    local level = (lib.inputDialog(locale('change_hieararchy_header'), {
        { type = 'select', options = options.levels, required = true, searchable = true, icon = 'wallet' }
    }) or {})[1] 

    if not level then return end
    TriggerServerEvent('zhawty-permissions:add', userId, index, level)
end

function User:RemovePermissionMenu(userPermissions, userId)
    local options = {
        permissions = {},
        input = {}
    }
    
    for index in pairs(userPermissions or Config.Permissions) do
        options.permissions[#options.permissions + 1] = { 
            value = index
        }
    end

    options.input[#options.input + 1] = { type = 'select', label = locale('permission'), options = options.permissions, required = true, searchable = true, icon = 'user-edit' }
    if not userId then 
        options.input[#options.input + 1] = { type = 'number', label = locale('userId'), required = true, icon = 'hashtag' }
    end

    local results = (lib.inputDialog(locale('ungroup_command_header'), options.input) or {}) 

    local index, userId = results[1], results[2] or userId
    if not (userId or index) then return end

    TriggerServerEvent('zhawty-permissions:remove', {
        userId = userId, 
        index = index
    })
end

function User:ChangePermissionMenu(citizenid, index)
    local options = {}
    local configSalarys = (Config.Permissions[index] or {}).salarys or {}
    for level, salary in pairs(configSalarys) do 
        options[#options + 1] = { value = level, label = 'Level: '..level..' '..locale('salary')..' : '..locale('money_symbol')..salary }
    end

    local response = lib.inputDialog(locale('change_hieararchy_header'), {
        { type = 'select', options = options, required = true, searchable = true, icon = 'wallet' }
    }) 

    if not response then return end
    TriggerServerEvent('zhawty-permissions:change', citizenid, index, response[1])
end

function User:ManageMenu(index, citizenid, text, menu)
    lib.registerContext({
        id = 'permissions_'..index..'_user_manage',
        title = text,
        menu = menu or 'permissions_'..index..'_users',
        options = {
            {
                title = locale('change_permission'),
                icon = 'right-left',
                onSelect = function()
                    User:ChangePermissionMenu(citizenid, index)
                end
            },
            {
                title = locale('remove_permission'),    
                icon = 'trash',
                serverEvent = 'zhawty-permissions:remove',
                args = { userId = citizenid, index = index }
            },
            {
                title = locale('reload'),
                icon = 'plus',
                serverEvent = 'zhawty-permissions:reload',
                args = { userId = citizenid }
            }
        }
    })
    lib.showContext('permissions_'..index..'_user_manage')
end

function User:GetUsersByPermission(index)
    local users = lib.callback.await('zhawty-permissions:getUsersByPermission', 100, index)
    local options = {}
    
    table.sort(users, function(a, b) return (a.citizenid < b.citizenid) and b.status end)

    for i=1, #users do 
        local user = users[i]
        options[#options + 1] = {
            title = user.text,
            onSelect = function()
                User:ManageMenu(index, user.citizenid, user.text)
            end
        }
    end

    lib.registerContext({
        id = 'permissions_'..index..'_users',
        title = locale('menu_title')..': '..index,
        menu = 'permissions_'..index,
        options = options
    })

    lib.showContext('permissions_'..index..'_users')
end

function User:RegisterPainelContext()
    local permissions = Config.Permissions
    local options = {}
    local permissionOptions = {}

    for index, v in pairs(permissions) do
        if not permissionOptions[index] then 
            permissionOptions[index] = {
                {
                    title = locale('see_users'),
                    icon = 'users',
                    arrow = true,
                    onSelect = function()
                        User:GetUsersByPermission(index)
                    end
                }
            }
        end 

        local _permissionOptions = permissionOptions[index]
        options[#options+1] = {
            title = index,
            arrow = true,
            onSelect = function()
                lib.showContext('permissions_'..index)
            end
        }

        for level, salary in pairs(v.salarys) do 
            _permissionOptions[#_permissionOptions+1] = {
                title = 'Level: '..level..' '..locale('salary')..' : '..locale('money_symbol')..salary,
            }
        end
    end

    lib.registerContext({
        id = 'permissions',
        title = locale('menu_title'),
        options = options
    })

    lib.showContext('permissions')
    
    for index, options in pairs(permissionOptions) do 
        lib.registerContext({
            id = 'permissions_'..index,
            title = locale('menu_title')..': '..index,
            menu = 'permissions',
            options = options
        })
    end
end

local PanelOptions = {
    default = function()
        User:RegisterPainelContext()
    end,
    addPermission = function()
        User:AddPermissionMenu()
    end,
    remPermission = function()
        User:RemovePermissionMenu()
    end,
    manageUser = function(userId)
        User:ManageUser(userId)
    end
}

RegisterNetEvent('zhawty-permissions:openPanel', function(mode, ...)
    local mode = mode or 'default'
    if not PanelOptions[mode] then return end
    PanelOptions[mode](...)
end)