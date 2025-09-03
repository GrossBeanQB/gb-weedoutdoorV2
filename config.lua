QBWeed = QBWeed or {}
QBWeed.ZSink = 0.47


QBWeed.Progress = {min = 1, max = 5}
QBWeed.ShowStages = true
QBWeed.GrowthTick = 1
QBWeed.FoodUsage = 1
QBWeed.WaterUsage = 1

QBWeed.MinSoilQuality = 0.6

QBWeed.Soil = {
    [2128369009] = 0.6,
    [-1286696947] = 0.75,
    [-461750719] = 0.8,
    [1333033863] = 0.8,
    [3008270349] = 1.0,
    [3594390083] = 1.0,
    [2461440131] = 1.0,
    [2409420175] = 1.2,
    [3833216577] = 1.2,
    [4170197704] = 1.2,
    [2230860562] = 1.3,
    [581794674]  = 1.3,
    [2352068586] = 1.4,
    [1109728704] = 1.5
}

QBWeed.StageLabels = {
    [1] = 'Germination',
    [2] = 'Seedling',
    [3] = 'Vegetative',
    [4] = 'Budding',
    [5] = 'Pre-flowering',
    [6] = 'Flowering',
    [7] = 'Ready for Harvest'
}

QBWeed.Plants = {
    ogkush = {
        label = 'OG Kush',
        stages = {
            [1] = 'bkr_prop_weed_01_small_01c',
            [2] = 'bkr_prop_weed_01_small_01b',
            [3] = 'bkr_prop_weed_01_small_01a',
            [4] = 'bkr_prop_weed_med_01b',
            [5] = 'bkr_prop_weed_lrg_01a',
            [6] = 'bkr_prop_weed_lrg_01b',
            [7] = 'bkr_prop_weed_lrg_01b'
        },
        highestStage = 7
    },
    amnesia = {
        label = 'Amnesia',
        stages = {
            [1] = 'bkr_prop_weed_01_small_01c',
            [2] = 'bkr_prop_weed_01_small_01b',
            [3] = 'bkr_prop_weed_01_small_01a',
            [4] = 'bkr_prop_weed_med_01b',
            [5] = 'bkr_prop_weed_lrg_01a',
            [6] = 'bkr_prop_weed_lrg_01b',
            [7] = 'bkr_prop_weed_lrg_01b'
        },
        highestStage = 7
    },
    ak47 = {
        label = 'AK47',
        stages = {
            [1] = 'bkr_prop_weed_01_small_01c',
            [2] = 'bkr_prop_weed_01_small_01b',
            [3] = 'bkr_prop_weed_01_small_01a',
            [4] = 'bkr_prop_weed_med_01b',
            [5] = 'bkr_prop_weed_lrg_01a',
            [6] = 'bkr_prop_weed_lrg_01b',
            [7] = 'bkr_prop_weed_lrg_01b'
        },
        highestStage = 7
    },
    purplehaze = {
        label = 'Purple Haze',
        stages = {
            [1] = 'bkr_prop_weed_01_small_01c',
            [2] = 'bkr_prop_weed_01_small_01b',
            [3] = 'bkr_prop_weed_01_small_01a',
            [4] = 'bkr_prop_weed_med_01b',
            [5] = 'bkr_prop_weed_lrg_01a',
            [6] = 'bkr_prop_weed_lrg_01b',
            [7] = 'bkr_prop_weed_lrg_01b'
        },
        highestStage = 7
    },
    skunk = {
        label = 'Skunk',
        stages = {
            [1] = 'bkr_prop_weed_01_small_01c',
            [2] = 'bkr_prop_weed_01_small_01b',
            [3] = 'bkr_prop_weed_01_small_01a',
            [4] = 'bkr_prop_weed_med_01b',
            [5] = 'bkr_prop_weed_lrg_01a',
            [6] = 'bkr_prop_weed_lrg_01b',
            [7] = 'bkr_prop_weed_lrg_01b'
        },
        highestStage = 7
    },
    whitewidow = {
        label = 'White Widow',
        stages = {
            [1] = 'bkr_prop_weed_01_small_01c',
            [2] = 'bkr_prop_weed_01_small_01b',
            [3] = 'bkr_prop_weed_01_small_01a',
            [4] = 'bkr_prop_weed_med_01b',
            [5] = 'bkr_prop_weed_lrg_01a',
            [6] = 'bkr_prop_weed_lrg_01b',
            [7] = 'bkr_prop_weed_lrg_01b'
        },
        highestStage = 7
    }
}
