local HandleToggleCommand
HandleToggleCommand = function(Split, Player)
  if (Player:HasPermission("portal.create") == true) then
    local playerData = DATA.players[Player:GetName()]
    if playerData.HasToolEnabled == true then
      playerData.HasToolEnabled = false
      Player:SendMessage("Your wooden sword will now act as usual")
    else
      playerData.HasToolEnabled = true
      Player:SendMessage("Your wooden sword will now select portal entrance zone")
    end
  end
  return true
end
local HandleMakeWarpCommand
HandleMakeWarpCommand = function(Split, Player)
  if (Player:HasPermission("portal.create") == false) then
    Player:SendMessage("You're not allowed to create warps")
    return true
  end
  if #Split < 2 then
    Player:SendMessage("Usage: " .. Split[1] .. " <id>")
    return true
  end
  local portalName = Split[2]
  local playerData = DATA.players[Player:GetName()]
  if DATA.portals[portalName] then
    Player:SendMessage('There already is a warp, named "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '"')
    return true
  end
  if (playerData.point1 == nil or playerData.point2 == nil) then
    Player:SendMessage("The portal volume can't be empty!")
    return true
  end
  local point1 = playerData.point1
  local point2 = playerData.point2
  DATA.portals[portalName] = { }
  local portalData = DATA.portals[portalName]
  portalData.world = Player:GetWorld():GetName()
  portalData.target = { }
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
  Player:SendMessage('Warp "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '" created!')
  return true
end
local HandleMakeDestinationCommand
HandleMakeDestinationCommand = function(Split, Player)
  if #Split < 2 then
    Player:SendMessage("Usage: " .. Split[1] .. " <id>")
    return true
  end
  local portalName = Split[2]
  local portalData = DATA.portals[portalName]
  if portalData == nil then
    Player:SendMessage('The id "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '" doesn\'t exist!')
    return true
  end
  portalData.destination_x = Player:GetPosX()
  portalData.destination_y = Player:GetPosY()
  portalData.destination_z = Player:GetPosZ()
  Player:SendMessage('Destination for Portal ID "' .. cChatColor.LightBlue .. portalName .. cChatColor.White .. '" created!')
  return true
end
HandleConnectCmd(Split, Player)(function()
  if #Split < 3 then
    Player:SendMessage("Usage: " .. Split[1] .. " <id> <target_id>")
  end
  local portal1Name = Split[2]
  local portal2Name = Split[3]
  if portal1Name == portal2Name then
    Player:SendMessage('You can\'t set the target as itself!')
    return true
  end
  local portalData = DATA.portals[portal1Name]
  if not DATA.portals[portal2Name] then
    Player:SendMessage('The id "' .. cChatColor.LightBlue .. portal2Name .. cChatColor.White .. '" doesn\'t exist!')
    return true
  end
  if not portalData then
    Player:SendMessage('The id "' .. cChatColor.LightBlue .. portal1Name .. cChatColor.White .. '" doesn\'t exist!')
    return true
  end
  if includes(portalData.target, portal2Name) then
    local index = find(portalData.target, portal2Name)
    table.remove(portalData.target, index)
    Player:SendMessage(portal2Name .. " removed from targets")
  else
    table.insert(portalData.target, portal2Name)
    Player:SendMessage('Entrance from "' .. cChatColor.LightBlue .. portal1Name .. cChatColor.White .. '" to "' .. cChatColor.LightBlue .. portal2Name .. cChatColor.White .. '" created!')
  end
  return true
end)
local HandleHelpCmd
HandleHelpCmd = function(Split, Player)
  if #Split == 1 then
    local _ = Player / SendMessage("Valid commands:")
    _ = Player / SendMessage("---------------")
    for k, v in pairs(g_PluginInfo.Commands) do
      Player:SendMessage(k)
    end
    return true
  end
  local command = "/" .. Split[2]
  if g_PluginInfo.Commands[command] == nil then
    Player:SendMessage("Must provide valid command name")
    return true
  end
  local commandConfig = g_PluginInfo.Commands[command]
  Player:SendMessage("---------------")
  Player:SendMessage("Command: " .. command)
  Player:SendMessage(commandConfig.HelpString)
  if commandConfig.ParameterCombinations ~= nil then
    Player:SendMessage("valid argument combinations:")
    for i, v in ipairs(commandConfig.ParameterCombinations) do
      local params = v.Params ~= "" and v.Params or "no args"
      Player:SendMessage(cChatColor.LightBlue .. "params: " .. cChatColor.LightGreen .. params)
      Player:SendMessage(v.Help)
    end
  end
  Player:SendMessage("---------------")
  return true
end
local HandleInfoCmd
HandleInfoCmd = function(Split, Player)
  local arg = Split[2]
  if not arg then
    listPortals(Split, Player)
    return true
  elseif findKey(DATA.portals, arg) then
    listPortalDetails(Split, Player)
    return true
  elseif (findKey(DATA.players, arg) or arg == "me") then
    listPlayerDetails(Split, Player)
    return true
  end
  Player:SendMessage(cChatColor.Red .. "you must supply a valid portal/player name")
  return true
end
local handleManageCmd
handleManageCmd = function(Split, Player)
  local command = Split[2]
  local portal = Split[3]
  if portal == nil then
    Player:SendMessage("you must supply portal name or specify 'all'")
    return true
  end
  if command ~= "enable" and command ~= "disable" then
    Player:SendMessage("Valid sub-commands are: enable, disable")
    return true
  end
  if portal == "all" then
    toggleAllPortalsdisabled(command, Player)
    return true
  end
  toggleDisablePortal(command, portal, Player)
  return true
end
local HandleTeleport
HandleTeleport = function(Split, Player)
  local portalName = playerInAPortal(Player)
  if portalName then
    local currentPortal = DATA.portals[portalName]
    local targetName = Split[2]
    if targetName == nil then
      Player:SendMessage("portal option not provided")
      return true
    end
    if not includes(currentPortal.target, targetName) then
      Player:SendMessage("Not a valid option.")
      Player:SendMessage("Choose from: " .. arrayTableToString(currentPortal.target))
      return true
    end
    if targetPortalHasNoDest(DATA.portals[targetName]) then
      Player:SendMessage(cChatColor.Red .. targetName .. " Does not have a destination set")
      return true
    end
    local playerName = Player:GetName()
    local playerData = DATA.players[playerName]
    playerData.targetPortalName = targetName
    playerData.state = PLAYER_STATES.TELEPORTING
    teleportPlayer(Player)
  end
  return true
end
