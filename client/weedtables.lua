local QBCore = exports['qb-core']:GetCoreObject()
local tableObj

CreateThread(function()
    local m = `bkr_prop_weed_table_01b`
    RequestModel(m)
    local t = GetGameTimer()
    while not HasModelLoaded(m) do
        Wait(15)
        if GetGameTimer() - t > 5000 then break end
    end
    tableObj = CreateObject(m, -1172.0, -1572.0, 4.66, false, false, false)
    SetEntityHeading(tableObj, 125.0)
    FreezeEntityPosition(tableObj, true)
    exports['qb-target']:AddTargetEntity(tableObj, {
        options = {
            {
                icon = 'fas fa-seedling',
                label = 'Check Table',
                action = function()
                    TriggerEvent('weed:client:checkTable')
                end
            }
        },
        distance = 2.0
    })
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if tableObj and DoesEntityExist(tableObj) then
        if exports['qb-target'] and exports['qb-target'].RemoveTargetEntity then
            exports['qb-target']:RemoveTargetEntity(tableObj)
        end
        DeleteObject(tableObj)
        tableObj = nil
    end
end)
