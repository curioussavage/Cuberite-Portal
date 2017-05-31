onPlayerMoving = (Player) ->
    playerName = Player\GetName()
    playerData = DATA.players[playerName]
    portalName = playerInAPortal(Player) -- only returns result when player is in portal area

    if portalName
        portalData = DATA.portals[portalName]
        targetPortals = portalData.target
        -- check if we already set state to PORTAL_NOT_SETUP or IN_DISABLED_PORTAL
        if (playerData.state == PLAYER_STATES.PORTAL_NOT_SETUP or
            playerData.state == PLAYER_STATES.IN_DISABLED_PORTAL or 
            DATA.all_portals_disabled or 
            playerData.state == PLAYER_STATES.SELECTING_DEST)
                return false

        if portalData.disabled == true
            Player\SendMessage(cChatColor.Red .. "portal: " .. portalName .. " is disabled")
            playerData.state = PLAYER_STATES.IN_DISABLED_PORTAL
            return false

        -- check if the portal is not set up
        if #targetPortals == 0
            Player\SendMessage(cChatColor.Red .. "Portal " .. portalName .. " doesn't lead anywhere!")
            playerData.state = PLAYER_STATES.PORTAL_NOT_SETUP
            return false

        if #targetPortals == 1 and targetPortalHasNoDest(DATA.portals[targetPortals[1]])
            Player\SendMessage(cChatColor.Red .. "Portal " .. targetPortals[1] .. " does not have a destination point set")
            playerData.state = PLAYER_STATES.PORTAL_NOT_SETUP
            return false

        if #targetPortals > 1
            Player\SendMessage(cChatColor.LightBlue .. "portal " .. portalName)
            Player\SendMessage(cChatColor.LightBlue .. "Select a destination from: " .. arrayTableToString(targetPortals))
            Player\SendMessage(cChatColor.LightBlue .. "use: '/pteleport <destination>'")
            playerData.state = PLAYER_STATES.SELECTING_DEST
            return false

        -- check if player just entered
        if playerData.state == PLAYER_STATES.NOT_IN_PORTAL
            Player\SendMessage(cChatColor.LightBlue .. "portal: " .. portalName)
            stand_still = "#{cChatColor.LightBlue}Stand still for a few seconds for teleportation"
            Player\SendMessage(stand_still)
            playerData.portal_timer = GetTime() + PORTAL_ACTIVATION_TIME
            playerData.state = PLAYER_STATES.WAITING
            playerData.targetPortalName = targetPortals[1]

        if playerData.state == PLAYER_STATES.WAITING
            if GetTime() > playerData.portal_timer
                playerData.state = PLAYER_STATES.TELEPORTING
                teleportPlayer(Player, playerData)
                return true
    else
        if playerData.state == PLAYER_STATES.WAITING
            Player\SendMessage(cChatColor.Red .. "You have left teleportation zone")

        playerData.state = PLAYER_STATES.NOT_IN_PORTAL
        playerData.targetPortalName = ""

    return false


onEntityChangedWorld = (Entity, World) ->
    -- this will teleport the player to the desired location after changing worlds
    if Entity\IsPlayer()
        playerName = Entity\GetName()
        playerData = DATA.players[playerName]
        if playerData.HasTeleportedToWorld
            portalName = playerData.targetPortalName
            targetPortal = DATA.portals[portalName]

            Entity\TeleportToCoords(targetPortal.destination_x,
                                                            targetPortal.destination_y,
                                                            targetPortal.destination_z)
            message = "You have been teleported!"
            Entity\SendMessage(cChatColor.Yellow .. message)

            playerData.targetPortalName = ""
            playerData.HasTeleportedToWorld = false

    return false


onPlayerBreakingBlock = (Player, IN_x, IN_y, IN_z, BlockFace, Status, OldBlock, OldMeta) ->
    playerName = Player\GetName()
    playerData = DATA.players[playerName]

    if (Player\HasPermission("portal.create") == true and
            playerData["HasToolEnabled"] == true)
        if playerData.isSelectingPoint2
            if ItemToString(Player\GetEquippedItem()) == "woodsword"
                if (playerData.point1.x == IN_x and 
                        playerData.point1.y == IN_y and
                        playerData.point1.z == IN_z)
                    -- on slow connections the server can get two of these events when the player clicks which means point1/point2
                    -- get selected right after one another and effectively makes it impossible to select point2
                    return true

                playerData.point2.x = IN_x
                playerData.point2.y = IN_y
                playerData.point2.z = IN_z
                Player\SendMessage(portalPointSelectMessage("Point 2", IN_x, IN_y, IN_z))
                playerData.isSelectingPoint2 = false
                return true
        else
            if (ItemToString(Player\GetEquippedItem()) == "woodsword")
                if (playerData.point2.x == IN_x and
                        playerData.point2.y == IN_y and
                        playerData.point2.z == IN_z)
                    -- see note above. this is used for the second playerbreaking event when selecting the point2
                    return true

                playerData.point1.x = IN_x
                playerData.point1.y = IN_y
                playerData.point1.z = IN_z
                Player\SendMessage(portalPointSelectMessage("Point 1", IN_x, IN_y, IN_z))
                Player\SendMessage(cChatColor.LightBlue .. "Now select point 2.")
                playerData.isSelectingPoint2 = true
                return true

    return false


onPlayerJoin = (Player) ->
    playerName = Player\GetName()
    if DATA.players[playerName] == nil
        DATA.players[playerName] = {
            portal_timer: 0,
            targetPortalName: "",
            HasToolEnabled: false,
            HasTeleportedToWorld: false,
            isSelectingPoint2: false,
            point2: Vector3i(),
            point1: Vector3i(),
            state: PLAYER_STATES.NOT_IN_PORTAL,
        }


onPlayerDestroyed = (Player) ->
    playerName = Player\GetName()
    if DATA.players[playerName]
        DATA.players[playerName] = nil
        