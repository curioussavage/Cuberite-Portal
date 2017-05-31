local worldOption
worldOption = function(name)
  return "\n      <option value='" .. tostring(name) .. "'>" .. tostring(name) .. "</option>\n    "
end
local worldsOptions
worldsOptions = function()
  local options = ""
  for index, worldName in pairs(WORLDS) do
    options = options .. worldOption(worldName)
  end
  return options
end
local get
get = function(table, key, default)
  if table ~= nil and table[key] ~= nil then
    if type(table[key]) == 'table' then
      return arrayTableToString(table[key])
    end
    return table[key]
  end
  return default
end
local renderGuiForm
renderGuiForm = function(portalConfigs, portalToEditName, path)
  local previewItems = ""
  for portalName, config in pairs(portalConfigs) do
    previewItems = previewItems .. makePreviewItem(portalName, config)
  end
  local editPortal = DATA.portals[portalToEditName]
  local buttonText = "ADD"
  local name = ""
  if editPortal ~= nil then
    buttonText = "SAVE"
    name = portalToEditName
  end
  local globalDisableMessage = DATA.all_portals_disabled and "Disable" or "Enable"
  return " \n        <style>\n            " .. tostring(CSS_STYLES) .. "\n        </style>\n      <form method='post' class='global-disable-form' >\n        <input hidden name='disable' value='global_disable' />\n        <span>Global portal lock </span>\n            <button type='submit'>" .. tostring(globalDisableMessage) .. "</button>\n      </form>\n        <form class='table' id='portalForm' method='post' action='" .. tostring(path) .. "'>\n            <div class='block'>\n                <h3>Name</h3>\n                <input name='name' type='text' value='" .. tostring(name) .. "'/>\n            </div>\n            \n            <div class='block'>\n                <h3>World</h3>\n                <select class='world-field__select' name='world' value='" .. tostring(get(editPortal, 'world', '')) .. "'>\n                 " .. tostring(worldsOptions()) .. "\n                </select>\n            </div>\n            \n            <div class='block'>\n                <h3>Target Portal Name</h3>\n                <input name='target' type='text' value='" .. tostring(get(editPortal, 'target', '')) .. "'/>\n            </div>\n\n            " .. tostring(makePointBlock('Portal Point 1', 'point1', editPortal)) .. "\n            " .. tostring(makePointBlock('Portal Point 2', 'point2', editPortal)) .. "\n            " .. tostring(makePointBlock('Portal Destination Point', 'destination', editPortal)) .. "\n\n            <button class='submit-btn' type='submit'>" .. tostring(buttonText) .. "</button>\n        </form>\n\n        <div class='preview'>\n            " .. tostring(previewItems) .. "\n        </div>\n    "
end
local makePreviewItem
makePreviewItem = function(portalName, portalConfig)
  local p1 = getPoints('point1', portalConfig)
  local p2 = getPoints('point2', portalConfig)
  local dest = getPoints('destination', portalConfig)
  local disableText = portalConfig.disabled and "enable" or "disable"
  return "\n        <div class='preview-item'>\n            <div class='preview-item__left'>\n                <h3 class='preview-item__name'>" .. tostring(portalName) .. "</h3>\n                <p>world: " .. tostring(portalConfig.world) .. "</p>\n                <p>target: " .. tostring(arrayTableToString(portalConfig.target)) .. "</p>\n                <p>disabled: " .. tostring(tostring(portalConfig.disabled)) .. "</p>\n            </div>\n            <div class='preview-item__right'>\n                " .. tostring(previewPointBox('Point 1', p1.x, p1.y, p1.z)) .. "\n                " .. tostring(previewPointBox('Point 2', p2.x, p2.y, p2.z)) .. "\n                " .. tostring(previewPointBox('Dest', dest.x, dest.y, dest.z)) .. "\n                <form method='get' >\n                    <input hidden type='text' name='edit' value='" .. tostring(portalName) .. "' />\n                    <button class='preview-item__edit'>Edit</button>\n                </form>\n                <form method='post'>\n                    <input hidden name='del' value='" .. tostring(portalName) .. "' />\n                    <button class='preview-item__del'>Del</button>\n                </form>\n                <form method='post'>\n                    <input hidden name='disable' value='" .. tostring(portalName) .. "' />\n                    <button class='preview-item__disable'>" .. tostring(disableText) .. "</button>\n                </form>\n            </div>\n        </div>\n    "
end
local previewPointBox
previewPointBox = function(label, x, y, z)
  return "\n        <div class='preview-item__point-box'>\n            <h3>" .. tostring(label) .. "</h3>\n            <ul>\n                <li>X: " .. tostring(x) .. "</li>\n                <li>Y: " .. tostring(y) .. "</li>\n                <li>Z: " .. tostring(z) .. "</li>\n            </ul>\n        </div>\n    "
end
