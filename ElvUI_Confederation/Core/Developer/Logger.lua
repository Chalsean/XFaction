local CON, E, L, V, P, G = unpack(select(2, ...))
local FormatSet = false

local function Format()
	if FormatSet == false and DLAPI and DLAPI.GetFormat and DLAPI.IsFormatRegistered then
		local fmt = DLAPI.IsFormatRegistered(DLAPI.GetFormat(CON.Category))
		if fmt and fmt.colWidth then
			fmt.colWidth = { 0.05, 0.12, 0.1, 0.03, 1 - 0.05 - 0.12 - 0.1 - 0.03, }
			FormatSet = true
		end
	end
end

function CON:Error(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
	  if DLAPI then DLAPI.DebugLog(CON.Category, format("ERR~%s~1~%s", SubCategory, res)) end
	end
end

function CON:Warn(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
	  if DLAPI then DLAPI.DebugLog(CON.Category, format("WARN~%s~3~%s", SubCategory, res)) end
	end
end

function CON:Info(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
		Format()
		if DLAPI then DLAPI.DebugLog(CON.Category, format("OK~%s~6~%s", SubCategory, res)) end
	end
end

function CON:Debug(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
		Format()
		if DLAPI then DLAPI.DebugLog(CON.Category, format("%s~9~%s", SubCategory, res)) end
	end
end

local function TableToString(t, l, k)
	local ResultSet
	if type(t) == "table" then
		ResultSet = string.format("%s%s:", string.rep(" ", l*2), tostring(k))
		for k, v in pairs(t) do
			ResultSet = ResultSet .. "\n" .. TableToString(v, l+1, k)
		end
	else
		ResultSet = string.format("%s%s:%s", string.rep(" ", l*2), tostring(k), tostring(t))
	end
	return ResultSet
end

function CON:DataDumper(SubCategory, ...)
	CON:Debug(SubCategory, TableToString(..., 1, "root"))
end