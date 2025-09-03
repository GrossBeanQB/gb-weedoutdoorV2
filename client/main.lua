local QBCore = exports['qb-core']:GetCoreObject()

local spawnedPlantObjects = {}
local plantsCache = {}
local weedProp = nil
local PlayerData = {}
local leafDebounce

local function OpenPlantStatusUI(plant)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showPlantStatus",
        data = {
            label = plant.label,
            health = plant.health,
            food = plant.food,
            water = plant.water,
            progress = plant.progress,
            stage = plant.stage
        }
    })
end

RegisterNUICallback("closePlantStatus", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

local function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
    end
    SetModelAsNoLongerNeeded(model)
end

local function DoPlantAction(label, msg, duration, animDict, anim, cb)
    QBCore.Functions.Progressbar(label, msg, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
        animDict = animDict,
        anim = anim,
        flags = 49
    }, {}, {}, {}, cb, function()
        QBCore.Functions.Notify("Action cancelled.", "error")
    end)
end

local function IsOnDutyPolice()
    if not PlayerData or not PlayerData.job then return false end
    local j = PlayerData.job
    return j.name == 'police' and (j.onduty == nil or j.onduty == true)
end

local function CanPlantHere(coord)
    if IsPointOnRoad(coord.x, coord.y, coord.z, false) then return false end
    if GetInteriorAtCoords(coord.x, coord.y, coord.z) ~= 0 then return false end
    local from = vector3(coord.x, coord.y, coord.z + 1.0)
    local to = vector3(coord.x, coord.y, coord.z - 2.0)
    local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 1, 0, 7)
    local _, _, _, _, mat = GetShapeTestResultIncludingMaterial(ray)
    if not mat then return false end
    local q = (QBWeed.Soil and QBWeed.Soil[mat]) or 0.0
    return q >= (QBWeed.MinSoilQuality or 0.6)
end

local function removeTargetIfPossible(entity)
    if exports['qb-target'] and exports['qb-target'].RemoveTargetEntity and entity and DoesEntityExist(entity) then
        exports['qb-target']:RemoveTargetEntity(entity)
    end
end

local function buildOptionsForPlant(plant)
    if IsOnDutyPolice() then
        return {
            {
                label = "Destroy The Plant",
                action = function()
                    local ped = PlayerPedId()
                    TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, true)
                    QBCore.Functions.Progressbar('destroy_plant', 'Destroying the plant...', 5000, false, true, {}, {}, {}, {}, function()
                        ClearPedTasksImmediately(ped)
                        TriggerServerEvent('weed:server:destroyPlantByPolice', plant.id)
                    end, function()
                        ClearPedTasksImmediately(ped)
                    end)
                end
            }
        }
    else
        return {
            {
                label = "Check Plant Status",
                action = function()
                    TriggerServerEvent('weed:server:getPlantStatus', plant.id)
                end
            },
            {
                label = "Harvest Plant",
                action = function()
                    TriggerServerEvent('weed:server:harvestPlant', plant.id)
                end
            },
            {
                label = "Feed Plant",
                action = function()
                    QBCore.Functions.TriggerCallback('weed:server:canFeed', function(ok, msg)
                        if not ok then
                            QBCore.Functions.Notify(msg, 'error')
                            return
                        end
                        DoPlantAction("feed_plant", "Feeding Plant...", 5000, "amb@world_human_gardener@male@idle_a", "idle_a", function()
                            TriggerServerEvent('weed:server:feedPlant', plant.id)
                        end)
                    end, plant.id)
                end
            },
            {
                label = "Water Plant",
                action = function()
                    QBCore.Functions.TriggerCallback('weed:server:canWater', function(ok, msg)
                        if not ok then
                            QBCore.Functions.Notify(msg, 'error')
                            return
                        end
                        DoPlantAction("water_plant", "Watering Plant...", 5000, "amb@world_human_drinking@coffee@male@idle_a", "idle_b", function()
                            TriggerServerEvent('weed:server:waterPlant', plant.id)
                        end)
                    end, plant.id)
                end
            }
        }
    end
end

local function attachTargetsForPlant(plantId)
    local obj = spawnedPlantObjects[plantId]
    local plant = plantsCache[plantId]
    if not obj or not DoesEntityExist(obj) or not plant then return end
    removeTargetIfPossible(obj)
    local opts = buildOptionsForPlant(plant)
    exports['qb-target']:AddTargetEntity(obj, { options = opts, distance = 2.5 })
end

local function CreateWeedPlant(plant)
    if not plant or not plant.coords or not plant.id then return nil end
    local coords = type(plant.coords) == "string" and json.decode(plant.coords) or plant.coords
    local plantModel = GetHashKey(plant.model)
    LoadModel(plantModel)
    local obj = CreateObject(plantModel, coords.x, coords.y, coords.z, false, false, false)
    PlaceObjectOnGroundProperly(obj)
    local x, y, z = table.unpack(GetEntityCoords(obj))
    local sink = QBWeed and QBWeed.ZSink or 0.0
    SetEntityCoords(obj, x, y, z - sink, false, false, false, true)
    FreezeEntityPosition(obj, true)
    return obj
end

local function refreshAllPlantTargets()
    for id, _ in pairs(spawnedPlantObjects) do
        attachTargetsForPlant(id)
    end
end

