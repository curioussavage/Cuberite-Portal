listPortals = (Split, Player) ->
    Player\SendMessage("name -> target")
    Player\SendMessage("--------------")
    for k, v in pairs(DATA.portals)
        Player\SendMessage(k .. " -> " .. arrayTableToString(DATA.portals[k].target))

    return true


listPortalDetails = (Split, Player) ->
    portalName = Split[2]
    portalData = DATA.portals[portalName]

    destPoints = getPoints("destination", portalData)
    point1 = getPoints("point1", portalData)
    point2 = getPoints("point2", portalData)

    Player\SendMessage("portal: " .. portalName)
    Player\SendMessage("--------------")
    Player\SendMessage("disabled = " .. tostring(portalData.disabled))
    Player\SendMessage("target = " .. arrayTableToString(portalData.target))
    Player\SendMessage("world = " .. portalData.world)
    Player\SendMessage("dest = " .. destPoints.x .. ", " .. destPoints.y .. ", " .. destPoints.z)
    Player\SendMessage("point 1 = " .. point1.x .. ", " .. point1.y .. ", " .. point1.z)
    Player\SendMessage("point 2 = " .. point2.x .. ", " .. point2.y .. ", " .. point2.z)
    Player\SendMessage("--------------")
    return true


listPlayerDetails = (Split, Player) ->
    -- for debugging
    playerName = Split[2]
    if Split[2] == "me"
        playerName = Player\GetName()

    playerData = DATA.players[playerName]

    Player\SendMessage("Current player data: ")
    for k, v in pairs(playerData)
        Player\SendMessage(k .. ": " .. tostring(v))

    return true


toggleDisablePortal = (command, portal, Player) ->
    portalData = DATA.portals[portal]

    if portalData
        if command == "disable"
            portalData.disabled = true
            Player/SendMessage("portal " .. portal .. " disabled")
        elseif command == "enable"
            portalData.disabled = false
            Player/SendMessage("portal " .. portal .. " Enabled")
    else
        Player\SendMessage("portal " .. portal .. " does not exist")

    return true


toggleAllPortalsdisabled = (command, Player) ->
    color = cChatColor.Red
    if command == "enable"
        DATA.all_portals_disabled = false
        color = cChatColor.LightBlue
    elseif command == "disable"
        DATA.all_portals_disabled = true

    Player\SendMessage(color .. "All portals are now " .. command .. "d")
    return true


portalPointSelectMessage = (label, x, y, z) ->
    { LightGreen: G, White: W } = cChatColor
    return "#{label} (#{G}#{x}#{W}, #{G}#{y}#{W}, #{G}#{z})"


portalIniToTable = (Portalini) ->
    PortalsData = {}
    warpNum = Portalini\GetNumKeys()
    if warpNum > 0
        for i=0, warpNum - 1
            portalName = Portalini\GetKeyName(i)
            PortalsData[portalName] = {}
            portalData = PortalsData[portalName]

            portalData["world"] = Portalini\GetValue( portalName , "world")
            portalData["target"] = StringSplit(Portalini\GetValue( portalName , "target"), ",")
            portalData["point1_x"] = Portalini\GetValueI( portalName , "point1_x")
            portalData["point1_y"] = Portalini\GetValueI( portalName , "point1_y")
            portalData["point1_z"] = Portalini\GetValueI( portalName , "point1_z")
            portalData["point2_x"] = Portalini\GetValueI( portalName , "point2_x")
            portalData["point2_y"] = Portalini\GetValueI( portalName , "point2_y")
            portalData["point2_z"] = Portalini\GetValueI( portalName , "point2_z")
            portalData["destination_x"] = Portalini\GetValueI( portalName , "destination_x")
            portalData["destination_y"] = Portalini\GetValueI( portalName , "destination_y")
            portalData["destination_z"] = Portalini\GetValueI( portalName , "destination_z")
            portalData["disabled"] = intToBool(Portalini\GetValueI( portalName , "disabled"))

    return PortalsData


