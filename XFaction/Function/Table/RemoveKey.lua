local XF, E, L, V, P, G = unpack(select(2, ...))

function table.RemoveKey(table, key)
	local element = table[key]
	table[key] = nil
	return element
end