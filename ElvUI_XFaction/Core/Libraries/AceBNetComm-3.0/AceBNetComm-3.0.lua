-- This is just modified AceBNetComm library to handle BNet, please see original source for any questions



--- **AceBNetComm-3.0** allows you to send messages of unlimited length over the addon comm channels.
-- It'll automatically split the messages into multiple parts and rebuild them on the receiving end.\\
-- **ChatThrottleLib** is of course being used to avoid being disconnected by the server.
--
-- **AceBNetComm-3.0** can be embeded into your addon, either explicitly by calling AceBNetComm:Embed(MyAddon) or by
-- specifying it as an embeded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call AceBNetComm itself.\\
-- It is recommended to embed AceBNetComm, otherwise you'll have to specify a custom `self` on all calls you
-- make into AceBNetComm.
-- @class file
-- @name AceBNetComm-3.0
-- @release $Id: AceBNetComm-3.0.lua 1202 2019-05-15 23:11:22Z nevcairiel $

--[[ AceBNetComm-3.0

TODO: Time out old data rotting around from dead senders? Not a HUGE deal since the number of possible sender names is somewhat limited.

]]

local CallbackHandler = LibStub("BNetCallbackHandler-1.0")
local CTL = assert(BNetCallbackHandler, "AceBNetComm-3.0 requires BNetCallbackHandler")

local MAJOR, MINOR = "AceBNetComm-3.0", 12
local AceBNetComm,oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceBNetComm then return end

-- Lua APIs
local type, next, pairs, tostring = type, next, pairs, tostring
local strsub, strfind = string.sub, string.find
local match = string.match
local tinsert, tconcat = table.insert, table.concat
local error, assert = error, assert

-- WoW APIs
local Ambiguate = Ambiguate

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: LibStub, DEFAULT_CHAT_FRAME, geterrorhandler, RegisterAddonMessagePrefix

AceBNetComm.embeds = AceBNetComm.embeds or {}

-- for my sanity and yours, let's give the message type bytes some names
local MSG_MULTI_FIRST = "\001"
local MSG_MULTI_NEXT  = "\002"
local MSG_MULTI_LAST  = "\003"
local MSG_ESCAPE = "\004"

-- remove old structures (pre WoW 4.0)
AceBNetComm.multipart_origprefixes = nil
AceBNetComm.multipart_reassemblers = nil

-- the multipart message spool: indexed by a combination of sender+distribution+
AceBNetComm.multipart_spool = AceBNetComm.multipart_spool or {}

local warnedPrefix=false

--- Send a message over the Addon Channel
-- @param prefix A printable character (\032-\255) classification of the message (typically AddonName or AddonNameEvent)
-- @param text Data to send, nils (\000) not allowed. Any length.
-- @param distribution Addon channel, e.g. "RAID", "GUILD", etc; see SendAddonMessage API
-- @param target Destination for some distributions; see SendAddonMessage API
-- @param prio OPTIONAL: ChatThrottleLib priority, "BULK", "NORMAL" or "ALERT". Defaults to "NORMAL".
-- @param callbackFn OPTIONAL: callback function to be called as each chunk is sent. receives 3 args: the user supplied arg (see next), the number of bytes sent so far, and the number of bytes total to send.
-- @param callbackArg: OPTIONAL: first arg to the callback function. nil will be passed if not specified.
function AceBNetComm:SendBNetCommMessage(target, prefix, text)
	if not( type(prefix)=="string" and
			type(text)=="string" and
			(target==nil or type(target)=="string" or type(target)=="number")
		) then
		error('Usage: SendBNetCommMessage(addon, "target", "prefix", "text"', 2)
	end

	local textlen = #text
	local maxtextlen = 255  -- Yes, the max is 255 even if the dev post said 256. I tested. Char 256+ get silently truncated. /Mikk, 20110327
	local queueName = prefix..distribution..(target or "")

	local ctlCallback = nil
	if callbackFn then
		ctlCallback = function(sent)
			return callbackFn(callbackArg, sent, textlen)
		end
	end

	local forceMultipart
	if match(text, "^[\001-\009]") then -- 4.1+: see if the first character is a control character
		-- we need to escape the first character with a \004
		if textlen+1 > maxtextlen then	-- would we go over the size limit?
			forceMultipart = true	-- just make it multipart, no escape problems then
		else
			text = "\004" .. text
		end
	end

	if not forceMultipart and textlen <= maxtextlen then
		-- fits all in one message
		CTL:SendAddonMessage(prio, prefix, text, distribution, target, queueName, ctlCallback, textlen)
	else
		maxtextlen = maxtextlen - 1	-- 1 extra byte for part indicator in prefix(4.0)/start of message(4.1)

		-- first part
		local chunk = strsub(text, 1, maxtextlen)
		CTL:SendAddonMessage(prio, prefix, MSG_MULTI_FIRST..chunk, distribution, target, queueName, ctlCallback, maxtextlen)

		-- continuation
		local pos = 1+maxtextlen

		while pos+maxtextlen <= textlen do
			chunk = strsub(text, pos, pos+maxtextlen-1)
			CTL:SendAddonMessage(prio, prefix, MSG_MULTI_NEXT..chunk, distribution, target, queueName, ctlCallback, pos+maxtextlen-1)
			pos = pos + maxtextlen
		end

		-- final part
		chunk = strsub(text, pos)
		CTL:SendAddonMessage(prio, prefix, MSG_MULTI_LAST..chunk, distribution, target, queueName, ctlCallback, textlen)
	end
