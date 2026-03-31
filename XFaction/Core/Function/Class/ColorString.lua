local XF, E, L, V, P, G = unpack(select(2, ...))

function ClassColorString(Text, Class)
	if Text == nil then return end
	local ClassColor = E:ClassColor(string.upper(string.gsub(Class, "%s+", "")), true)
	local Hex

    if(ClassColor ~= nil) then
		Hex = ClassColor.colorStr
	else
		Hex = "ffffffff"
	end
    return "|c" .. Hex .. Text .. "|r"
end