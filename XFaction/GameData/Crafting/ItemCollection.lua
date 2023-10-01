local XF, G = unpack(select(2, ...))
local XFC = XF.Class
local ObjectName = 'ItemCollection'
local IsItemCachedByClient = C_Item.IsItemDataCachedByID
local RequestItemCachedFromServer = C_Item.RequestLoadItemDataByID

XFC.ItemCollection = Factory:newChildConstructor()

--#region Constructors
function XFC.ItemCollection:new()
	local object = XFC.ItemCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.ItemCollection:NewObject()
	return XFC.Item:new()
end
--#endregion

--#region Initializers
function XFC.ItemCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.ItemCollection:IsCached(inID)
	assert(type(inID) == 'number')
	if(self:Contains(inID)) then
		return self:Get(inID):IsCached()
	end
	return false
end

function XFC.ItemCollection:Cache(inID)
	assert(type(inID) == 'number')

	local item = nil
	try(function()
		if(self:Contains(inID)) then
			item = self:Get(inID)
		else
			item = self:Pop()
			item:Initialize()
			item:SetKey(inID)
			item:SetID(inID)
			self:Add(item)
		end

		if(IsItemCachedByClient(item:GetID())) then
			item:Cache()
		else
			XF:Debug(self:GetObjectName(), 'Requesting item from server: %d', inID)
			XF.Events:Get('ItemLoaded'):Start()
			RequestItemCachedFromServer(inID)
		end
	end).
	catch(function(inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
		self:Push(item)
	end)
end

function XFC.ItemCollection:HasPending()
	for _, item in self:Iterator() do
		if(not item:IsCached()) then
			return true
		end
	end
	return false
end
--#endregion

--#region System
function XFC.ItemCollection:Backup()
	try(function ()
        if(self:IsInitialized()) then
            for _, item in self:Iterator() do
				XF.Cache.Backup.Items[item:GetKey()] = item:Encode()
            end
        end
    end).
    catch(function (inErrorMessage)
        XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create item backup before reload: ' .. inErrorMessage
    end)
end

function XFC.ItemCollection:Restore()
	for key, data in pairs (XF.Cache.Backup.Items) do
		local item = nil
        try(function ()
            item = self:Pop()
			item:Decode(data)
			self:Add(item)
			self:Cache(item:GetID())
			XF:Info(self:GetObjectName(), '  Restored %d item information from backup', item:GetID())
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
			self:Push(item)
        end)
    end
    XF.Cache.Backup.Items = {}
end
--#endregion