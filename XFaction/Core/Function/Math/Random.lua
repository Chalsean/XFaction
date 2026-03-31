local XF, E, L, V, P, G = unpack(select(2, ...))
local Initialized = false
--local math_seed = math.randomseed

local function Initialize()
	if(Initialized == false) then
--		local seed = GetServerTime()
--		math.randomseed(seed)
		Initialized = true
	end
end

function math.Random(Modulo)
	XF:Debug('Random', "modulo [%d]", Modulo)
	Initialize()
	local RandomNumber = math.random() 
	if(Modulo ~= nil) then
		RandomNumber = RandomNumber % Modulo
	end
	return RandomNumber
end