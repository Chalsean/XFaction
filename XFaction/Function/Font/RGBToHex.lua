-- Credit to wowwiki: https://wowwiki-archive.fandom.com/wiki/USERAPI_RGBPercToHex
local XF, E, L, V, P, G = unpack(select(2, ...))

function XF:RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end