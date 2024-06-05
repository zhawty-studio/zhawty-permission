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
                return true--exports[GetCurrentResourceName()]:Has(userId, 'god')
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