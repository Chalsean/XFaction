local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'HookCollection'

XFC.HookCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.HookCollection:new()
    local object = XFC.HookCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Hash
function XFC.HookCollection:Add(inArgs)
    assert(type(inArgs) == 'table')
    assert(type(inArgs.name) == 'string')
    assert(type(inArgs.original) == 'string')
    assert(type(inArgs.callback) == 'function')
    assert(inArgs.pre == nil or type(inArgs.pre) == 'boolean')
    assert(inArgs.start == nil or type(inArgs.start) == 'boolean')

    local hook = XFC.Hook:new()
    hook:Initialize()
    hook:SetKey(inArgs.name)
    hook:SetOriginal(inArgs.original)
    hook:SetCallback(inArgs.callback)
    hook:IsPreHook(inArgs.pre)
    if(inArgs.start) then
        hook:Start()
    end
    self.parent.Add(self, hook)
    XF:Info('Hook', 'Hooked function %s', hook:GetOriginal())
end
--#endregion

--#region Start/Stop everything
function XFC.HookCollection:Start()
	for _, hook in self:Iterator() do
        if(not hook:IsEnabled()) then
            hook:Start()
        end
	end
end

function XFC.HookCollection:Stop()
	for _, hook in self:Iterator() do
        if(hook:IsEnabled()) then
            hook:Stop()
        end
	end
end
--#endregion