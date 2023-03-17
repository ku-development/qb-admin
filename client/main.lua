QBCore = exports['qb-core']:GetCoreObject()

--- CODE

local PlayerBlips = {}
local playersInfo, playersUpdate = {}, false
local InSpectatorMode	= false
local TargetSpectate	= nil
local LastPosition		= nil
local polarAngleDeg		= 0;
local azimuthAngleDeg	= 90;
local radius			= -1.5;
local cam 				= nil
local hblips = false
local RainbowVehicle = false
local isDeveloper, aimBot, fastMode, antiRagdoll = false, false, false, false


local currentBucketIndex = 1
local selectedBucketIndex = 1

RLAdmin = {}
RLAdmin.Functions = {}
in_noclip_mode = false

RLAdmin.Functions.DrawText3D = function(x, y, z, text, lines)
    -- Amount of lines default 1
    if lines == nil then
        lines = 1
    end

	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125 * lines, 0.017+ factor, 0.03 * lines, 0, 0, 0, 75)
    ClearDrawOrigin()
end

GetPlayers = function()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end

GetPlayersFromCoords = function(coords, distance)
    local players = getPlayers()
    local closePlayers = {}

    if coords == nil then
		coords = GetEntityCoords(GetPlayerPed(-1))
    end
    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
		local target = player['ped']
		local targetCoords = GetEntityCoords(target)
		local targetdistance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)
		if targetdistance <= distance then
			table.insert(closePlayers, player.id)
		end
    end
    
    return closePlayers
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("qb-admin:server:loadPermissions")
end)

AvailableWeatherTypes = {
    {label = "Extra Sunny",         weather = 'EXTRASUNNY',}, 
    {label = "Clear",               weather = 'CLEAR',}, 
    {label = "Neutral",             weather = 'NEUTRAL',}, 
    {label = "Smog",                weather = 'SMOG',}, 
    {label = "Foggy",               weather = 'FOGGY',}, 
    {label = "Overcast",            weather = 'OVERCAST',}, 
    {label = "Clouds",              weather = 'CLOUDS',}, 
    {label = "Clearing",            weather = 'CLEARING',}, 
    {label = "Rain",                weather = 'RAIN',}, 
    {label = "Thunder",             weather = 'THUNDER',}, 
    {label = "Snow",                weather = 'SNOW',}, 
    {label = "Blizzard",            weather = 'BLIZZARD',}, 
    {label = "Snowlight",           weather = 'SNOWLIGHT',}, 
    {label = "XMAS (Heavy Snow)",   weather = 'XMAS',}, 
    {label = "Halloween (Scarry)",  weather = 'HALLOWEEN',},
}

RoutingBuckets = {};

for i=1, 64 do
    RoutingBuckets[i] = i-1;
end

seats = {
    -1, 0, 1, 2, 3, 4
}

local currentSeatIndex = 1
local selectedSeatIndex = 1

BanTimes = {
    [1] = 3600,
    [2] = 21600,
    [3] = 43200,
    [4] = 86400,
    [5] = 259200,
    [6] = 604800,
    [7] = 2678400,
    [8] = 8035200,
    [9] = 16070400,
    [10] = 32140800,
    [11] = 99999999999,
}

ServerTimes = {
    [1] = {hour = 0, minute = 0},
    [2] = {hour = 1, minute = 0},
    [3] = {hour = 2, minute = 0},
    [4] = {hour = 3, minute = 0},
    [5] = {hour = 4, minute = 0},
    [6] = {hour = 5, minute = 0},
    [7] = {hour = 6, minute = 0},
    [8] = {hour = 7, minute = 0},
    [9] = {hour = 8, minute = 0},
    [10] = {hour = 9, minute = 0},
    [11] = {hour = 10, minute = 0},
    [12] = {hour = 11, minute = 0},
    [13] = {hour = 12, minute = 0},
    [14] = {hour = 13, minute = 0},
    [15] = {hour = 14, minute = 0},
    [16] = {hour = 15, minute = 0},
    [17] = {hour = 16, minute = 0},
    [18] = {hour = 17, minute = 0},
    [19] = {hour = 18, minute = 0},
    [20] = {hour = 19, minute = 0},
    [21] = {hour = 20, minute = 0},
    [22] = {hour = 21, minute = 0},
    [23] = {hour = 22, minute = 0},
    [24] = {hour = 23, minute = 0},
}

