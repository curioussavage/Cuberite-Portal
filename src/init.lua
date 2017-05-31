local PLUGIN = { }
local PORTAL_ACTIVATION_TIME = 2
local _player_states = {
  "NOT_IN_PORTAL",
  "WAITING",
  "TELEPORTING",
  "PORTAL_NOT_SETUP",
  "IN_DISABLED_PORTAL",
  "SELECTING_DEST"
}
local PLAYER_STATES
do
  local _tbl_0 = { }
  for _index_0 = 1, #_player_states do
    local x = _player_states[_index_0]
    _tbl_0[x] = x
  end
  PLAYER_STATES = _tbl_0
end
local DATA = { }
DATA.players = { }
DATA.portals = { }
DATA.all_portals_disabled = false
local PORTALS_INI_NAME = "portals.ini"
local PLUGIN_PATH = ''
DATA.portalIniFile = cIniFile()
local CSS_STYLES = nil
local WORLDS = { }
local HOOK_ENTITY_CHANGED_WORLD, HOOK_PLAYER_DESTROYED, HOOK_PLAYER_JOINED, HOOK_PLAYER_LEFT_CLICK, HOOK_PLAYER_MOVING
do
  local _obj_0 = cPluginManager
  HOOK_ENTITY_CHANGED_WORLD, HOOK_PLAYER_DESTROYED, HOOK_PLAYER_JOINED, HOOK_PLAYER_LEFT_CLICK, HOOK_PLAYER_MOVING = _obj_0.HOOK_ENTITY_CHANGED_WORLD, _obj_0.HOOK_PLAYER_DESTROYED, _obj_0.HOOK_PLAYER_JOINED, _obj_0.HOOK_PLAYER_LEFT_CLICK, _obj_0.HOOK_PLAYER_MOVING
end
local Initialize
Initialize = function(Plugin)
  PLUGIN = Plugin
  dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
  Plugin:SetName(g_PluginInfo.Name)
  Plugin:SetVersion(3)
  local PluginManager = cRoot:Get():GetPluginManager()
  cPluginManager:AddHook(HOOK_PLAYER_MOVING, onPlayerMoving)
  cPluginManager:AddHook(HOOK_PLAYER_JOINED, onPlayerJoin)
  cPluginManager:AddHook(HOOK_PLAYER_DESTROYED, onPlayerDestroyed)
  cPluginManager:AddHook(HOOK_PLAYER_LEFT_CLICK, onPlayerBreakingBlock)
  cPluginManager:AddHook(HOOK_ENTITY_CHANGED_WORLD, onEntityChangedWorld)
  Plugin:AddWebTab("Portals", handleRequest)
  cRoot:Get():ForEachWorld(function(world)
    WORLDS[#WORLDS + 1] = world:GetName()
  end)
  RegisterPluginInfoCommands()
  local plugins_path = cPluginManager:GetPluginsPath()
  local folder_name = Plugin:GetFolderName()
  PLUGIN_PATH = tostring(plugins_path) .. "/" .. tostring(folder_name) .. "/"
  CSS_STYLES = cFile:ReadWholeFile(PLUGIN_PATH .. "portal-styles.css")
  initINI(PORTALS_INI_NAME, DATA.portalIniFile)
  DATA.portals = portalIniToTable(DATA.portalIniFile)
  LOG("Initialized " .. PLUGIN:GetName() .. " v" .. g_PluginInfo.Version)
  return true
end
local initINI
initINI = function(fileName, iniObject)
  if cFile:IsFile(PLUGIN_PATH .. fileName) then
    iniObject:ReadFile(PLUGIN_PATH .. fileName)
    local name = PLUGIN:GetName()
    return LOG(tostring(name) .. ": loaded " .. tostring(fileName))
  else
    local success, _ = pcall(iniObject.WriteFile, iniObject, PLUGIN_PATH .. fileName)
    if success then
      return LOG("PORTALS PLUGIN " .. tostring(fileName) .. " created.")
    end
  end
end
local OnDisable
OnDisable = function()
  portalDataToIni()
  DATA.portalIniFile:WriteFile(PLUGIN_PATH .. PORTALS_INI_NAME)
  local name = Plugin:GetName()
  local version = g_PluginInfo.Version
  local message = tostring(name) .. " v" .. tostring(version) .. " is shutting down..."
  return LOG(message)
end
