local XFG, G = unpack(select(2, ...))
local ObjectName = 'HookCollection'

HookCollection = ObjectCollection:newChildConstructor()

function HookCollection:new()
    local _Object = HookCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function HookCollection:Add(inKey, inOriginal, inCallback)
    local _Hook = Hook:new()
    _Hook:Initialize()
    _Hook:SetKey(inKey)
    _Hook:SetOriginal(inOriginal)
    _Hook:SetCallback(inCallback)
    _Hook:Start()
    self.parent.Add(self, _Hook)
    XFG:Info('Hook', 'Hooked function %s', inKey)
end

-- Stop everything
function HookCollection:Stop()
	for _, _Hook in self:Iterator() do
        _Hook:Stop()
	end
end