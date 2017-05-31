worldOption = (name) ->
    return "
      <option value='#{name}'>#{name}</option>
    "

worldsOptions = () ->
    options = ""
    for index, worldName in pairs(WORLDS)
        options = options .. worldOption(worldName)

    return options

get = (table, key, default) ->
    if table ~= nil and table[key] ~= nil
        if type(table[key]) == 'table'
            return arrayTableToString(table[key])

        return table[key]

    return default

renderGuiForm = (portalConfigs, portalToEditName, path) ->
    previewItems = ""
    for portalName, config in pairs(portalConfigs)
        previewItems = previewItems .. makePreviewItem(portalName, config)

    editPortal = DATA.portals[portalToEditName]
    buttonText = "ADD"
    name = ""
    if editPortal ~= nil
        buttonText = "SAVE"
        name = portalToEditName

    globalDisableMessage = DATA.all_portals_disabled and "Disable" or "Enable"

    return " 
        <style>
            #{ CSS_STYLES }
        </style>
      <form method='post' class='global-disable-form' >
        <input hidden name='disable' value='global_disable' />
        <span>Global portal lock </span>
            <button type='submit'>#{ globalDisableMessage }</button>
      </form>
        <form class='table' id='portalForm' method='post' action='#{ path }'>
            <div class='block'>
                <h3>Name</h3>
                <input name='name' type='text' value='#{ name }'/>
            </div>
            
            <div class='block'>
                <h3>World</h3>
                <select class='world-field__select' name='world' value='#{ get(editPortal, 'world', '') }'>
                 #{ worldsOptions() }
                </select>
            </div>
            
            <div class='block'>
                <h3>Target Portal Name</h3>
                <input name='target' type='text' value='#{ get(editPortal, 'target', '') }'/>
            </div>

            #{ makePointBlock('Portal Point 1', 'point1', editPortal) }
            #{ makePointBlock('Portal Point 2', 'point2', editPortal) }
            #{ makePointBlock('Portal Destination Point', 'destination', editPortal) }

            <button class='submit-btn' type='submit'>#{ buttonText }</button>
        </form>

        <div class='preview'>
            #{ previewItems }
        </div>
    "


makePreviewItem = (portalName, portalConfig) ->
    p1 = getPoints('point1', portalConfig)
    p2 = getPoints('point2', portalConfig)
    dest = getPoints('destination', portalConfig)
    disableText = portalConfig.disabled and "enable" or "disable"
    return "
        <div class='preview-item'>
            <div class='preview-item__left'>
                <h3 class='preview-item__name'>#{ portalName }</h3>
                <p>world: #{portalConfig.world }</p>
                <p>target: #{ arrayTableToString(portalConfig.target) }</p>
                <p>disabled: #{ tostring(portalConfig.disabled) }</p>
            </div>
            <div class='preview-item__right'>
                #{ previewPointBox('Point 1', p1.x, p1.y, p1.z) }
                #{ previewPointBox('Point 2', p2.x, p2.y, p2.z) }
                #{ previewPointBox('Dest', dest.x, dest.y, dest.z) }
                <form method='get' >
                    <input hidden type='text' name='edit' value='#{ portalName }' />
                    <button class='preview-item__edit'>Edit</button>
                </form>
                <form method='post'>
                    <input hidden name='del' value='#{ portalName }' />
                    <button class='preview-item__del'>Del</button>
                </form>
                <form method='post'>
                    <input hidden name='disable' value='#{ portalName }' />
                    <button class='preview-item__disable'>#{ disableText }</button>
                </form>
            </div>
        </div>
    "


previewPointBox = (label, x, y, z) ->
    return "
        <div class='preview-item__point-box'>
            <h3>#{ label }</h3>
            <ul>
                <li>X: #{ x }</li>
                <li>Y: #{ y }</li>
                <li>Z: #{ z }</li>
            </ul>
        </div>
    "