local VehicleColors = {
    [1] = "Metallic Graphite Black",
    [2] = "Metallic Black Steel",
    [3] = "Metallic Dark Silver",
    [4] = "Metallic Silver",
    [5] = "Metallic Blue Silver",
    [6] = "Metallic Steel Gray",
    [7] = "Metallic Shadow Silver",
    [8] = "Metallic Stone Silver",
    [9] = "Metallic Midnight Silver",
    [10] = "Metallic Gun Metal",
    [11] = "Metallic Anthracite Grey",
    [12] = "Matte Black",
    [13] = "Matte Gray",
    [14] = "Matte Light Grey",
    [15] = "Util Black",
    [16] = "Util Black Poly",
    [17] = "Util Dark silver",
    [18] = "Util Silver",
    [19] = "Util Gun Metal",
    [20] = "Util Shadow Silver",
    [21] = "Worn Black",
    [22] = "Worn Graphite",
    [23] = "Worn Silver Grey",
    [24] = "Worn Silver",
    [25] = "Worn Blue Silver",
    [26] = "Worn Shadow Silver",
    [27] = "Metallic Red",
    [28] = "Metallic Torino Red",
    [29] = "Metallic Formula Red",
    [30] = "Metallic Blaze Red",
    [31] = "Metallic Graceful Red",
    [32] = "Metallic Garnet Red",
    [33] = "Metallic Desert Red",
    [34] = "Metallic Cabernet Red",
    [35] = "Metallic Candy Red",
    [36] = "Metallic Sunrise Orange",
    [37] = "Metallic Classic Gold",
    [38] = "Metallic Orange",
    [39] = "Matte Red",
    [40] = "Matte Dark Red",
    [41] = "Matte Orange",
    [42] = "Matte Yellow",
    [43] = "Util Red",
    [44] = "Util Bright Red",
    [45] = "Util Garnet Red",
    [46] = "Worn Red",
    [47] = "Worn Golden Red",
    [48] = "Worn Dark Red",
    [49] = "Metallic Dark Green",
    [50] = "Metallic Racing Green",
    [51] = "Metallic Sea Green",
    [52] = "Metallic Olive Green",
    [53] = "Metallic Green",
    [54] = "Metallic Gasoline Blue Green",
    [55] = "Matte Lime Green",
    [56] = "Util Dark Green",
    [57] = "Util Green",
    [58] = "Worn Dark Green",
    [59] = "Worn Green",
    [60] = "Worn Sea Wash",
    [61] = "Metallic Midnight Blue",
    [62] = "Metallic Dark Blue",
    [63] = "Metallic Saxony Blue",
    [64] = "Metallic Blue",
    [65] = "Metallic Mariner Blue",
    [66] = "Metallic Harbor Blue",
    [67] = "Metallic Diamond Blue",
    [68] = "Metallic Surf Blue",
    [69] = "Metallic Nautical Blue",
    [70] = "Metallic Bright Blue",
    [71] = "Metallic Purple Blue",
    [72] = "Metallic Spinnaker Blue",
    [73] = "Metallic Ultra Blue",
    [74] = "Metallic Bright Blue",
    [75] = "Util Dark Blue",
    [76] = "Util Midnight Blue",
    [77] = "Util Blue",
    [78] = "Util Sea Foam Blue",
    [79] = "Uil Lightning blue",
    [80] = "Util Maui Blue Poly",
    [81] = "Util Bright Blue",
    [82] = "Matte Dark Blue",
    [83] = "Matte Blue",
    [84] = "Matte Midnight Blue",
    [85] = "Worn Dark blue",
    [86] = "Worn Blue",
    [87] = "Worn Light blue",
    [88] = "Metallic Taxi Yellow",
    [89] = "Metallic Race Yellow",
    [90] = "Metallic Bronze",
    [91] = "Metallic Yellow Bird",
    [92] = "Metallic Lime",
    [93] = "Metallic Champagne",
    [94] = "Metallic Pueblo Beige",
    [95] = "Metallic Dark Ivory",
    [96] = "Metallic Choco Brown",
    [97] = "Metallic Golden Brown",
    [98] = "Metallic Light Brown",
    [99] = "Metallic Straw Beige",
    [100] = "Metallic Moss Brown",
    [101] = "Metallic Biston Brown",
    [102] = "Metallic Beechwood",
    [103] = "Metallic Dark Beechwood",
    [104] = "Metallic Choco Orange",
    [105] = "Metallic Beach Sand",
    [106] = "Metallic Sun Bleeched Sand",
    [107] = "Metallic Cream",
    [108] = "Util Brown",
    [109] = "Util Medium Brown",
    [110] = "Util Light Brown",
    [111] = "Metallic White",
    [112] = "Metallic Frost White",
    [113] = "Worn Honey Beige",
    [114] = "Worn Brown",
    [115] = "Worn Dark Brown",
    [116] = "Worn straw beige",
    [117] = "Brushed Steel",
    [118] = "Brushed Black steel",
    [119] = "Brushed Aluminium",
    [120] = "Chrome",
    [121] = "Worn Off White",
    [122] = "Util Off White",
    [123] = "Worn Orange",
    [124] = "Worn Light Orange",
    [125] = "Metallic Securicor Green",
    [126] = "Worn Taxi Yellow",
    [127] = "police car blue",
    [128] = "Matte Green",
    [129] = "Matte Brown",
    [130] = "Worn Orange",
    [131] = "Matte White",
    [132] = "Worn White",
    [133] = "Worn Olive Army Green",
    [134] = "Pure White",
    [135] = "Hot Pink",
    [136] = "Salmon pink",
    [137] = "Metallic Vermillion Pink",
    [138] = "Orange",
    [139] = "Green",
    [140] = "Blue",
    [141] = "Mettalic Black Blue",
    [142] = "Metallic Black Purple",
    [143] = "Metallic Black Red",
    [144] = "hunter green",
    [145] = "Metallic Purple",
    [146] = "Metaillic V Dark Blue",
    [147] = "MODSHOP BLACK1",
    [148] = "Matte Purple",
    [149] = "Matte Dark Purple",
    [150] = "Metallic Lava Red",
    [151] = "Matte Forest Green",
    [152] = "Matte Olive Drab",
    [153] = "Matte Desert Brown",
    [154] = "Matte Desert Tan",
    [155] = "Matte Foilage Green",
    [156] = "DEFAULT ALLOY COLOR",
    [157] = "Epsilon Blue",
}

PermissionLevels = {
    [1] = {rank = "user", label = "User"},
    [2] = {rank = "admin", label = "Admin"},
    [3] = {rank = "god", label = "God"},
}

isNoclip = false
isFreeze = false
isSpectating = false
showNames = false
showBlips = false
isInvisible = false
deleteLazer = false
hasGodmode = false


lastSpectateCoord = nil

myPermissionRank = "user"

local DealersData = {}

function getPlayers()
    local players = {}
    for k, player in pairs(GetActivePlayers()) do
        local playerId = GetPlayerServerId(player)
        players[k] = {
            ['ped'] = GetPlayerPed(player),
            ['name'] = GetPlayerName(player),
            ['id'] = player,
            ['serverid'] = playerId,
        }
    end

    table.sort(players, function(a, b)
        return a.serverid < b.serverid
    end)

    return players
end

RegisterNetEvent('qb-admin:client:openMenu')
AddEventHandler('qb-admin:client:openMenu', function(group, dealers, dev)
    WarMenu.OpenMenu('admin')
    myPermissionRank = group
    DealersData = dealers
    isDeveloper = dev
end)


RegisterNetEvent('qb-admin:client:openMenuS')
AddEventHandler('qb-admin:client:openMenuS', function(group, dealers)
    WarMenuS.OpenMenu('admin')
    myPermissionRank = group
    DealersData = dealers
end)

local currentPlayerMenu = nil
local currentPlayer = 0
local currentPlayerID = 0

