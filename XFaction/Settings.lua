local addon, Engine = ...
local LogCategory = 'Constants'

--#region XF Instantiation
local XF = {}
setmetatable(XF, self)

Engine[1] = XF
Engine[2] = G
_G[addon] = Engine

XF.Name = 'XFaction'
XF.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XF.Version = C_AddOns.GetAddOnMetadata(addon, 'Version')
XF.Start = GetServerTime()
XF.Verbosity = 4
XF.Initialized = false
XF.UIDLength = 11
XF.Icons = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

XF.Player = {}
XF.Class = {}
XF.Function = {}
XF.Object = {}
XF.ChangeLog = {}
XF.Options = {}
XF.Enum = {}
--#endregion

--#region Libraries
XF.Lib = {
	Deflate = LibStub:GetLibrary('LibDeflate'),
	QT = LibStub('LibQTip-1.0'),
	Broker = LibStub('LibDataBroker-1.1'),
	Locale = LibStub('AceLocale-3.0'):GetLocale(XF.Name, true),
	Config = LibStub('AceConfigRegistry-3.0'),
	ConfigDialog = LibStub('AceConfigDialog-3.0'),
	LSM = LibStub('LibSharedMedia-3.0')
}
XF.Lib.BCTL = assert(BNetChatThrottleLib, 'XFaction requires BNetChatThrottleLib')
--#endregion