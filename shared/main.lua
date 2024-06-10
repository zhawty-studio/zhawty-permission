Config = {
    Payday = {
        Timer = 10,
        Job = true
    },
    Commands = {
        panel = {
            name = 'permissions',
            canExecute = function(source)
                local userId = Functions.getUserId(source)
                return exports[GetCurrentResourceName()]:Has(userId, 'admin')
            end
        },
        addPermission = {
            name = 'group',
            canExecute = function(source)
                local userId = Functions.getUserId(source)
                return exports[GetCurrentResourceName()]:Has(userId, 'admin')
            end
        },
        remPermission = {
            name = 'ungroup',
            canExecute = function(source)
                local userId = Functions.getUserId(source)
                return exports[GetCurrentResourceName()]:Has(userId, 'admin')
            end
        },
        manageUser = {
            name = 'ugroup',
            canExecute = function(source)
                local userId = Functions.getUserId(source)
                return exports[GetCurrentResourceName()]:Has(userId, 'admin')
            end
        }
    },
    Permissions = {
        ['teste'] = {
            salarys = {
                ['0'] = 200,
                ['1'] = 600
            },
            parents = {}
        },
        ['teste2'] = {
            salarys = {
                ['0'] = 200,
                ['1'] = 600
            },
            parents = {}
        }
    }
}