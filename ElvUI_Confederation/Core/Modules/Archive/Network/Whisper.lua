local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MWhisper'
local Initialized = false

function CON:WhisperUnitData(UnitData, Target)
	CON:Info(LogCategory, "Whispering data for [%s] to [%s]", UnitData.Unit, Target)
	local MessageData = CON:EncodeUnitData(UnitData)
	CON:SendCommMessage(CON.Network.Message.UnitData, MessageData, "WHISPER", Target)
end