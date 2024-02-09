local XF, E, L, V, P, G = unpack(select(2, ...))

function string.Split(String, Delimiter)
	if Delimiter == nil then
		Delimiter = "%s"
	end
	local ResultSet = {}
	for SubString in string.gmatch(String, "([^"..Delimiter.."]+)") do
		ResultSet[#ResultSet + 1] = SubString
	end
	return ResultSet
end