end


----------------------------------------
-- Message receiving
----------------------------------------

do
	local compost = setmetatable({}, {__mode = "k"})
	local function new()
		local t = next(compost)
		if t then
			compost[t]=nil
			for i=#t,3,-1 do	-- faster than pairs loop. don't even nil out 1/2 since they'll be overwritten
				t[i]=nil
			end
			return t
		end

		return {}
	end

	local function lostdatawarning(prefix,sender,where)
		DEFAULT_CHAT_FRAME:AddMessage(MAJOR..": Warning: lost network data regarding '"..tostring(prefix).."' from '"..tostring(sender).."' (in "..where..")")
	end

	function AceBNetComm:OnReceiveMultipartFirst(prefix, message, distribution, sender)
		local key = prefix.."\t"..distribution.."\t"..sender	-- a unique stream is defined by the prefix + distribution + sender
		local spool = AceBNetComm.multipart_spool

		--[[
		if spool[key] then
			lostdatawarning(prefix,sender,"First")
			-- continue and overwrite
		end
		--]]

		spool[key] = message  -- plain string for now
	end

	function AceBNetComm:OnReceiveMultipartNext(prefix, message, distribution, sender)
		local key = prefix.."\t"..distribution.."\t"..sender	-- a unique stream is defined by the prefix + distribution + sender
		local spool = AceBNetComm.multipart_spool
		local olddata = spool[key]

		if not olddata then
			--lostdatawarning(prefix,sender,"Next")
			return
		end

		if type(olddata)~="table" then
			-- ... but what we have is not a table. So make it one. (Pull a composted one if available)
			local t = new()
			t[1] = olddata    -- add old data as first string
			t[2] = message    -- and new message as second string
			spool[key] = t    -- and put the table in the spool instead of the old string
		else
			tinsert(olddata, message)
		end
	end

	function AceBNetComm:OnReceiveMultipartLast(prefix, message, distribution, sender)
		local key = prefix.."\t"..distribution.."\t"..sender	-- a unique stream is defined by the prefix + distribution + sender
		local spool = AceBNetComm.multipart_spool
		local olddata = spool[key]

		if not olddata then
			--lostdatawarning(prefix,sender,"End")
			return
		end

		spool[key] = nil

		if type(olddata) == "table" then
			-- if we've received a "next", the spooled data will be a table for rapid & garbage-free tconcat
			tinsert(olddata, message)
			AceBNetComm.callbacks:Fire(prefix, tconcat(olddata, ""), distribution, sender)
			compost[olddata] = true
		else
			-- if we've only received a "first", the spooled data will still only be a string
			AceBNetComm.callbacks:Fire(prefix, olddata..message, distribution, sender)
		end
	end
end






----------------------------------------
-- Embed CallbackHandler
----------------------------------------

if not AceBNetComm.callbacks then
	AceBNetComm.callbacks = CallbackHandler:New(AceBNetComm,
						"_RegisterComm",
						"UnregisterComm",
						"UnregisterAllComm")
end

AceBNetComm.callbacks.OnUsed = nil
AceBNetComm.callbacks.OnUnused = nil

local function OnEvent(self, event, prefix, message, distribution, sender)
	if event == "CHAT_MSG_ADDON" then
		sender = Ambiguate(sender, "none")
		local control, rest = match(message, "^([\001-\009])(.*)")
		if control then
			if control==MSG_MULTI_FIRST then
				AceBNetComm:OnReceiveMultipartFirst(prefix, rest, distribution, sender)
			elseif control==MSG_MULTI_NEXT then
				AceBNetComm:OnReceiveMultipartNext(prefix, rest, distribution, sender)
			elseif control==MSG_MULTI_LAST then
				AceBNetComm:OnReceiveMultipartLast(prefix, rest, distribution, sender)
			elseif control==MSG_ESCAPE then
				AceBNetComm.callbacks:Fire(prefix, rest, distribution, sender)
			else
				-- unknown control character, ignore SILENTLY (dont warn unnecessarily about future extensions!)
			end
		else
			-- single part: fire it off immediately and let CallbackHandler decide if it's registered or not
			AceBNetComm.callbacks:Fire(prefix, message, distribution, sender)
		end
	else
		assert(false, "Received "..tostring(event).." event?!")
	end
end

AceBNetComm.frame = AceBNetComm.frame or CreateFrame("Frame", "AceBNetComm30Frame")
AceBNetComm.frame:SetScript("OnEvent", OnEvent)
AceBNetComm.frame:UnregisterAllEvents()
AceBNetComm.frame:RegisterEvent("CHAT_MSG_ADDON")


----------------------------------------
-- Base library stuff
----------------------------------------

local mixins = {
	"RegisterComm",
	"UnregisterComm",
	"UnregisterAllComm",
	"SendCommMessage",
}

-- Embeds AceBNetComm-3.0 into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceBNetComm-3.0 in
function AceBNetComm:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

function AceBNetComm:OnEmbedDisable(target)
	target:UnregisterAllComm()
end

-- Update embeds
for target, v in pairs(AceBNetComm.embeds) do
	AceBNetComm:Embed(target)
end