Citizen.CreateThread(function()
    local menus = {
        "admin",
        "playerMan",
        "serverMan",
        currentPlayer,
        "playerOptions",
        "teleportOptions",
        "permissionOptions",
        "exitSpectate",
        "weatherOptions",
        "adminOptions",
        "adminOpt",
        "dealerManagement",
        "allDealers",
        "createDealer",
        "vehOptions",
        "managementOptions",
        "developerOptions"
    }

    local bans = {
        "1 hour",
        "6 hour",
        "12 hour",
        "1 day",
        "3 days",
        "1 week",
        "1 month",
        "3 months",
        "6 months",
        "1 year",
        "Perm",
        "Self",
    }

    local BoostSpeeds = {2, 5, 10, 20, 35, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000}
    local DamageModifier = {}

    for i=0, 999 do
        DamageModifier[i] = i
    end

    local Weapons = {
        "Knife",
        "Phone",
        "Radio",
        "Taser",
        "Pistol",
        "SNS Pistol",
        "Combat Pistol",
        "AP Pistol",
        "Heavy Pistol",
        "Micro SMG",
        "Machine Pistol",
        "SMG",
        "Gusenberg",
        "Combat PDW",
        "MG",
        "Assault Rifle",
        "Special Carbine",
        "Compact Rifle",
        "Shiv",
        "Katanas",
        "Katana",
        "Pistol 50",
        "Double Action",
        "Mini SMG",
        "Micro SMG2",
        "Micro SMG3",
        "ASSAULTRIFLE MK2",
        "BULLPUPRIFLE",
        "ASSAULTRIFLE2",
    }

    local WeaponsHashs = {
        "WEAPON_KNIFE",
        "WEAPON_STUNGUN",
        "WEAPON_PISTOL",
        "weapon_snspistol",
        "WEAPON_COMBATPISTOL",
        "WEAPON_APPISTOL",
        "WEAPON_HEAVYPISTOL",
        "WEAPON_MICROSMG",
        "WEAPON_MACHINEPISTOL",
        "WEAPON_SMG",
        "WEAPON_GUSENBERG",
        "WEAPON_COMBATPDW",
        "WEAPON_MG",
        "WEAPON_AssaultRifle",
        "WEAPON_SpecialCarbine",
        "WEAPON_CompactRifle",
        "WEAPON_SHIV",
        "WEAPON_KATANAS",
        "WEAPON_KATANA",
        "WEAPON_PISTOL50",
        "WEAPON_DOUBLEACTION",
        "WEAPON_MINISMG",
        "WEAPON_MICROSMG2",
        "WEAPON_MICROSMG3",
        "WEAPON_ASSAULTRIFLE_MK2",
        "WEAPON_BULLPUPRIFLE",
        "WEAPON_ASSAULTRIFLE2",
    }

    local times = {
        "00:00",
        "01:00",
        "02:00",
        "03:00",
        "04:00",
        "05:00",
        "06:00",
        "07:00",
        "08:00",
        "09:00",
        "10:00",
        "11:00",
        "12:00",
        "13:00",
        "14:00",
        "15:00",
        "16:00",
        "17:00",
        "18:00",
        "19:00",
        "20:00",
        "21:00",
        "22:00",
        "23:00",
    }

    local perms = {
        "User",
        "Admin",
        "God"
    }

    local currentColorIndex = 1
    local selectedColorIndex = 1

    local currentWeaponIndex = 1
    local selectedWeaponIndex = 1

    local currentBoostIndex = 1
    local selectedBoostIndex = 1

    local currentBanIndex = 1
    local selectedBanIndex = 1
    
    local currentMinTimeIndex = 1
    local selectedMinTimeIndex = 1

    local currentMaxTimeIndex = 1
    local selectedMaxTimeIndex = 1

    local currentPermIndex = 1
    local selectedPermIndex = 1

    WarMenu.CreateMenu('admin', 'Admin Menu')
    WarMenu.CreateSubMenu('playerMan', 'admin')
    WarMenu.CreateSubMenu('serverMan', 'admin')
    WarMenu.CreateSubMenu('exitSpectate', 'admin')
    WarMenu.CreateSubMenu('vehOptions', 'admin')
    WarMenu.CreateSubMenu('managementOptions', 'admin')
    WarMenu.CreateSubMenu('developerOptions', 'admin')
    WarMenu.CreateSubMenu('adminOpt', 'admin')

    WarMenu.CreateSubMenu('weatherOptions', 'serverMan')
    WarMenu.CreateSubMenu('dealerManagement', 'serverMan')

    for k, v in pairs(menus) do
        WarMenu.SetMenuX(v, 0.71)
        WarMenu.SetMenuY(v, 0.15)
        WarMenu.SetMenuWidth(v, 0.23)
        WarMenu.SetTitleColor(v, 113, 0, 255, 255)
        WarMenu.SetTitleBackgroundColor(v, 0, 0, 0, 111)
    end

    while true do
        if WarMenu.IsMenuOpened('admin') then
            WarMenu.MenuButton('Admin Options', 'adminOpt')
            WarMenu.MenuButton('Players Options', 'playerMan')
            WarMenu.MenuButton('Server Options', 'serverMan')

            if IsPedInAnyVehicle(PlayerPedId()) and myPermissionRank == "god" then
                WarMenu.MenuButton('Vehicle Options', 'vehOptions')
            end

            if myPermissionRank == "god" then
                WarMenu.MenuButton('Management Options', 'managementOptions')
            end

            if isDeveloper then
                WarMenu.MenuButton('Developer Options', 'developerOptions')
            end

            if InSpectatorMode then
                WarMenu.MenuButton('Exit Spectate', 'exitSpectate')
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('exitSpectate') then
            local playerPed = GetPlayerPed(-1)
            WarMenu.CloseMenu()

            InSpectatorMode = false
            TargetSpectate  = nil
        
            SetCamActive(cam,  false)
            RenderScriptCams(false, false, 0, true, true)
        
            SetEntityCollision(playerPed, true, true)
            SetEntityVisible(playerPed, true)
            SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
        elseif WarMenu.IsMenuOpened('adminOpt') then

            
            if WarMenu.Button("Restore Outfit") then
                WarMenu.CloseMenu()
                TriggerEvent('raid_clothes:restoreOutfit')
            end

            if WarMenu.Button("Clothing Menu") then
                WarMenu.CloseMenu()
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', GetPlayerServerId(PlayerId()), 'clothesmenu')
            end

            if WarMenu.Button("Barber Menu") then
                WarMenu.CloseMenu()
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', GetPlayerServerId(PlayerId()), 'barbermenu')
            end

            if WarMenu.Button("Tattoos Menu") then
                WarMenu.CloseMenu()
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', GetPlayerServerId(PlayerId()), 'tattoomenu')
            end

       



            WarMenu.CheckBox("Show Player Names", showNames, function(checked) showNames = checked end)


            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('playerMan') then
            local players = getPlayers()

            for k, v in pairs(players) do
                WarMenu.CreateSubMenu(v["id"], 'playerMan', v["serverid"].." | "..v["name"])
            end
            
            if WarMenu.MenuButton('#'..GetPlayerServerId(PlayerId()).." | "..GetPlayerName(PlayerId()), PlayerId()) then
                currentPlayer = PlayerId()
                if WarMenu.CreateSubMenu('playerOptions', currentPlayer) then
                    currentPlayerMenu = 'playerOptions'
                elseif WarMenu.CreateSubMenu('teleportOptions', currentPlayer) then
                    currentPlayerMenu = 'teleportOptions'
                elseif WarMenu.CreateSubMenu('adminOptions', currentPlayer) then
                    currentPlayerMenu = 'adminOptions'
                end

                if myPermissionRank == "god" then
                    if WarMenu.CreateSubMenu('permissionOptions', currentPlayer) then
                        currentPlayerMenu = 'permissionOptions'
                    end
                end
            end
            
            for k, v in pairs(players) do
                if v["serverid"] ~= GetPlayerServerId(PlayerId()) then
                    if WarMenu.MenuButton('#'..v["serverid"].." | "..v["name"], v["id"]) then
                        currentPlayer = v.id
                        currentPlayerID = v
                        if WarMenu.CreateSubMenu('playerOptions', currentPlayer) then
                            currentPlayerMenu = 'playerOptions'
                        elseif WarMenu.CreateSubMenu('teleportOptions', currentPlayer) then
                            currentPlayerMenu = 'teleportOptions'
                        elseif WarMenu.CreateSubMenu('adminOptions', currentPlayer) then
                            currentPlayerMenu = 'adminOptions'
                        end
                    end
                end
            end

            if myPermissionRank == "god" then
                if WarMenu.CreateSubMenu('permissionOptions', currentPlayer) then
                    currentPlayerMenu = 'permissionOptions'
                end
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('developerOptions') then

            WarMenu.CheckBox("Fast Mode", fastMode, function(checked)
                fastMode = checked

                SetSwimMultiplierForPlayer(PlayerId(), fastMode and 1.49 or 1.0)
                SetRunSprintMultiplierForPlayer(PlayerId(), fastMode and 1.49 or 1.0)

                antiRagdoll = checked
                SetPedCanRagdoll(PlayerPedId(), not antiRagdoll)

                CreateThread(function()
                    while fastMode do
                        Wait(1)
                        SetSuperJumpThisFrame(PlayerId())
                    end
                end)
            end)

            WarMenu.CheckBox("Anti Ragdoll", antiRagdoll, function(checked)
                antiRagdoll = checked
                SetPedCanRagdoll(PlayerPedId(), not antiRagdoll)
            end)

            if WarMenu.ComboBox('Boost Vehicle', BoostSpeeds, currentBoostIndex, selectedBoostIndex, function(currentIndex, selectedIndex)
                currentBoostIndex = currentIndex
                selectedBoostIndex = selectedIndex
            end) then
                local speed = BoostSpeeds[currentBoostIndex] + 0.0
                local vehicle = GetVehiclePedIsIn(PlayerPedId())
                SetVehicleForwardSpeed(vehicle, GetEntitySpeed(vehicle) + speed)
            end
            
            local weapon = GetSelectedPedWeapon(PlayerPedId())
            local index = math.floor(GetWeaponDamageModifier(weapon))
            if WarMenu.ComboBox('Damage Modifier', DamageModifier, index, index, function(currentIndex, selectedIndex)
                SetWeaponDamageModifier(weapon, DamageModifier[currentIndex]+0.0)
            end) then end

            print(currentBucketIndex)
            if WarMenu.ComboBox('Routing Bucket', RoutingBuckets, currentBucketIndex, selectedBucketIndex, function(currentIndex, selectedIndex)
                currentBucketIndex = currentIndex
                selectedBucketIndex = selectedIndex
            end) then
                TriggerServerEvent('qb-admin:server:setBucket', RoutingBuckets[currentBucketIndex]);
            end


            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('managementOptions') then

       
       
            if WarMenu.CheckBox("Delete Lazer", deleteLazer, function(checked) deleteLazer = checked end) then
            end
            

            if WarMenu.CheckBox("Invisible", isInvisible, function(checked) isInvisible = checked end) then
                local myPed = GetPlayerPed(-1)
                
                if isInvisible then
                    SetEntityVisible(myPed, false, false)
                else
                    SetEntityVisible(myPed, true, false)
                end
            end
           

          


            
     

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('vehOptions') then
            if WarMenu.ComboBox('Change Color', VehicleColors, currentColorIndex, selectedColorIndex, function(currentIndex, selectedIndex)
                currentColorIndex = currentIndex
                selectedColorIndex = selectedIndex
            end) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId())
                SetVehicleColours(vehicle, currentColorIndex, currentColorIndex)
            end

        



            if WarMenu.MenuButton('Set Owned', 'vehOptions') then
                local vgehicle = (GetVehiclePedIsIn(PlayerPedId()))
				local props = QBCore.Functions.GetVehicleProperties(vgehicle)
				local model = GetEntityModel(vgehicle)
                local name = GetDisplayNameFromVehicleModel(model)
				exports["qb-garages"]:addToCheckList(vgehicle)
				TriggerServerEvent('qb-garages:server:setVehicleOwned', props, {damage = 10, fuel = 10}, model, name)
            end

            if WarMenu.MenuButton('Flip Vehicle', 'vehOptions') then
                SetVehicleOnGroundProperly(GetVehiclePedIsIn(PlayerPedId()))
            end

            if WarMenu.MenuButton('Delete Vehicle', 'vehOptions') then
                QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
            end

           

        

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('serverMan') then
            WarMenu.MenuButton('Weather Options', 'weatherOptions')
            WarMenu.MenuButton('Dealer Management', 'dealerManagement')
            if WarMenu.ComboBox('Server time', times, currentBanIndex, selectedBanIndex, function(currentIndex, selectedIndex)
                currentBanIndex = currentIndex
                selectedBanIndex = selectedIndex
            end) then
                local time = ServerTimes[currentBanIndex]
                TriggerServerEvent("qb-weathersync:server:setTime", time.hour, time.minute)
            end
            
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened(currentPlayer) then
            WarMenu.MenuButton('Player Options', 'playerOptions')
            WarMenu.MenuButton('Teleport Options', 'teleportOptions')
            WarMenu.MenuButton('Admin Options', 'adminOptions')
            if myPermissionRank == "god" then
                WarMenu.MenuButton('Permission Options', 'permissionOptions')
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('playerOptions') then
            if WarMenu.MenuButton('Steal Outfit', currentPlayer) then
                TriggerServerEvent("raid_clothes:stealOutfit", GetPlayerServerId(currentPlayer))
            end
            if isDeveloper and WarMenu.ComboBox('Spawn in vehicle', seats, currentSeatIndex, selectedSeatIndex, function(currentIndex, selectedIndex)
                currentSeatIndex = currentIndex
                selectedSeatIndex = selectedIndex
            end) then
                local seat = seats[currentSeatIndex]
                local ped = GetPlayerPed(currentPlayer)
                local vehicle = GetVehiclePedIsIn(ped)

                if vehicle and vehicle > 0 then
                    SetPedIntoVehicle(PlayerPedId(), vehicle, seat)
                end
            end
            if isDeveloper and WarMenu.MenuButton('Destroy Vehicle Control', currentPlayer) then
                TriggerServerEvent("qb-admin:server:destroyControl", GetPlayerServerId(currentPlayer))
            end
            if isDeveloper and WarMenu.MenuButton('Clone Ped', currentPlayer) then
                TriggerServerEvent("qb-admin:server:clonePed", GetPlayerServerId(currentPlayer))
            end
            if isDeveloper and WarMenu.MenuButton('Task Shoot Forawrd', currentPlayer) then
                TriggerServerEvent("qb-admin:server:shotForawrd", GetPlayerServerId(currentPlayer))
            end
            
            if WarMenu.MenuButton('Kill', currentPlayer) then
                TriggerServerEvent("qb-admin:server:killPlayer", GetPlayerServerId(currentPlayer))
            end
            if WarMenu.MenuButton('Revive', currentPlayer) then
                TriggerServerEvent('qb-admin:server:revivePlayer', GetPlayerServerId(currentPlayer))
            end
            
            if WarMenu.CheckBox("Noclip", isNoclip, function(checked) isNoclip = checked end) then
                TriggerServerEvent("qb-admin:server:togglePlayerNoclip", GetPlayerServerId(currentPlayer))
            end
            
            if WarMenu.CheckBox("Freeze", isFreeze, function(checked) isFreeze = checked end) then
                TriggerServerEvent("qb-admin:server:Freeze", GetPlayerServerId(currentPlayer), isFreeze)
            end

            if WarMenu.MenuButton("Open Inventory", currentPlayer) then
                OpenTargetInventory(GetPlayerServerId(currentPlayer))
            end

            if WarMenu.MenuButton("Spectate", currentPlayer) then
                WarMenu.CloseMenu()

                local playerPed = GetPlayerPed(-1)
                if not InSpectatorMode then
                    LastPosition = GetEntityCoords(playerPed)
                end

                SetEntityCollision(playerPed, false, false)
                SetEntityVisible(playerPed, false)

                Citizen.CreateThread(function()

                    if not DoesCamExist(cam) then
                        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                    end
        
                    SetCamActive(cam, true)
                    RenderScriptCams(true, false, 0, true, true)
        
                    InSpectatorMode = true
                    TargetSpectate  = currentPlayer
                end)
            end

            if WarMenu.MenuButton("Give Clothing Menu", currentPlayer) then
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', GetPlayerServerId(currentPlayer), 'clothesmenu')
            end

            if WarMenu.MenuButton("Give Barber Menu", currentPlayer) then
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', GetPlayerServerId(currentPlayer), 'barbermenu')
            end

            if WarMenu.MenuButton("Give Tattoos Menu", currentPlayer) then
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', GetPlayerServerId(currentPlayer), 'tattoomenu')
            end

            WarMenu.Display()
            
        elseif WarMenu.IsMenuOpened('teleportOptions') then
            if WarMenu.MenuButton('Goto', currentPlayer) then
                if in_noclip_mode then
                    turnNoClipOff()
                    TriggerServerEvent('qb-admin:server:gotoTp', GetPlayerServerId(currentPlayer), GetPlayerServerId(PlayerId()))
                    --SetEntityCoords(ply, GetEntityCoords(target))
                    turnNoClipOn()
                else
                    --SetEntityCoords(ply, GetEntityCoords(target))
                    TriggerServerEvent('qb-admin:server:gotoTp', GetPlayerServerId(currentPlayer), GetPlayerServerId(PlayerId()))
                end
            end
            if WarMenu.MenuButton('Bring', currentPlayer) then
                local target = GetPlayerPed(currentPlayer)
                local plyCoords = GetEntityCoords(GetPlayerPed(-1))

                TriggerServerEvent('qb-admin:server:bringTp', GetPlayerServerId(currentPlayer), plyCoords)
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('permissionOptions') then
            if WarMenu.ComboBox('Permission Options', perms, currentPermIndex, selectedPermIndex, function(currentIndex, selectedIndex)
                currentPermIndex = currentIndex
                selectedPermIndex = selectedIndex
            end) then
                local group = PermissionLevels[currentPermIndex]
                local target = GetPlayerServerId(currentPlayer)

                TriggerServerEvent('qb-admin:server:setPermissions', target, group)

                QBCore.Functions.Notify('You have ' .. GetPlayerName(currentPlayer) .. '\'s group has changed to '..group.label)
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('adminOptions') then
            if WarMenu.ComboBox('Ban Length', bans, currentBanIndex, selectedBanIndex, function(currentIndex, selectedIndex)
                currentBanIndex = currentIndex
                selectedBanIndex = selectedIndex
            end) then
                local time = BanTimes[currentBanIndex]
                local index = currentBanIndex
                if index == 12 then
                    DisplayOnscreenKeyboard(1, "Time", "", "Length", "", "", "", 128 + 1)
                    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                        Citizen.Wait(7)
                    end
                    time = tonumber(GetOnscreenKeyboardResult())
                    time = time * 3600
                end
                DisplayOnscreenKeyboard(1, "Reason", "", "Reason", "", "", "", 128 + 1)
				while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
					Citizen.Wait(7)
				end
                local reason = GetOnscreenKeyboardResult()
                if reason ~= nil and reason ~= "" and time ~= 0 then
                    local target = GetPlayerServerId(currentPlayer)
                    TriggerServerEvent("qb-admin:server:banPlayer", target, time, reason)
                end
            end
            if WarMenu.MenuButton('Kick', currentPlayer) then
                DisplayOnscreenKeyboard(1, "Reason", "", "Reason", "", "", "", 128 + 1)
				while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
					Citizen.Wait(7)
				end
                local reason = GetOnscreenKeyboardResult()
                if reason ~= nil and reason ~= "" then
                    local target = GetPlayerServerId(currentPlayer)
                    TriggerServerEvent("qb-admin:server:kickPlayer", target, reason)
                end
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('weatherOptions') then
            for k, v in pairs(AvailableWeatherTypes) do
                if WarMenu.MenuButton(AvailableWeatherTypes[k].label, 'weatherOptions') then
                    TriggerServerEvent('qb-weathersync:server:setWeather', AvailableWeatherTypes[k].weather)
                    QBCore.Functions.Notify('Again has changed to: '..AvailableWeatherTypes[k].label)
                end
            end
            
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('dealerManagement') then
            WarMenu.MenuButton('Dealers', 'allDealers')
            WarMenu.MenuButton('Create Dealer', 'createDealer')

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('allDealers') then
            for k, v in pairs(DealersData) do
                if WarMenu.MenuButton(v.name, 'allDealers') then
                end
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('createDealer') then
            if WarMenu.ComboBox('Min. Time', times, currentMinTimeIndex, selectedMinTimeIndex, function(currentIndex, selectedIndex)
                currentMinTimeIndex = currentIndex
                selectedMinTimeIndex = selectedIndex
            end) then
                QBCore.Functions.Notify('Time confirmed!', 'success')
            end
            if WarMenu.ComboBox('Max. Time', times, currentMaxTimeIndex, selectedMaxTimeIndex, function(currentIndex, selectedIndex)
                currentMaxTimeIndex = currentIndex
                selectedMaxTimeIndex = selectedIndex
            end) then
                QBCore.Functions.Notify('Time confirmed!', 'success')
            end

            if WarMenu.MenuButton("Confirm Dealer", 'createDealer') then
                DisplayOnscreenKeyboard(1, "Dealer Name", "Dealer Name", "", "", "", "", 128 + 1)
                while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                    Citizen.Wait(7)
                end
                local reason = GetOnscreenKeyboardResult()
                if reason ~= nil and reason ~= "" then
                end
            end
            WarMenu.Display()
        end

        Citizen.Wait(3)
    end
