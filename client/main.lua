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

function User:ManageMenu(index, citizenid)
    lib.registerContext({
        id = 'permissions_'..index..'_user_manage',
        title = locale('menu_title')..': '..index,
        menu = 'permissions_'..index..'_users',
        options = {
            {
                title = 'Alterar',
                serverEvent = ''
            },
            {
                title = 'Remover',
                serverEvent = ''
            }
        }
    })
    lib.showContext('permissions_'..index..'_user_manage')
end

function User:GetUsersByPermission(index)
    local users = lib.callback.await('zhawty-permissions:getUsersByPermission', 100, index)
    local options = {}
    for _, user in pairs(users) do
        options[#options + 1] = {
            title = user.text,
            onSelect = function()
                User:ManageMenu(index, user.citizenid)
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
                    title = 'Ver usuários setados',
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
                title = 'Level: '..level..' Salário: '..locale('money_symbol')..salary,
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

RegisterNetEvent('zhawty-permissions:openPanel', function()
    User:RegisterPainelContext()
end)