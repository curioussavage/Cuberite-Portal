findKey = (table, val) ->
    if (not table or not val) then return false
    for k, v in pairs(table)
        if k == val then return true

    return false


boolToInt = (val) ->
    if type(val) == "boolean"
        if val == false
            return 0
        else 
            return 1


intToBool = (val) ->
    if type(val) == "number"
        if val == 1
            return true
        else 
            return false


arrayTableToString = (table) ->
    string = ""
    for i, v in ipairs(table)
        newString = v
        if i ~= #table
            newString = newString .. ","

        string = string .. newString

    return string


includes = (table, val) ->
    -- check if key exists in array like table
    for i, v in ipairs(table)
        if v == val
            return true
    
    return false

find = (table, val) ->
    -- return index of item in array like table
    for i, v in ipairs(table)
        if v == val
            return i

    return 0


getPoints = (prefix, data) ->
    table = {}
    table.x = data[prefix .. "_x"]
    table.y = data[prefix .. "_y"]
    table.z = data[prefix .. "_z"]

    return table
