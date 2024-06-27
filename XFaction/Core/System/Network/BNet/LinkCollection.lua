local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'LinkCollection'
local ServerTime = GetServerTime

LinkCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function LinkCollection:new()
    local object = LinkCollection.parent.new(self)
	object.__name = ObjectName
	return object
end

function LinkCollection:NewObject()
	return Link:new()
end
--#endregion

--#region Hash
function LinkCollection:Add(inLink)
    assert(type(inLink) == 'table' and inLink.__name == 'Link', 'argument must be Link object')
	if(not self:Contains(inLink:Key())) then
		self.parent.Add(self, inLink)
		inLink:GetFromNode():IncrementLinkCount()
		inLink:GetToNode():IncrementLinkCount()
		XF:Info(ObjectName, 'Added link from [%s] to [%s]', inLink:GetFromNode():Name(), inLink:GetToNode():Name())
		XF.DataText.Links:RefreshBroker()
	end
end

function LinkCollection:Remove(inLink)
    assert(type(inLink) == 'table' and inLink.__name == 'Link', 'argument must be Link object')
	if(self:Contains(inLink:Key())) then
		self.parent.Remove(self, inLink:Key())
		inLink:GetFromNode():DecrementLinkCount()
		inLink:GetToNode():DecrementLinkCount()
		XF:Info(ObjectName, 'Removed link from [%s] to [%s]', inLink:GetFromNode():Name(), inLink:GetToNode():Name())
		self:Push(inLink)
		XF.DataText.Links:RefreshBroker()
	end
end
--#endregion

--#region DataSet
-- A link message is a reset of the links for that node
function LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', 'argument must be Message object')
	local linkStrings = string.Split(inMessage:GetData(), '|')
	local linkKeys = {}
	local sourceKey = nil	
	-- Add new links
    for _, linkString in pairs (linkStrings) do
		local linkKey, from = self:SetLinkFromString(linkString)
		if(linkKey ~= nil) then 
			linkKeys[linkKey] = true 
			sourceKey = from
		end
    end
	-- Remove stale links and update datetimes
	for _, link in self:Iterator() do
		-- Consider that we may have gotten link information from the other node
		if(link:GetFromNode():Name() == sourceKey or link:GetToNode():Name() == sourceKey) then
			if(not link:IsMyLink() and linkKeys[link:Key()] == nil) then
				self:Remove(link)
				XF:Debug(ObjectName, 'Removed link due to node broadcast [%s]', link:Key())
			else
				-- Update datetime for janitor process
				link:SetTimeStamp(ServerTime())
			end
		end
	end
end

function LinkCollection:SetLinkFromString(inLinkString)
    assert(type(inLinkString) == 'string')

    local nodes = string.Split(inLinkString, ';')
    local fromNode = XF.Nodes:SetNodeFromString(nodes[1])
    local toNode = XF.Nodes:SetNodeFromString(nodes[2])

	-- Can remove equality check once everyone updates to 3.9.6
	if(fromNode:IsMyNode() or toNode:IsMyNode() or fromNode:Equals(toNode)) then
		return nil
	end

	local key = XF:GetLinkKey(fromNode:Name(), toNode:Name())
	if(self:Contains(key)) then
		return self:Get(key), fromNode:Name()
	end

	local link = self:Pop()
	link:SetFromNode(fromNode)
	link:SetToNode(toNode)
    link:Initialize()
	self:Add(link)
	fromNode:IncrementLinkCount()
	toNode:IncrementLinkCount()

	return key, fromNode:Name()
end
--#endregion

--#region Network
function LinkCollection:Broadcast()
	XF:Debug(ObjectName, 'Broadcasting links')
	local linksString = ''
	local haveLinks = false
	for _, link in self:Iterator() do
		if(link:IsMyLink()) then
			haveLinks = true
			linksString = linksString .. '|' .. link:GetString()
		end
	end

	if(not haveLinks) then return end

	local message = nil
	try(function ()
		message = XFO.Mailbox:Pop()
		message:Initialize()
		message:SetType(XF.Enum.Network.BROADCAST)
		message:SetSubject(XF.Enum.Message.LINK)
		message:SetData(linksString)
		XFO.Chat:Send(message)  
	end).
	finally(function ()
		XFO.Mailbox:Push(message)
	end)
end
--#endregion

--#region Janitorial
function LinkCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			local linksString = ''
			for _, link in self:Iterator() do
				linksString = linksString .. '|' .. link:GetString()
			end
			XF.Cache.Backup.Links = linksString
		end
	end).
	catch(function (inErrorMessage)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create links backup before reload: ' .. inErrorMessage
	end)
end

function LinkCollection:Restore()
	if(XF.Cache.Backup.Links ~= nil and strlen(XF.Cache.Backup.Links) > 0) then
		try(function ()
			local links = string.Split(XF.Cache.Backup.Links, '|')
			for _, link in pairs (links) do
				self:SetLinkFromString(link)
			end
		end).
		catch(function (inErrorMessage)
			XF:Warn(ObjectName, inErrorMessage)
		end)
	end
	XF.Cache.Backup.Links = ''
end

function LinkCollection:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _, link in self:Iterator() do
		if(not link:IsMyLink() and link:GetTimeStamp() < inEpochTime) then
			XF:Debug(ObjectName, 'Removing stale link')
			self:Remove(link)
		end
	end
end
--#endregion