-- Global variables
PLUGIN = {} -- Reference to own plugin object
-- LOGIC
PORTAL_ACTIVATION_TIME = 2

_player_states = {
    "NOT_IN_PORTAL", 
    "WAITING", 
    "TELEPORTING", 
    "PORTAL_NOT_SETUP", 
    "IN_DISABLED_PORTAL", 
    "SELECTING_DEST" 
}
PLAYER_STATES = { x, x for x in *_player_states }

DATA = {}
DATA.players = {}
DATA.portals = {}
DATA.all_portals_disabled = false

PORTALS_INI_NAME = "portals.ini"

PLUGIN_PATH = ''
DATA.portalIniFile = cIniFile()

CSS_STYLES = nil
WORLDS = {}

{   :HOOK_ENTITY_CHANGED_WORLD,
    :HOOK_PLAYER_DESTROYED,
    :HOOK_PLAYER_JOINED,
    :HOOK_PLAYER_LEFT_CLICK,
    :HOOK_PLAYER_MOVING
} = cPluginManager

Initialize = (Plugin) ->
    PLUGIN = Plugin

    dofile(cPluginManager\GetPluginsPath() .. "/InfoReg.lua")

    Plugin\SetName(g_PluginInfo.Name)
    Plugin\SetVersion(3)

    cPluginManager\AddHook(HOOK_PLAYER_MOVING, onPlayerMoving)
    cPluginManager\AddHook(HOOK_PLAYER_JOINED, onPlayerJoin)
    cPluginManager\AddHook(HOOK_PLAYER_DESTROYED, onPlayerDestroyed)
    cPluginManager\AddHook(HOOK_PLAYER_LEFT_CLICK, onPlayerBreakingBlock)
    cPluginManager\AddHook(HOOK_ENTITY_CHANGED_WORLD, onEntityChangedWorld)

    Plugin\AddWebTab("Portals", handleRequest)

    cRoot\Get()\ForEachWorld((world) -> WORLDS[#WORLDS + 1] = world\GetName())

    RegisterPluginInfoCommands() -- provided by env. sets up the commands listed in info.lua

    plugins_path = cPluginManager\GetPluginsPath()
    folder_name = Plugin\GetFolderName()
    PLUGIN_PATH = "#{plugins_path}/#{folder_name}/"
    CSS_STYLES = cFile\ReadWholeFile(PLUGIN_PATH .. "portal-styles.css")
    -- load ini files into memory or create them.
    initINI(PORTALS_INI_NAME, DATA.portalIniFile)
    DATA.portals = portalIniToTable(DATA.portalIniFile)

    LOG("Initialized " .. PLUGIN\GetName() .. " v" .. g_PluginInfo.Version)
    return true


initINI = (fileName, iniObject) ->
    if cFile\IsFile(PLUGIN_PATH .. fileName)
        iniObject\ReadFile(PLUGIN_PATH .. fileName)
        name = PLUGIN\GetName()
        LOG("#{name}: loaded #{fileName}")
    else
        success, _ = pcall(iniObject.WriteFile, iniObject, PLUGIN_PATH ..fileName)
        if success
            LOG("PORTALS PLUGIN #{fileName} created.")


OnDisable = () -> -- the environment will call this function when plugin is disabled.
    portalDataToIni()
    DATA.portalIniFile\WriteFile(PLUGIN_PATH .. PORTALS_INI_NAME)
    
    name = Plugin\GetName()
    version = g_PluginInfo.Version
    message = "#{name} v#{version} is shutting down..."
    LOG(message)
