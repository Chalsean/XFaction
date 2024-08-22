local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MainlineInit'

do
	try(function ()
		XF.CoreInit()
	end).
	catch(function (inErrorMessage)
		XF:Error(ObjectName, inErrorMessage)
		XF:Stop()
	end)
end