HandleToggleCommand = (Split, Player) ->
    if (Player\HasPermission("portal.create") == true)
        playerData = DATA.players[Player\GetName()]

        if playerData.HasToolEnabled == true
            playerData.HasToolEnabled = false
            Player\SendMessage("Your wooden sword will now act as usual")
        else
            playerData.HasToolEnabled = true
            Player\SendMessage("Your wooden sword will now select portal entrance zone")
            
    return true

HandleMakeWarpCommand = (Split, Player) ->
    if (Player\HasPermission("portal.create") == false)
        Player\SendMessage("You're not allowed to create warps")
        return true

    if #Split < 2
        Player\SendMessage("Usage: "..Split[1].." <id>")
        return true

    portalName = Split[2]
    playerData = DATA.players[Player\GetName()]

    if DATA.portals[portalName] -- if portal name taken
        Player\SendMessage('There already is a warp, named "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '"')
        return true

    if (playerData.point1 == nil or playerData.point2 == nil)
        Player\SendMessage("The portal volume can't be empty!")
        return true

    point1 = playerData.point1
    point2 = playerData.point2
    DATA.portals[portalName] = {}
    portalData = DATA.portals[portalName]

    portalData.world = Player\GetWorld()\GetName()
    portalData.target = {}
    portalData.point1_x = point1.x
    portalData.point1_y = point1.y
    portalData.point1_z = point1.z
    portalData.point2_x = point2.x
    portalData.point2_y = point2.y
    portalData.point2_z = point2.z
    portalData.destination_x = 0
    portalData.destination_y = 0
    portalData.destination_z = 0
    portalData.disabled = false

    Player\SendMessage('Warp "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '" created!')

    return true

HandleMakeDestinationCommand = (Split, Player) ->
    if #Split < 2
        Player\SendMessage("Usage: "..Split[1].." <id>")
        return true

    portalName = Split[2]
    portalData = DATA.portals[portalName]

    if portalData == nil
        Player\SendMessage('The id "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '" doesn\'t exist!')
        return true

    portalData.destination_x = Player\GetPosX()
    portalData.destination_y = Player\GetPosY()
    portalData.destination_z = Player\GetPosZ()

    Player\SendMessage('Destination for Portal ID "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '" created!')

    return true

HandleConnectCmd(Split, Player) ->
    if #Split < 3
        Player\SendMessage("Usage: "..Split[1].." <id> <target_id>")

    portal1Name = Split[2]
    portal2Name = Split[3]

    if portal1Name == portal2Name
        Player\SendMessage('You can\'t set the target as itself!')
        return true

    portalData = DATA.portals[portal1Name]
    if not DATA.portals[portal2Name]
        Player\SendMessage('The id "' .. cChatColor.LightBlue .. portal2Name ..
            cChatColor.White .. '" doesn\'t exist!')
        return true

    if not portalData
        Player\SendMessage('The id "' .. cChatColor.LightBlue ..
            portal1Name .. cChatColor.White .. '" doesn\'t exist!')
        return true

    if includes(portalData.target, portal2Name) -- remove from targets
        index = find(portalData.target, portal2Name)
        table.remove(portalData.target, index)
        Player\SendMessage(portal2Name .. " removed from targets")
    else -- add to targets
        table.insert(portalData.target, portal2Name)
        Player\SendMessage('Entrance from "' .. cChatColor.LightBlue ..
            portal1Name .. cChatColor.White .. '" to "' ..
            cChatColor.LightBlue .. portal2Name .. cChatColor.White .. '" created!')

    return true


HandleHelpCmd = (Split, Player) ->
    -- list available commands
    if #Split == 1
        Player/SendMessage("Valid commands:")
        Player/SendMessage("---------------")
        for k, v in pairs(g_PluginInfo.Commands)
            Player\SendMessage(k)

        return true

    command = "/" .. Split[2]
    if g_PluginInfo.Commands[command] == nil
        Player\SendMessage("Must provide valid command name")
        return true

    -- print help for a specific command
    commandConfig = g_PluginInfo.Commands[command]
    Player\SendMessage("---------------")
    Player\SendMessage("Command: " .. command)
    Player\SendMessage(commandConfig.HelpString)
    if commandConfig.ParameterCombinations ~= nil
        Player\SendMessage("valid argument combinations:")
        for i, v in ipairs(commandConfig.ParameterCombinations)
            params = v.Params ~= "" and v.Params or "no args"
            Player\SendMessage(cChatColor.LightBlue .. "params: " ..
                cChatColor.LightGreen .. params)
            Player\SendMessage(v.Help)

    Player\SendMessage("---------------")
    return true


HandleInfoCmd = (Split, Player) ->
    arg = Split[2]
    if not arg
        listPortals(Split, Player)
        return true
    elseif findKey(DATA.portals, arg)
        listPortalDetails(Split, Player)
        return true
    elseif (findKey(DATA.players, arg) or arg == "me")
        listPlayerDetails(Split, Player)
        return true

    -- default to error message
    Player\SendMessage(cChatColor.Red .. "you must supply a valid portal/player name")
    return true


handleManageCmd = (Split, Player) ->
    command = Split[2]
    portal = Split[3]

    if portal == nil
        Player\SendMessage("you must supply portal name or specify 'all'")
        return true

    if command ~= "enable" and command ~= "disable"
        Player\SendMessage("Valid sub-commands are: enable, disable")
        return true

    if portal == "all"
        toggleAllPortalsdisabled(command, Player)
        return true

    toggleDisablePortal(command, portal, Player)
    return true


HandleTeleport = (Split, Player) ->
    portalName = playerInAPortal(Player)
    if portalName
        currentPortal = DATA.portals[portalName]
        targetName = Split[2]
        if targetName == nil
            Player\SendMessage("portal option not provided")
            return true

        if not includes(currentPortal.target, targetName)
            Player\SendMessage("Not a valid option.")
            Player\SendMessage("Choose from: " .. arrayTableToString(currentPortal.target))
            return true

        if targetPortalHasNoDest(DATA.portals[targetName]) then
            Player\SendMessage(cChatColor.Red .. targetName .. " Does not have a destination set")
            return true

        playerName = Player\GetName()
        playerData = DATA.players[playerName]

        playerData.targetPortalName = targetName
        playerData.state = PLAYER_STATES.TELEPORTING
        teleportPlayer(Player)  -- !!!!!!!! need to pass in the target portal here

    return true

