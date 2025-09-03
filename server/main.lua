local QBCore = exports['qb-core']:GetCoreObject()
local lastUse = {}

local function IsOnDutyPolice(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    local job = Player.PlayerData.job
    if not job or job.name ~= 'police' then return false end
    if job.onduty == nil then return true end
    return job.onduty == true
end

local function ValidStrain(k)
    return QBWeed.Plants[k] ~= nil
end

local function FirstStageModel(k)
    local s = QBWeed.Plants[k]
    return s and s.stages[1] or nil
end

local function StrainLabel(k)
    local s = QBWeed.Plants[k]
    return s and s.label or k
end

local function LoadAllPlants()
    local rows = MySQL.query.await('SELECT id, coords, model, label, stage, health, food, water, progress, sort FROM weed_plants', {})
    local list = {}
    for _, r in ipairs(rows) do
        local c = json.decode(r.coords)
        list[#list+1] = {id=r.id, coords=c, model=r.model, label=r.label, stage=r.stage, health=r.health, food=r.food, water=r.water, progress=r.progress, sort=r.sort}
    end
    return list
end

local function SyncAll(target)
    local list = LoadAllPlants()
    if target then
        TriggerClientEvent('weed:client:syncPlants', target, list)
    else
        TriggerClientEvent('weed:client:syncPlants', -1, list)
    end
end

local function canUse(src, key)
    local t = GetGameTimer()
    lastUse[src] = lastUse[src] or {}
    if (lastUse[src][key] or 0) + (QBWeed.ActionCooldown or 2000) > t then return false end
    lastUse[src][key] = t
    return true
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SyncAll()
end)

RegisterNetEvent('weed:server:syncPlants', function()
    local src = source
    SyncAll(src)
end)

for strain, _ in pairs(QBWeed.Plants) do
    QBCore.Functions.CreateUseableItem('weed_'..strain..'_seed', function(source, item)
        if IsOnDutyPolice(source) then
            TriggerClientEvent('QBCore:Notify', source, 'Not allowed.', 'error')
            return
        end
        TriggerClientEvent('weed:client:useSeed', source, strain)
    end)
end

RegisterNetEvent('weed:server:plantSeed', function(coords, plantType)
    local src = source
    if not ValidStrain(plantType) then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if IsOnDutyPolice(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Not allowed.', 'error')
        return
    end
    local ped = GetPlayerPed(src)
    local pcoords = GetEntityCoords(ped)
    if #(pcoords - vector3(coords.x, coords.y, coords.z)) > 5.0 then return end
    local seedName = 'weed_'..plantType..'_seed'
    local itm = Player.Functions.GetItemByName(seedName)
    if not itm or itm.amount < 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Missing seed.', 'error')
        return
    end
    Player.Functions.RemoveItem(seedName, 1)
    local model = FirstStageModel(plantType)
    local label = StrainLabel(plantType)
    local id = MySQL.insert.await('INSERT INTO weed_plants (coords, model, label, stage, health, food, water, progress, sort) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        json.encode(coords), model, label, 1, 100, 100, 100, 0, plantType
    })
    local p = {id=id, coords=coords, model=model, label=label, stage=1, health=100, food=100, water=100, progress=0, sort=plantType}
    TriggerClientEvent('weed:client:addNewPlant', -1, p)
    TriggerClientEvent('QBCore:Notify', src, 'Seed planted.', 'success')
end)

RegisterNetEvent('weed:server:getPlantStatus', function(id)
    local src = source
    local r = MySQL.single.await('SELECT id, coords, model, label, stage, health, food, water, progress, sort FROM weed_plants WHERE id = ?', { id })
    if not r then return end
    local data = {
        label = r.label,
        health = r.health,
        food = r.food,
        water = r.water,
        progress = r.progress,
        stage = QBWeed.StageLabels[r.stage] or r.stage
    }
    TriggerClientEvent('weed:client:updatePlantStatus', src, data)
end)

QBCore.Functions.CreateCallback('weed:server:canFeed', function(source, cb, id)
    if not canUse(source, 'feed') then return cb(false, 'Too fast.') end
    if IsOnDutyPolice(source) then return cb(false, 'Not allowed.') end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false, 'No player') end
    local fert = Player.Functions.GetItemByName('weed_nutrition')
    if not fert or fert.amount < 1 then
        return cb(false, 'You don’t have fertilizer.')
    end
    local r = MySQL.single.await('SELECT food FROM weed_plants WHERE id = ?', { id })
    if not r then return cb(false, 'Plant not found.') end
    if (r.food or 0) >= 100 then
        return cb(false, 'Plant doesn’t need fertilizer.')
    end
    cb(true, '')
end)

QBCore.Functions.CreateCallback('weed:server:canWater', function(source, cb, id)
    if not canUse(source, 'water') then return cb(false, 'Too fast.') end
    if IsOnDutyPolice(source) then return cb(false, 'Not allowed.') end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false, 'No player') end
    local water = Player.Functions.GetItemByName('water_bottle')
    if not water or water.amount < 1 then
        return cb(false, 'You don’t have water.')
    end
    local r = MySQL.single.await('SELECT water FROM weed_plants WHERE id = ?', { id })
    if not r then return cb(false, 'Plant not found.') end
    if (r.water or 0) >= 100 then
        return cb(false, 'Plant doesn’t need water.')
    end
    cb(true, '')
