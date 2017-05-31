local listPortals
listPortals = function(Split, Player)
  Player:SendMessage("name -> target")
  Player:SendMessage("--------------")
  for k, v in pairs(DATA.portals) do
    Player:SendMessage(k .. " -> " .. arrayTableToString(DATA.portals[k].target))
  end
  return true
end
local listPortalDetails
listPortalDetails = function(Split, Player)
  local portalName = Split[2]
  local portalData = DATA.portals[portalName]
  local destPoints = getPoints("destination", portalData)
  local point1 = getPoints("point1", portalData)
  local point2 = getPoints("point2", portalData)
  Player:SendMessage("portal: " .. portalName)
  Player:SendMessage("--------------")
  Player:SendMessage("disabled = " .. tostring(portalData.disabled))
  Player:SendMessage("target = " .. arrayTableToString(portalData.target))
  Player:SendMessage("world = " .. portalData.world)
  Player:SendMessage("dest = " .. destPoints.x .. ", " .. destPoints.y .. ", " .. destPoints.z)
  Player:SendMessage("point 1 = " .. point1.x .. ", " .. point1.y .. ", " .. point1.z)
  Player:SendMessage("point 2 = " .. point2.x .. ", " .. point2.y .. ", " .. point2.z)
  Player:SendMessage("--------------")
  return true
end
local listPlayerDetails
listPlayerDetails = function(Split, Player)
  local playerName = Split[2]
  if Split[2] == "me" then
    playerName = Player:GetName()
  end
  local playerData = DATA.players[playerName]
  Player:SendMessage("Current player data: ")
  for k, v in pairs(playerData) do
    Player:SendMessage(k .. ": " .. tostring(v))
  end
  return true
end
local toggleDisablePortal
toggleDisablePortal = function(command, portal, Player)
  local portalData = DATA.portals[portal]
  if portalData then
    if command == "disable" then
      portalData.disabled = true
      local _ = Player / SendMessage("portal " .. portal .. " disabled")
    elseif command == "enable" then
      portalData.disabled = false
      local _ = Player / SendMessage("portal " .. portal .. " Enabled")
    end
  else
    Player:SendMessage("portal " .. portal .. " does not exist")
  end
  return true
end
local toggleAllPortalsdisabled
toggleAllPortalsdisabled = function(command, Player)
  local color = cChatColor.Red
  if command == "enable" then
    DATA.all_portals_disabled = false
    color = cChatColor.LightBlue
  elseif command == "disable" then
    DATA.all_portals_disabled = true
  end
  Player:SendMessage(color .. "All portals are now " .. command .. "d")
  return true
end
local portalPointSelectMessage
portalPointSelectMessage = function(label, x, y, z)
  local G, W
  do
    local _obj_0 = cChatColor
    G, W = _obj_0.LightGreen, _obj_0.White
  end
  return tostring(label) .. " (" .. tostring(G) .. tostring(x) .. tostring(W) .. ", " .. tostring(G) .. tostring(y) .. tostring(W) .. ", " .. tostring(G) .. tostring(z) .. ")"
end
local portalIniToTable
portalIniToTable = function(Portalini)
  local PortalsData = { }
  local warpNum = Portalini:GetNumKeys()
  if warpNum > 0 then
    for i = 0, warpNum - 1 do
      local portalName = Portalini:GetKeyName(i)
      PortalsData[portalName] = { }
      local portalData = PortalsData[portalName]
      portalData["world"] = Portalini:GetValue(portalName, "world")
      portalData["target"] = StringSplit(Portalini:GetValue(portalName, "target"), ",")
      portalData["point1_x"] = Portalini:GetValueI(portalName, "point1_x")
      portalData["point1_y"] = Portalini:GetValueI(portalName, "point1_y")
      portalData["point1_z"] = Portalini:GetValueI(portalName, "point1_z")
      portalData["point2_x"] = Portalini:GetValueI(portalName, "point2_x")
      portalData["point2_y"] = Portalini:GetValueI(portalName, "point2_y")
      portalData["point2_z"] = Portalini:GetValueI(portalName, "point2_z")
      portalData["destination_x"] = Portalini:GetValueI(portalName, "destination_x")
      portalData["destination_y"] = Portalini:GetValueI(portalName, "destination_y")
      portalData["destination_z"] = Portalini:GetValueI(portalName, "destination_z")
      portalData["disabled"] = intToBool(Portalini:GetValueI(portalName, "disabled"))
    end
  end
  return PortalsData
