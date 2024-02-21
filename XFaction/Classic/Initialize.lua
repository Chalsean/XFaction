local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ClassicInit'

do
	try(function ()
		XF.CoreInit()
	end).
	catch(function (inErrorMessage)
		XF:Error(ObjectName, inErrorMessage)
		XF:Stop()
	end)
end