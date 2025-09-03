# gb-weedoutdoorV2
New version of growing weed outdoors.

# qb-weedoutdoor V2

A free **weed growing system** for the QB-Core framework in FiveM.  
Supports outdoor planting, fertilizing, watering, harvesting, and police interaction.

---

## Features
- Plant weed seeds on natural ground.
- Growth system with multiple stages.
- Fertilizer & water requirements for healthy plants.
- Custom animations:
  - Planting animation
  - Police can only **destroy plants** (with proper animation).
- Plants sink slightly into the ground (configurable).
- Growth and needs tick every configurable interval.
- Server-side security:
  - Distance check (prevents planting at unrealistic coords)
  - Rate limit (prevents spam actions)
- Fully synced across all players.
- Easy to configure.

---

## Installation

1. Clone or download this repository into your `resources/[qb]` folder.
2. Import the SQL file into your database:
   CREATE TABLE IF NOT EXISTS `weed_plants` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `coords` LONGTEXT DEFAULT NULL,
  `model` VARCHAR(75) DEFAULT NULL,
  `label` VARCHAR(50) DEFAULT NULL,
  `stage` INT(11) DEFAULT 1,
  `health` INT(11) DEFAULT 100,
  `food` INT(11) DEFAULT 100,
  `water` INT(11) DEFAULT 100,
  `progress` INT(11) DEFAULT 0,
  `sort` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

3.

ADD THESE IN YOUR qb-core/shared/items.lua

-- Seeds
["weed_ak47_seed"]         = {["name"] = "weed_ak47_seed",         ["label"] = "AK47 Seed",          ["weight"] = 0, ["type"] = "item", ["image"] = "weed_seed.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed seed"},
["weed_amnesia_seed"]      = {["name"] = "weed_amnesia_seed",      ["label"] = "Amnesia Seed",       ["weight"] = 0, ["type"] = "item", ["image"] = "weed_seed.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed seed"},
["weed_purple_haze_seed"]  = {["name"] = "weed_purple_haze_seed",  ["label"] = "Purple Haze Seed",   ["weight"] = 0, ["type"] = "item", ["image"] = "weed_seed.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed seed"},
["weed_og_kush_seed"]      = {["name"] = "weed_og_kush_seed",      ["label"] = "OG Kush Seed",       ["weight"] = 0, ["type"] = "item", ["image"] = "weed_seed.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed seed"},
["weed_white_widow_seed"]  = {["name"] = "weed_white_widow_seed",  ["label"] = "White Widow Seed",   ["weight"] = 0, ["type"] = "item", ["image"] = "weed_seed.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed seed"},
["weed_skunk_seed"]        = {["name"] = "weed_skunk_seed",        ["label"] = "Skunk Seed",         ["weight"] = 0, ["type"] = "item", ["image"] = "weed_seed.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed seed"},

-- Leaves (reward from harvesting)
["weed_ak47_leaf"]         = {["name"] = "weed_ak47_leaf",         ["label"] = "AK47 Leaf",          ["weight"] = 100, ["type"] = "item", ["image"] = "weed_leaf.png", ["unique"] = false, ["useable"] = false, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed leaf"},
["weed_amnesia_leaf"]      = {["name"] = "weed_amnesia_leaf",      ["label"] = "Amnesia Leaf",       ["weight"] = 100, ["type"] = "item", ["image"] = "weed_leaf.png", ["unique"] = false, ["useable"] = false, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed leaf"},
["weed_purple_haze_leaf"]  = {["name"] = "weed_purple_haze_leaf",  ["label"] = "Purple Haze Leaf",   ["weight"] = 100, ["type"] = "item", ["image"] = "weed_leaf.png", ["unique"] = false, ["useable"] = false, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed leaf"},
["weed_og_kush_leaf"]      = {["name"] = "weed_og_kush_leaf",      ["label"] = "OG Kush Leaf",       ["weight"] = 100, ["type"] = "item", ["image"] = "weed_leaf.png", ["unique"] = false, ["useable"] = false, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed leaf"},
["weed_white_widow_leaf"]  = {["name"] = "weed_white_widow_leaf",  ["label"] = "White Widow Leaf",   ["weight"] = 100, ["type"] = "item", ["image"] = "weed_leaf.png", ["unique"] = false, ["useable"] = false, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed leaf"},
["weed_skunk_leaf"]        = {["name"] = "weed_skunk_leaf",        ["label"] = "Skunk Leaf",         ["weight"] = 100, ["type"] = "item", ["image"] = "weed_leaf.png", ["unique"] = false, ["useable"] = false, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Weed leaf"},

-- Fertilizer
["weed_nutrition"]         = {["name"] = "weed_nutrition",         ["label"] = "Fertilizer",         ["weight"] = 200, ["type"] = "item", ["image"] = "fertilizer.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Plant nutrition"}

