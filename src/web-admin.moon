handleRequest = (Request) ->
    Query = getQuery(Request.URL)
    if Request.Method == 'POST'
        params = Request.PostParams
        name = params['name']
        del = params['del']
        disable = params['disable']

        if disable
            toggleDisable(disable)

        if name
            saveNewPortal(name, params)

        if del
            delPortal(del)

    path = StringSplit(Request.URL, "?")[1]
    return renderGuiForm(DATA.portals, Query.edit, path)

   
saveNewPortal = (name, fields) ->
    if not DATA.portals[name]
        DATA.portals[name] = {}

    for key, val in pairs(fields)
        if key ~= "name"
            if key == 'target'
                DATA.portals[name][key] = StringSplit(val, ",")
            else
                DATA.portals[name][key] = val


delPortal = (portalName) ->
        if DATA.portals[portalName]
            DATA.portals[portalName] = nil


toggleDisable = (portalName) ->
    if portalName == "global_disable"
        DATA.all_portals_disabled = not DATA.all_portals_disabled
    elseif DATA.portals[portalName]
        DATA.portals[portalName].disabled = not DATA.portals[portalName].disabled


getQuery = (url) ->
    -- local <return vals here> = cUrlParser:Parse( url ) -- this did not work for some reason
    Query = StringSplit(url, '?')[2]
    querySplit = StringSplit(Query, '&')
    query = {}
    for i, val in pairs(querySplit)
        keyVal = StringSplit(val, '=')
        query[keyVal[1]] = keyVal[2]

    return query
 