end
local portalDataToIni
portalDataToIni = function()
  local ini = DATA.portalIniFile
  for key, val in pairs(DATA.portals) do
    local portalData = DATA.portals[key]
    if ini:FindKey(key) then
      ini:SetValue(key, "world", portalData["world"])
      ini:SetValue(key, "target", arrayTableToString(portalData["target"]))
      ini:SetValueI(key, "point1_x", portalData["point1_x"])
      ini:SetValueI(key, "point1_y", portalData["point1_y"])
      ini:SetValueI(key, "point1_z", portalData["point1_z"])
      ini:SetValueI(key, "point2_x", portalData["point2_x"])
      ini:SetValueI(key, "point2_y", portalData["point2_y"])
      ini:SetValueI(key, "point2_z", portalData["point2_z"])
      ini:SetValueI(key, "destination_x", portalData["destination_x"])
      ini:SetValueI(key, "destination_y", portalData["destination_y"])
      ini:SetValueI(key, "destination_z", portalData["destination_z"])
      ini:SetValueI(key, "disabled", boolToInt(portalData["disabled"]))
    else
      ini:AddKeyName(key)
      ini:AddValue(key, "world", portalData["world"])
      ini:AddValue(key, "target", arrayTableToString(portalData["target"]))
      ini:AddValueI(key, "point1_x", portalData["point1_x"])
      ini:AddValueI(key, "point1_y", portalData["point1_y"])
      ini:AddValueI(key, "point1_z", portalData["point1_z"])
      ini:AddValueI(key, "point2_x", portalData["point2_x"])
      ini:AddValueI(key, "point2_y", portalData["point2_y"])
      ini:AddValueI(key, "point2_z", portalData["point2_z"])
      ini:AddValueI(key, "destination_x", portalData["destination_x"])
      ini:AddValueI(key, "destination_y", portalData["destination_y"])
      ini:AddValueI(key, "destination_z", portalData["destination_z"])
      ini:AddValueI(key, "disabled", boolToInt(portalData["disabled"]))
    end
  end
  local numKeys = ini:GetNumKeys()
  for i = 0, numKeys - 1 do
    local portalName = ini:GetKeyName(i)
    if not DATA.portals[portalName] then
      ini:DeleteKey(portalName)
    end
  end
end
local playerInAPortal
playerInAPortal = function(Player)
  local _check_cuboid = cCuboid()
  local _player_pos = Player:GetPosition()
  _player_pos.x = math.floor(_player_pos.x)
  _player_pos.y = math.floor(_player_pos.y)
  _player_pos.z = math.floor(_player_pos.z)
  for k, v in pairs(DATA.portals) do
    if (v["target"]) then
      if (v["world"] == Player:GetWorld():GetName()) then
        local vector1 = Vector3i()
        local vector2 = Vector3i()
        vector1.x = v["point1_x"]
        vector1.y = v["point1_y"]
        vector1.z = v["point1_z"]
        vector2.x = v["point2_x"]
        vector2.y = v["point2_y"]
        vector2.z = v["point2_z"]
        _check_cuboid.p1 = vector1
        _check_cuboid.p2 = vector2
        _check_cuboid:Sort()
        if (_check_cuboid:IsInside(_player_pos)) then
          return k
        end
      end
    end
  end
  return false
end
local targetPortalHasNoDest
targetPortalHasNoDest = function(targetPortal)
  local destination_x, destination_y, destination_z
  destination_x, destination_y, destination_z = targetPortal.destination_x, targetPortal.destination_y, targetPortal.destination_z
  if targetPortal ~= nil and (destination_x == 0 and destination_y == 0 and destination_z == 0) then
    return true
  end
  return false
end
local teleportPlayer
teleportPlayer = function(Player)
  local playerData = DATA.players[Player:GetName()]
  local portalData = DATA.portals[playerData.targetPortalName]
  local world = Player:GetWorld()
  if world:GetName() ~= portalData.world then
    playerData.HasTeleportedToWorld = true
    return Player:MoveToWorld(portalData.world)
  else
    local destination_x, destination_y, destination_z
    destination_x, destination_y, destination_z = portalData.destination_x, portalData.destination_y, portalData.destination_z
    Player:TeleportToCoords(destination_x, destination_y, destination_z)
    playerData.targetPortalName = ""
    return Player:SendMessage(cChatColor.Yellow .. "You have been teleported!")
  end
end