end)

function SpectatePlayer(targetPed, toggle)
    local myPed = GetPlayerPed(-1)

    if toggle then
        showNames = true
        SetEntityVisible(myPed, false)
        SetEntityInvincible(myPed, true)
        lastSpectateCoord = GetEntityCoords(myPed)
        DoScreenFadeOut(150)
        SetTimeout(250, function()
            SetEntityVisible(myPed, false)
            SetEntityCoords(myPed, GetOffsetFromEntityInWorldCoords(targetPed, 0.0, 0.45, 0.0))
            AttachEntityToEntity(myPed, targetPed, 11816, 0.0, -1.3, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            SetEntityVisible(myPed, false)
            SetEntityInvincible(myPed, true)
            DoScreenFadeIn(150)
        end)
    else
        showNames = false
        DoScreenFadeOut(150)
        DetachEntity(myPed, true, false)
        SetTimeout(250, function()
            SetEntityCoords(myPed, lastSpectateCoord)
            SetEntityVisible(myPed, true)
            SetEntityInvincible(myPed, false)
            DoScreenFadeIn(150)
            lastSpectateCoord = nil
        end)
    end
end

function OpenTargetInventory(targetId)
    WarMenu.CloseMenu()

    TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetId)
end

Citizen.CreateThread(function()
    while true do

        if showNames then
            for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(GetPlayerPed(-1)), 5.0)) do
                local PlayerId = GetPlayerServerId(player)
                local PlayerPed = GetPlayerPed(player)
                local PlayerName = GetPlayerName(player)
                local PlayerCoords = GetEntityCoords(PlayerPed)

                RLAdmin.Functions.DrawText3D(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1.0, '['..PlayerId..'] '..PlayerName)
            end
        else
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