portalDataToIni = () ->
    ini = DATA.portalIniFile
    for key, val in pairs(DATA.portals)
        portalData = DATA.portals[key]
        if ini\FindKey(key)
             ini\SetValue( key , "world", portalData["world"])
             ini\SetValue( key , "target", arrayTableToString(portalData["target"]))
             ini\SetValueI( key , "point1_x", portalData["point1_x"])
             ini\SetValueI( key , "point1_y", portalData["point1_y"])
             ini\SetValueI( key , "point1_z", portalData["point1_z"])
             ini\SetValueI( key , "point2_x", portalData["point2_x"])
             ini\SetValueI( key , "point2_y", portalData["point2_y"])
             ini\SetValueI( key , "point2_z", portalData["point2_z"])
             ini\SetValueI( key , "destination_x", portalData["destination_x"])
             ini\SetValueI( key , "destination_y", portalData["destination_y"])
             ini\SetValueI( key , "destination_z", portalData["destination_z"])
             ini\SetValueI( key , "disabled", boolToInt( portalData["disabled"]))
        else
            ini\AddKeyName(key)
            ini\AddValue( key , "world", portalData["world"])
            ini\AddValue( key , "target", arrayTableToString(portalData["target"]))
            ini\AddValueI( key , "point1_x", portalData["point1_x"])
            ini\AddValueI( key , "point1_y", portalData["point1_y"])
            ini\AddValueI( key , "point1_z", portalData["point1_z"])
            ini\AddValueI( key , "point2_x", portalData["point2_x"])
            ini\AddValueI( key , "point2_y", portalData["point2_y"])
            ini\AddValueI( key , "point2_z", portalData["point2_z"])
            ini\AddValueI( key , "destination_x", portalData["destination_x"])
            ini\AddValueI( key , "destination_y", portalData["destination_y"])
            ini\AddValueI( key , "destination_z", portalData["destination_z"])
            ini\AddValueI( key , "disabled", boolToInt( portalData["disabled"]))

    -- remove deleted
    numKeys = ini\GetNumKeys()
    for i=0, numKeys - 1
        portalName = ini\GetKeyName(i)
        if not DATA.portals[portalName]
            ini\DeleteKey(portalName)


playerInAPortal = (Player) ->
    _check_cuboid = cCuboid()
    _player_pos = Player\GetPosition()
    _player_pos.x = math.floor(_player_pos.x)
    _player_pos.y = math.floor(_player_pos.y)
    _player_pos.z = math.floor(_player_pos.z)

    for k,v in pairs(DATA.portals)
        if (v["target"])
            if (v["world"] == Player\GetWorld()\GetName())
                vector1 = Vector3i()
                vector2 = Vector3i()

                vector1.x = v["point1_x"]
                vector1.y = v["point1_y"]
                vector1.z = v["point1_z"]

                vector2.x = v["point2_x"]
                vector2.y = v["point2_y"]
                vector2.z = v["point2_z"]

                _check_cuboid.p1 = vector1
                _check_cuboid.p2 = vector2
                _check_cuboid\Sort()

                if (_check_cuboid\IsInside(_player_pos))
                    return k

    return false


targetPortalHasNoDest = (targetPortal) ->
    { :destination_x, :destination_y, :destination_z } = targetPortal
    if targetPortal ~= nil and
      (destination_x == 0 and
      destination_y == 0 and
      destination_z == 0)
        return true

    return false


teleportPlayer = (Player) ->
    playerData = DATA.players[Player\GetName()]
    portalData = DATA.portals[playerData.targetPortalName]

    world = Player\GetWorld()
    if world\GetName() ~= portalData.world
        playerData.HasTeleportedToWorld = true
        Player\MoveToWorld(portalData.world)
    else
        { :destination_x, :destination_y, :destination_z } = portalData
        Player\TeleportToCoords(destination_x, destination_y, destination_z)
        playerData.targetPortalName = ""

        Player\SendMessage(cChatColor.Yellow .. "You have been teleported!")
