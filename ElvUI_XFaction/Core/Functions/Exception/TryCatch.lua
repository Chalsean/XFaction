local XFG, E, L, V, P, G = unpack(select(2, ...))

function Try (...)
	local _Status, _Error = (pcall(function () ...))
	if(_Status == false) then
		
	end
end

function Throw(...)
	error(...)
end