local XFG, G = unpack(select(2, ...))
local ObjectName = 'HookCollection'

HookCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function HookCollection:new()
    local object = HookCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Hash
function HookCollection:Add(inKey, inOriginal, inCallback)
    local hook = Hook:new()
    hook:Initialize()
    hook:SetKey(inKey)
    hook:SetOriginal(inOriginal)
    hook:SetCallback(inCallback)
    hook:Start()
    self.parent.Add(self, hook)
    XFG:Info('Hook', 'Hooked function %s', inKey)
end
--#endregion

--#region Start/Stop
-- Stop everything
function HookCollection:Stop()
	for _, hook in self:Iterator() do
        hook:Stop()
	end
end
--#endregion