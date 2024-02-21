local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'MainlineInit'

do
	try(function ()
		XF.CoreInit()
		--XF.Handlers.TimerEvent:Initialize()
	end).
	catch(function (inErrorMessage)
		XF:Error(ObjectName, inErrorMessage)
		XF:Stop()
	end)
end