local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'LibraryCollection'

XFC.LibraryCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.LibraryCollection:new()
    local object = XFC.LibraryCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.LibraryCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:Add('Location', 'LibTourist-3.0')
        self:IsInitialized(true)
    end
end
--#endregion

--#region Hash
function XFC.LibraryCollection:Add(inName, inStubName)
    assert(type(inName) == 'string')
    assert(type(inStubName) == 'string')
    if(not self:Contains(inName)) then
        local library = XFC.Library:new(); library:Initialize()
        library:SetKey(inName)
        library:SetLibrary(LibStub:GetLibrary(inStubName))
        self.parent.Add(self, library)
    end
end
--#endregion