local findKey
findKey = function(table, val)
  if (not table or not val) then
    return false
  end
  for k, v in pairs(table) do
    if k == val then
      return true
    end
  end
  return false
end
local boolToInt
boolToInt = function(val)
  if type(val) == "boolean" then
    if val == false then
      return 0
    else
      return 1
    end
  end
end
local intToBool
intToBool = function(val)
  if type(val) == "number" then
    if val == 1 then
      return true
    else
      return false
    end
  end
end
local arrayTableToString
arrayTableToString = function(table)
  local string = ""
  for i, v in ipairs(table) do
    local newString = v
    if i ~= #table then
      newString = newString .. ","
    end
    string = string .. newString
  end
  return string
end
local includes
includes = function(table, val)
  for i, v in ipairs(table) do
    if v == val then
      return true
    end
  end
  return false
end
local find
find = function(table, val)
  for i, v in ipairs(table) do
    if v == val then
      return i
    end
  end
  return 0
end
local getPoints
getPoints = function(prefix, data)
  local table = { }
  table.x = data[prefix .. "_x"]
  table.y = data[prefix .. "_y"]
  table.z = data[prefix .. "_z"]
  return table
end