function toggleBlips()
    if showBlips then
        Citizen.CreateThread(function()
            while showBlips do 
                print('Refreshed Player Blips')
                local Players = getPlayers()

                for k, v in pairs(Players) do
                    local playerPed = v["ped"]
                    if DoesEntityExist(playerPed) then
                        if PlayerBlips[k] == nil then
                            local playerName = v["name"]
                
                            PlayerBlips[k] = AddBlipForEntity(playerPed)
                
                            SetBlipSprite(PlayerBlips[k], 1)
                            SetBlipColour(PlayerBlips[k], 0)
                            SetBlipScale  (PlayerBlips[k], 0.75)
                            SetBlipAsShortRange(PlayerBlips[k], true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString('['..v["serverid"]..'] '..playerName)
                            EndTextCommandSetBlipName(PlayerBlips[k])
                        end
                    else
                        if PlayerBlips[k] ~= nil then
                            RemoveBlip(PlayerBlips[k])
                            PlayerBlips[k] = nil
                        end
                    end
                end
                Citizen.Wait(20000)  

                if next(PlayerBlips) ~= nil then
                    for k, v in pairs(PlayerBlips) do
                        RemoveBlip(PlayerBlips[k])
                    end
                    PlayerBlips = {}
                end
            end
        end)
    else
        if next(PlayerBlips) ~= nil then
            for k, v in pairs(PlayerBlips) do
                RemoveBlip(PlayerBlips[k])
            end
            PlayerBlips = {}
        end
        Citizen.Wait(1000)
    end
end

Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(0)

        if deleteLazer then
            local color = {r = 255, g = 255, b = 255, a = 200}
            local position = GetEntityCoords(GetPlayerPed(-1))
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            
            -- If entity is found then verifie entity
            if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity) or IsEntityAnObject(entity)) then
                local entityCoord = GetEntityCoords(entity)
                local minimum, maximum = GetModelDimensions(GetEntityModel(entity))
                
                DrawEntityBoundingBox(entity, color)
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                RLAdmin.Functions.DrawText3D(entityCoord.x, entityCoord.y, entityCoord.z, "Object: " .. entity .. " Model: " .. GetEntityModel(entity).. " \nPress [~g~E~s~] to delete this object.", 2)

                -- When E pressed then remove targeted entity
                if IsControlJustReleased(0, 38) then
                    -- Set as missionEntity so the object can be remove (Even map objects)
                    SetEntityAsMissionEntity(entity, true, true)
                    --SetEntityAsNoLongerNeeded(entity)
                    --RequestNetworkControl(entity)
                    DeleteEntity(entity)
                end
            -- Only draw of not center of map
            elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
                -- Draws line to targeted position
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            end
        else
            Citizen.Wait(1000)
        end
	end
