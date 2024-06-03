local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'MainlineInit'

do
	try(function ()
		XF.CoreInit()
	end).
	catch(function (err)
		XF:Error(ObjectName, err)
		XF:Stop()
	end)
end