end)

RegisterNetEvent('weed:server:feedPlant', function(id)
    local src = source
    if IsOnDutyPolice(src) then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local fert = Player.Functions.GetItemByName('weed_nutrition')
    if not fert or fert.amount < 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Missing fertilizer.', 'error')
        return
    end
    local r = MySQL.single.await('SELECT food FROM weed_plants WHERE id = ?', { id })
    if not r then return end
    local nv = math.min(100, (r.food or 0) + 25)
    Player.Functions.RemoveItem('weed_nutrition', 1)
    MySQL.update.await('UPDATE weed_plants SET food = ? WHERE id = ?', { nv, id })
    TriggerClientEvent('QBCore:Notify', src, 'Fertilized.', 'success')
end)

RegisterNetEvent('weed:server:waterPlant', function(id)
    local src = source
    if IsOnDutyPolice(src) then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local water = Player.Functions.GetItemByName('water_bottle')
    if not water or water.amount < 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Missing water.', 'error')
        return
    end
    local r = MySQL.single.await('SELECT water FROM weed_plants WHERE id = ?', { id })
    if not r then return end
    local nv = math.min(100, (r.water or 0) + 25)
    Player.Functions.RemoveItem('water_bottle', 1)
    MySQL.update.await('UPDATE weed_plants SET water = ? WHERE id = ?', { nv, id })
    TriggerClientEvent('QBCore:Notify', src, 'Watered.', 'success')
end)

RegisterNetEvent('weed:server:harvestPlant', function(id)
    local src = source
    if IsOnDutyPolice(src) then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local r = MySQL.single.await('SELECT id, stage, sort FROM weed_plants WHERE id = ?', { id })
    if not r then return end
    local s = QBWeed.Plants[r.sort]
    if not s then return end
    if tonumber(r.stage) < s.highestStage then
        TriggerClientEvent('QBCore:Notify', src, 'Not ready.', 'error')
        return
    end
    MySQL.update.await('DELETE FROM weed_plants WHERE id = ?', { id })
    TriggerClientEvent('weed:client:removePlant', -1, id)
    local leaf = 'weed_'..r.sort..'_leaf'
    Player.Functions.AddItem(leaf, math.random(2,5))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[leaf], 'add')
    TriggerClientEvent('QBCore:Notify', src, 'Harvested.', 'success')
end)

RegisterNetEvent('weed:server:destroyPlantByPolice', function(id)
    local src = source
    if not IsOnDutyPolice(src) then return end
    local r = MySQL.single.await('SELECT id FROM weed_plants WHERE id = ?', { id })
    if not r then return end
    MySQL.update.await('DELETE FROM weed_plants WHERE id = ?', { id })
    TriggerClientEvent('weed:client:removePlant', -1, id)
    TriggerClientEvent('QBCore:Notify', src, 'Destroyed.', 'success')
end)

CreateThread(function()
    while true do
        Wait(QBWeed.GrowthTick * 60000)
        local rows = MySQL.query.await('SELECT id, stage, health, food, water, progress, sort, coords FROM weed_plants', {})
        if rows and #rows > 0 then
            local updates = {}
            for _, r in ipairs(rows) do
                local health = r.health or 100
                local food = r.food or 100
                local water = r.water or 100
                local progress = r.progress or 0
                local stage = r.stage or 1
                food = math.max(0, food - QBWeed.FoodUsage)
                water = math.max(0, water - QBWeed.WaterUsage)
                if food < 10 or water < 10 then
                    health = math.max(0, health - 2)
                else
                    if health < 100 then health = math.min(100, health + 1) end
                end
                if health > 50 then
                    progress = progress + math.random(QBWeed.Progress.min, QBWeed.Progress.max)
                end
                local dead = health <= 0
                local sdata = QBWeed.Plants[r.sort]
                if progress >= 100 and sdata and stage < sdata.highestStage then
                    stage = stage + 1
                    progress = 0
                    local m = sdata.stages[stage]
                    MySQL.update.await('UPDATE weed_plants SET stage = ?, model = ?, progress = ?, health = ?, food = ?, water = ? WHERE id = ?', { stage, m, progress, health, food, water, r.id })
                    table.insert(updates, {id=r.id, model=m, stage=stage, coords=json.decode(r.coords), label=sdata.label})
                elseif dead then
                    MySQL.update.await('DELETE FROM weed_plants WHERE id = ?', { r.id })
                    TriggerClientEvent('weed:client:removePlant', -1, r.id)
                else
                    MySQL.update.await('UPDATE weed_plants SET progress = ?, health = ?, food = ?, water = ? WHERE id = ?', { progress, health, food, water, r.id })
                end
            end
            for _, u in ipairs(updates) do
                TriggerClientEvent('weed:client:updatePlantStage', -1, u)
            end
        end
    end
end)
