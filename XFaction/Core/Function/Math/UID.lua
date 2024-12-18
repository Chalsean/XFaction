local XF, G = unpack(select(2, ...))
local characters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789_`!@:#$^.&*()-=+[]{}|<>/?'
local characterArray = {}
for character in characters:gmatch('.') do
    characterArray[#characterArray + 1] = character
end

function math.GenerateUID()
    local uid = ''
    for i = 1, XF.Settings.System.UIDLength do
        uid = uid .. characterArray[math.random(1, #characterArray)] 
    end
    return uid
end