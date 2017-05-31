local onPlayerMoving
onPlayerMoving = function(Player)
  local playerName = Player:GetName()
  local playerData = DATA.players[playerName]
  local portalName = playerInAPortal(Player)
  if portalName then
    local portalData = DATA.portals[portalName]
    local targetPortals = portalData.target
    if (playerData.state == PLAYER_STATES.PORTAL_NOT_SETUP or playerData.state == PLAYER_STATES.IN_DISABLED_PORTAL or DATA.all_portals_disabled or playerData.state == PLAYER_STATES.SELECTING_DEST) then
      return false
    end
    if portalData.disabled == true then
      Player:SendMessage(cChatColor.Red .. "portal: " .. portalName .. " is disabled")
      playerData.state = PLAYER_STATES.IN_DISABLED_PORTAL
      return false
    end
    if #targetPortals == 0 then
      Player:SendMessage(cChatColor.Red .. "Portal " .. portalName .. " doesn't lead anywhere!")
      playerData.state = PLAYER_STATES.PORTAL_NOT_SETUP
      return false
    end
    if #targetPortals == 1 and targetPortalHasNoDest(DATA.portals[targetPortals[1]]) then
      Player:SendMessage(cChatColor.Red .. "Portal " .. targetPortals[1] .. " does not have a destination point set")
      playerData.state = PLAYER_STATES.PORTAL_NOT_SETUP
      return false
    end
    if #targetPortals > 1 then
      Player:SendMessage(cChatColor.LightBlue .. "portal " .. portalName)
      Player:SendMessage(cChatColor.LightBlue .. "Select a destination from: " .. arrayTableToString(targetPortals))
      Player:SendMessage(cChatColor.LightBlue .. "use: '/pteleport <destination>'")
      playerData.state = PLAYER_STATES.SELECTING_DEST
      return false
    end
    if playerData.state == PLAYER_STATES.NOT_IN_PORTAL then
      Player:SendMessage(cChatColor.LightBlue .. "portal: " .. portalName)
      local stand_still = tostring(cChatColor.LightBlue) .. "Stand still for a few seconds for teleportation"
      Player:SendMessage(stand_still)
      playerData.portal_timer = GetTime() + PORTAL_ACTIVATION_TIME
      playerData.state = PLAYER_STATES.WAITING
      playerData.targetPortalName = targetPortals[1]
    end
    if playerData.state == PLAYER_STATES.WAITING then
      if GetTime() > playerData.portal_timer then
        playerData.state = PLAYER_STATES.TELEPORTING
        teleportPlayer(Player, playerData)
        return true
      end
    end
  else
    if playerData.state == PLAYER_STATES.WAITING then
      Player:SendMessage(cChatColor.Red .. "You have left teleportation zone")
    end
    playerData.state = PLAYER_STATES.NOT_IN_PORTAL
    playerData.targetPortalName = ""
  end
  return false
end
local onEntityChangedWorld
onEntityChangedWorld = function(Entity, World)
  if Entity:IsPlayer() then
    local playerName = Entity:GetName()
    local playerData = DATA.players[playerName]
    if playerData.HasTeleportedToWorld then
      local portalName = playerData.targetPortalName
      local targetPortal = DATA.portals[portalName]
      Entity:TeleportToCoords(targetPortal.destination_x, targetPortal.destination_y, targetPortal.destination_z)
      local message = "You have been teleported!"
      Entity:SendMessage(cChatColor.Yellow .. message)
      playerData.targetPortalName = ""
      playerData.HasTeleportedToWorld = false
    end
  end
  return false
end
local onPlayerBreakingBlock
onPlayerBreakingBlock = function(Player, IN_x, IN_y, IN_z, BlockFace, Status, OldBlock, OldMeta)
  local playerName = Player:GetName()
  local playerData = DATA.players[playerName]
  if (Player:HasPermission("portal.create") == true and playerData["HasToolEnabled"] == true) then
    if playerData.isSelectingPoint2 then
      if ItemToString(Player:GetEquippedItem()) == "woodsword" then
        if (playerData.point1.x == IN_x and playerData.point1.y == IN_y and playerData.point1.z == IN_z) then
          return true
        end
        playerData.point2.x = IN_x
        playerData.point2.y = IN_y
        playerData.point2.z = IN_z
        Player:SendMessage(portalPointSelectMessage("Point 2", IN_x, IN_y, IN_z))
        playerData.isSelectingPoint2 = false
        return true
      end
    else
      if (ItemToString(Player:GetEquippedItem()) == "woodsword") then
        if (playerData.point2.x == IN_x and playerData.point2.y == IN_y and playerData.point2.z == IN_z) then
          return true
        end
        playerData.point1.x = IN_x
        playerData.point1.y = IN_y
        playerData.point1.z = IN_z
        Player:SendMessage(portalPointSelectMessage("Point 1", IN_x, IN_y, IN_z))
        Player:SendMessage(cChatColor.LightBlue .. "Now select point 2.")
        playerData.isSelectingPoint2 = true
        return true
      end
    end
  end
  return false
end
local onPlayerJoin
onPlayerJoin = function(Player)
  local playerName = Player:GetName()
  if DATA.players[playerName] == nil then
    DATA.players[playerName] = {
      portal_timer = 0,
      targetPortalName = "",
      HasToolEnabled = false,
      HasTeleportedToWorld = false,
      isSelectingPoint2 = false,
      point2 = Vector3i(),
      point1 = Vector3i(),
      state = PLAYER_STATES.NOT_IN_PORTAL
    }
  end
end
local onPlayerDestroyed
onPlayerDestroyed = function(Player)
  local playerName = Player:GetName()
  if DATA.players[playerName] then
    DATA.players[playerName] = nil
  end
end
