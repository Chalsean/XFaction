local CON, E, L, V, P, G = unpack(select(2, ...))

function math.Random(Modulo)
	math.randomseed(GetServerTime())
	local RandomNumber = math.random() 
	if(Modulo ~= nil) then
		RandomNumber = RandomNumber % Modulo
	end
	return RandomNumber
end