local function spawnOutdoorPlants(plants)
    for _, obj in pairs(spawnedPlantObjects) do
        if DoesEntityExist(obj) then
            removeTargetIfPossible(obj)
            DeleteObject(obj)
        end
    end
    spawnedPlantObjects = {}
    plantsCache = {}
    local i = 0
    for _, plant in pairs(plants) do
        plantsCache[plant.id] = plant
        local obj = CreateWeedPlant(plant)
        if obj then
            spawnedPlantObjects[plant.id] = obj
            attachTargetsForPlant(plant.id)
        end
        i = i + 1
        if i % 25 == 0 then Wait(0) end
    end
end

RegisterNetEvent('weed:client:syncPlants', function(plants)
    spawnOutdoorPlants(plants)
end)

RegisterNetEvent('weed:client:updatePlantStage', function(updatedPlant)
    local oldObj = spawnedPlantObjects[updatedPlant.id]
    if oldObj and DoesEntityExist(oldObj) then
        removeTargetIfPossible(oldObj)
        DeleteObject(oldObj)
        spawnedPlantObjects[updatedPlant.id] = nil
    end
    plantsCache[updatedPlant.id] = updatedPlant
    local newObj = CreateWeedPlant(updatedPlant)
    if newObj then
        spawnedPlantObjects[updatedPlant.id] = newObj
        attachTargetsForPlant(updatedPlant.id)
    end
end)

RegisterNetEvent('weed:client:updatePlantStatus', function(updatedPlant)
    if updatedPlant then
        OpenPlantStatusUI(updatedPlant)
    else
        QBCore.Functions.Notify('Unable to retrieve plant data.', 'error')
    end
end)

RegisterNetEvent('weed:client:useSeed', function(seedType)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end
    local pos = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    local place = pos + (fwd * 0.8)
    local _, groundZ = GetGroundZFor_3dCoord(place.x, place.y, place.z, false)
    local plantAt = vector3(place.x, place.y, groundZ)
    if not CanPlantHere(plantAt) then
        QBCore.Functions.Notify('You must plant on natural ground.', 'error')
        return
    end
    TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, true)
    QBCore.Functions.Progressbar('plant_weed', 'Planting Seed...', 5000, false, true, {}, {}, {}, {}, function()
        ClearPedTasksImmediately(ped)
        TriggerServerEvent('weed:server:plantSeed', plantAt, seedType)
    end, function()
        ClearPedTasksImmediately(ped)
    end)
end)

RegisterNetEvent('weed:client:addNewPlant', function(plant)
    if not plant or not plant.coords or not plant.id then return end
    plantsCache[plant.id] = plant
    local createdObj = CreateWeedPlant(plant)
    if createdObj then
        spawnedPlantObjects[plant.id] = createdObj
        attachTargetsForPlant(plant.id)
    end
end)

RegisterNetEvent('weed:client:removePlant', function(plantId)
    plantsCache[plantId] = nil
    local obj = spawnedPlantObjects[plantId]
    if obj and DoesEntityExist(obj) then
        removeTargetIfPossible(obj)
        DeleteObject(obj)
    end
    spawnedPlantObjects[plantId] = nil
end)

local function UpdateWeedLeafProp()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local hasWeedLeaf = false
    local weedLeafItems = {
        "weed_ak47_leaf", "weed_amnesia_leaf", "weed_purple_haze_leaf",
        "weed_og_kush_leaf", "weed_white_widow_leaf", "weed_skunk_leaf"
    }
    for _, item in pairs(playerData.items or {}) do
        for _, leaf in pairs(weedLeafItems) do
            if item.name == leaf and item.amount > 0 then
                hasWeedLeaf = true
                break
            end
        end
        if hasWeedLeaf then break end
    end
    if hasWeedLeaf and not weedProp then
        local model = GetHashKey("bkr_prop_weed_drying_02a")
        LoadModel(model)
        local coords = GetEntityCoords(ped)
        weedProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(weedProp, ped, GetPedBoneIndex(ped, 24816), 0.0, -0.20, 0.0, 0.0, 100.0, 2.0, false, false, false, false, 2, true)
    elseif not hasWeedLeaf and weedProp then
        DeleteObject(weedProp)
        weedProp = nil
    end
end

local function SafeUpdateWeedLeafProp()
    if leafDebounce then return end
    leafDebounce = true
    SetTimeout(150, function()
        leafDebounce = nil
        UpdateWeedLeafProp()
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    SafeUpdateWeedLeafProp()
    refreshAllPlantTargets()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    if not PlayerData then PlayerData = {} end
    PlayerData.job = job
    refreshAllPlantTargets()
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    if not PlayerData or not PlayerData.job then return end
    PlayerData.job.onduty = duty
    refreshAllPlantTargets()
end)

RegisterNetEvent('QBCore:Client:OnInventoryUpdate', function()
    SafeUpdateWeedLeafProp()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
    SafeUpdateWeedLeafProp()
    refreshAllPlantTargets()
end)

CreateThread(function()
    TriggerServerEvent('weed:server:syncPlants')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, obj in pairs(spawnedPlantObjects) do
            if DoesEntityExist(obj) then
                removeTargetIfPossible(obj)
                DeleteObject(obj)
            end
        end
        spawnedPlantObjects = {}
        plantsCache = {}
        if weedProp and DoesEntityExist(weedProp) then
            DeleteObject(weedProp)
            weedProp = nil
        end
        SetNuiFocus(false, false)
    end
end)