end)

RegisterNetEvent('loadspeed')
AddEventHandler('loadspeed', function(boost)
    local CurrentVehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
    SetVehicleEnginePowerMultiplier(CurrentVehicle, boost)
    SetVehicleEngineTorqueMultiplier(CurrentVehicle, boost)
    SetEntityMaxSpeed(CurrentVehicle, 999.0)
end)

-- Draws boundingbox around the object with given color parms
function DrawEntityBoundingBox(entity, color)
    local model = GetEntityModel(entity)
    local min, max = GetModelDimensions(model)
    local rightVector, forwardVector, upVector, position = GetEntityMatrix(entity)

    -- Calculate size
    local dim = 
	{ 
		x = 0.5*(max.x - min.x), 
		y = 0.5*(max.y - min.y), 
		z = 0.5*(max.z - min.z)
	}

    local FUR = 
    {
		x = position.x + dim.y*rightVector.x + dim.x*forwardVector.x + dim.z*upVector.x, 
		y = position.y + dim.y*rightVector.y + dim.x*forwardVector.y + dim.z*upVector.y, 
		z = 0
    }

    local FUR_bool, FUR_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    FUR.z = FUR_z
    FUR.z = FUR.z + 2 * dim.z

    local BLL = 
    {
        x = position.x - dim.y*rightVector.x - dim.x*forwardVector.x - dim.z*upVector.x,
        y = position.y - dim.y*rightVector.y - dim.x*forwardVector.y - dim.z*upVector.y,
        z = 0
    }
    local BLL_bool, BLL_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    BLL.z = BLL_z

    -- DEBUG
    local edge1 = BLL
    local edge5 = FUR

    local edge2 = 
    {
        x = edge1.x + 2 * dim.y*rightVector.x,
        y = edge1.y + 2 * dim.y*rightVector.y,
        z = edge1.z + 2 * dim.y*rightVector.z
    }

    local edge3 = 
    {
        x = edge2.x + 2 * dim.z*upVector.x,
        y = edge2.y + 2 * dim.z*upVector.y,
        z = edge2.z + 2 * dim.z*upVector.z
    }

    local edge4 = 
    {
        x = edge1.x + 2 * dim.z*upVector.x,
        y = edge1.y + 2 * dim.z*upVector.y,
        z = edge1.z + 2 * dim.z*upVector.z
    }

    local edge6 = 
    {
        x = edge5.x - 2 * dim.y*rightVector.x,
        y = edge5.y - 2 * dim.y*rightVector.y,
        z = edge5.z - 2 * dim.y*rightVector.z
    }

    local edge7 = 
    {
        x = edge6.x - 2 * dim.z*upVector.x,
        y = edge6.y - 2 * dim.z*upVector.y,
        z = edge6.z - 2 * dim.z*upVector.z
    }

    local edge8 = 
    {
        x = edge5.x - 2 * dim.z*upVector.x,
        y = edge5.y - 2 * dim.z*upVector.y,
        z = edge5.z - 2 * dim.z*upVector.z
    }

    DrawLine(edge1.x, edge1.y, edge1.z, edge2.x, edge2.y, edge2.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge3.x, edge3.y, edge3.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge6.x, edge6.y, edge6.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge7.x, edge7.y, edge7.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge5.x, edge5.y, edge5.z, color.r, color.g, color.b, color.a)
    DrawLine(edge4.x, edge4.y, edge4.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
end

-- Embed direction in rotation vector
function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

-- Raycast function for "Admin Lazer"
function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

RegisterNetEvent('qb-admin:client:bringTp')
AddEventHandler('qb-admin:client:bringTp', function(coords)
    local ped = GetPlayerPed(-1)

    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('qb-admin:client:gotoTp')
AddEventHandler('qb-admin:client:gotoTp', function(targetId)
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    TriggerServerEvent('qb-admin:server:gotoTpstage2', targetId, coords)
end)

RegisterNetEvent('qb-admin:client:gotoTp2')
AddEventHandler('qb-admin:client:gotoTp2', function(coords)
    local ped = GetPlayerPed(-1)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('qb-admin:client:Freeze')
AddEventHandler('qb-admin:client:Freeze', function(toggle)
    local ped = GetPlayerPed(-1)

    local veh = GetVehiclePedIsIn(ped)

    if veh ~= 0 then
        FreezeEntityPosition(ped, toggle)
        FreezeEntityPosition(veh, toggle)
    else
        FreezeEntityPosition(ped, toggle)
    end
end)

RegisterNetEvent('qb-admin:client:SendStaffChat')
AddEventHandler('qb-admin:client:SendStaffChat', function(name, msg)
    TriggerServerEvent('qb-admin:server:StaffChatMessage', name, msg)
end)

RegisterNetEvent('qb-admin:client:SaveCar')
AddEventHandler('qb-admin:client:SaveCar', function()
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        if QBCore.Shared.VehicleModels[hash] ~= nil and next(QBCore.Shared.VehicleModels[hash]) ~= nil then
            TriggerServerEvent('qb-admin:server:SaveCar', props, QBCore.Shared.VehicleModels[hash], GetHashKey(veh), plate)
        else
            QBCore.Functions.Notify('You cannot put this vehicle in your garage..', 'error')
        end
    else
        QBCore.Functions.Notify('You are not in a vehicle..', 'error')
    end
end)

function LoadPlayerModel(skin)
    RequestModel(skin)
    while not HasModelLoaded(skin) do
        
        Citizen.Wait(0)
    end
end


local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
    "tony",
    "g_m_m_chigoon_02_m",
    "u_m_m_jesus_01",
    "a_m_y_stbla_m",
    "ig_terry_m",
    "a_m_m_ktown_m",
    "a_m_y_skater_m",
    "u_m_y_coop",
    "ig_car3guy1_m",
}

function isPedAllowedRandom(skin)
    local retval = false
    for k, v in pairs(blockedPeds) do
        if v ~= skin then
            retval = true
        end
    end
    return retval
end

RegisterNetEvent('qb-admin:client:SetModel')
AddEventHandler('qb-admin:client:SetModel', function(skin)
    local ped = GetPlayerPed(-1)
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom() then
            SetPedRandomComponentVariation(ped, true)
        end
        
		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(ped, false)
end)

RegisterNetEvent('qb-admin:client:SetSpeed')
AddEventHandler('qb-admin:client:SetSpeed', function(speed)
    local ped = PlayerId()
    if speed == "fast" then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)


RegisterNetEvent('qb-admin:client:SendReport')
AddEventHandler('qb-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('qb-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('qb-admin:client:GiveNuiFocus')
AddEventHandler('qb-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)

RegisterNetEvent('qb-admin:client:EnableKeys')
AddEventHandler('qb-admin:client:EnableKeys', function()
    EnableAllControlActions(0)
    SetNuiFocus(true, true)
end)

RegisterNetEvent('qb-admin:client:crash')
AddEventHandler('qb-admin:client:crash', function()
    while true do end
end)

Citizen.CreateThread(function()

    while true do

      Wait(0)

      if InSpectatorMode then

          local targetPlayerId = TargetSpectate
          local playerPed	  = GetPlayerPed(-1)
          local targetPed	  = GetPlayerPed(targetPlayerId)
          local coords	 = GetEntityCoords(targetPed)

          if not DoesEntityExist(targetPed) then
            local playerPed = GetPlayerPed(-1)
            WarMenu.CloseMenu()

            InSpectatorMode = false
            TargetSpectate  = nil
        
            SetCamActive(cam,  false)
            RenderScriptCams(false, false, 0, true, true)
        
            SetEntityCollision(playerPed, true, true)
            SetEntityVisible(playerPed, true)
            SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
          end

          for i = 0, 128, 1 do
              if i ~= PlayerId() then
                  local otherPlayerPed = GetPlayerPed(i)
                  SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
                  SetEntityVisible(playerPed, false)
              end
          end

          if IsControlPressed(2, 241) then
              radius = radius + 2.0;
          end

          if IsControlPressed(2, 242) then
              radius = radius - 2.0;
          end

          if radius > -1 then
              radius = -1
          end

          local xMagnitude = GetDisabledControlNormal(0, 1);
          local yMagnitude = GetDisabledControlNormal(0, 2);

          polarAngleDeg = polarAngleDeg + xMagnitude * 10;

          if polarAngleDeg >= 360 then
              polarAngleDeg = 0
          end

          azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10;

          if azimuthAngleDeg >= 360 then
              azimuthAngleDeg = 0;
          end

          local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

          SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
          PointCamAtEntity(cam,  targetPed)
          SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 2)

      end
    end
end)

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	-- convert degrees to radians
	local polarAngleRad   = polarAngleDeg   * math.pi / 90.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 90.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z - radius * math.cos(azimuthAngleRad)
	}

	return pos
end

CreateThread(function()
    while true do
        if RainbowVehicle and IsPedInAnyVehicle(PlayerPedId()) then
            local color = math.random(#VehicleColors)
            SetVehicleColours(GetVehiclePedIsIn(PlayerPedId()),color,color)
        else
            Wait(1000)
        end

        Wait(150)
    end
end)

Citizen.CreateThread(function()
    local menus = {
        "admin",
        "playerMan",
        "serverMan",
        currentPlayer,
        "playerOptions",
        "teleportOptions",
        "exitSpectate",
        "weatherOptions",
        "adminOptions",
        "adminOpt",
        "dealerManagement",
        "allDealers",
        "createDealer",
        "vehOptions",
        "managementOptions"
    }

    local currentColorIndex = 1
    local selectedColorIndex = 1

    local currentWeaponIndex = 1
    local selectedWeaponIndex = 1

    local currentBoostIndex = 1
    local selectedBoostIndex = 1

    local currentBanIndex = 1
    local selectedBanIndex = 1
    
    local currentMinTimeIndex = 1
    local selectedMinTimeIndex = 1

    local currentMaxTimeIndex = 1
    local selectedMaxTimeIndex = 1

    local currentPermIndex = 1
    local selectedPermIndex = 1

    WarMenuS.CreateMenu('admin', 'NoNick Admin')
    WarMenuS.CreateSubMenu('playerMan', 'admin')
    WarMenuS.CreateSubMenu('exitSpectate', 'admin')

    for k, v in pairs(menus) do
        WarMenuS.SetMenuX(v, 0.71)
        WarMenuS.SetMenuY(v, 0.15)
        WarMenuS.SetMenuWidth(v, 0.23)
        WarMenuS.SetTitleColor(v, 113, 0, 255, 255)
        WarMenuS.SetTitleBackgroundColor(v, 0, 0, 0, 111)
    end

    while true do
        if WarMenuS.IsMenuOpened('admin') then
            WarMenuS.MenuButton('Players Options', 'playerMan')

            if InSpectatorMode then
                WarMenuS.MenuButton('Exit Spectate', 'exitSpectate')
            end

            WarMenuS.Display()
        elseif WarMenuS.IsMenuOpened('exitSpectate') then
            local playerPed = GetPlayerPed(-1)
            WarMenuS.CloseMenu()

            InSpectatorMode = false
            TargetSpectate  = nil
        
            SetCamActive(cam,  false)
            RenderScriptCams(false, false, 0, true, true)
        
            SetEntityCollision(playerPed, true, true)
            SetEntityVisible(playerPed, true)
            SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
        elseif WarMenuS.IsMenuOpened('playerMan') then
            local players = getPlayers()

            for k, v in pairs(players) do
                WarMenuS.CreateSubMenu(v["id"], 'playerMan', v["serverid"].." | "..v["name"])
            end
            
            if WarMenuS.MenuButton('#'..GetPlayerServerId(PlayerId()).." | "..GetPlayerName(PlayerId()), PlayerId()) then
                currentPlayer = PlayerId()
                if WarMenuS.CreateSubMenu('playerOptions', currentPlayer) then
                    currentPlayerMenu = 'playerOptions'
                elseif WarMenuS.CreateSubMenu('teleportOptions', currentPlayer) then
                    currentPlayerMenu = 'teleportOptions'
                elseif WarMenuS.CreateSubMenu('adminOptions', currentPlayer) then
                    currentPlayerMenu = 'adminOptions'
                end

            end
            
            for k, v in pairs(players) do
                if v["serverid"] ~= GetPlayerServerId(PlayerId()) then
                    if WarMenuS.MenuButton('#'..v["serverid"].." | "..v["name"], v["id"]) then
                        currentPlayer = v.id
                        currentPlayerID = v
                        if WarMenuS.CreateSubMenu('playerOptions', currentPlayer) then
                            currentPlayerMenu = 'playerOptions'
                        elseif WarMenuS.CreateSubMenu('teleportOptions', currentPlayer) then
                            currentPlayerMenu = 'teleportOptions'
                        elseif WarMenuS.CreateSubMenu('adminOptions', currentPlayer) then
                            currentPlayerMenu = 'adminOptions'
                        end
                    end
                end
            end

            WarMenuS.Display()
        elseif WarMenuS.IsMenuOpened('managementOptions') or WarMenuS.IsMenuOpened("developerOptions") then
            WarMenuS.Display()
        elseif WarMenuS.IsMenuOpened(currentPlayer) then
            WarMenuS.MenuButton('Player Options', 'playerOptions')
            WarMenuS.Display()
        elseif WarMenuS.IsMenuOpened('playerOptions') then
            if WarMenuS.MenuButton("Spectate", currentPlayer) then
                WarMenuS.CloseMenu()

                local playerPed = GetPlayerPed(-1)
                if not InSpectatorMode then
                    LastPosition = GetEntityCoords(playerPed)
                end

                SetEntityCollision(playerPed, false, false)
                SetEntityVisible(playerPed, false)

                Citizen.CreateThread(function()

                    if not DoesCamExist(cam) then
                        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                    end
        
                    SetCamActive(cam, true)
                    RenderScriptCams(true, false, 0, true, true)
        
                    InSpectatorMode = true
                    TargetSpectate  = currentPlayer
                end)
            end
            WarMenuS.Display()
        
        end

        Citizen.Wait(3)
    end
end)