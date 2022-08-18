local XFG, G = unpack(select(2, ...))
local ObjectName = 'SoulbindCollection'

SoulbindCollection = ObjectCollection:newChildConstructor()

function SoulbindCollection:new()
	local _Object = SoulbindCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function SoulbindCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(XFG.WoW:IsRetail()) then
			for _, _Covenant in XFG.Covenants:Iterator() do
				for _, _SoulbindID in _Covenant:SoulbindIterator() do
					local _Soulbind = Soulbind:new()
					_Soulbind:SetID(_SoulbindID)
					_Soulbind:Initialize()
					_Soulbind:SetKey(_SoulbindID)									
					self:AddObject(_Soulbind)
					XFG:Info(ObjectName, 'Initialized soulbind [%s]', _Soulbind:GetName())
				end
			end
		end
		self:IsInitialized(true)
	end
end