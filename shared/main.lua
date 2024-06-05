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
                
            end
        },
        remPermission = {
            name = 'ungroup',
            canExecute = function(source)
                
            end
        }
    }
}