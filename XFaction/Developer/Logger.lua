local XFG, G = unpack(select(2, ...))
local FormatSet = false

local function Format()
	if FormatSet == false and DLAPI and DLAPI.GetFormat and DLAPI.IsFormatRegistered then
		local fmt = DLAPI.IsFormatRegistered(DLAPI.GetFormat(XFG.Category))
		if fmt and fmt.colWidth then
			fmt.colWidth = { 0.05, 0.12, 0.1, 0.03, 1 - 0.05 - 0.12 - 0.1 - 0.03, }
			FormatSet = true
		end
	end
end

function XFG:Error(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
	  if DLAPI then DLAPI.DebugLog(XFG.Category, format('ERR~%s~1~%s', SubCategory, res)) end
	end
	if(XFG.Metrics ~= nil) then
		XFG.Metrics:GetMetric(XFG.Settings.Metric.Error):Increment()
	end
end

function XFG:Warn(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
	  if DLAPI then DLAPI.DebugLog(XFG.Category, format('WARN~%s~3~%s', SubCategory, res)) end
	end
	if(XFG.Metrics ~= nil) then
		XFG.Metrics:GetMetric(XFG.Settings.Metric.Warning):Increment()
	end
end

function XFG:Info(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
		Format()
		if DLAPI then DLAPI.DebugLog(XFG.Category, format('OK~%s~6~%s', SubCategory, res)) end
	end
end

function XFG:Debug(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
		Format()
		if DLAPI then DLAPI.DebugLog(XFG.Category, format('%s~9~%s', SubCategory, res)) end
	end
end

local function TableToString(t, l, k)
	local ResultSet
	if type(t) == 'table' then
		ResultSet = string.format('%s%s:', string.rep(' ', l*2), tostring(k))
		for k, v in pairs(t) do
			ResultSet = ResultSet .. '\n' .. TableToString(v, l+1, k)
		end
	else
		ResultSet = string.format('%s%s:%s', string.rep(' ', l*2), tostring(k), tostring(t))
	end
	return ResultSet
end

function XFG:DataDumper(SubCategory, ...)
	XFG:Debug(SubCategory, TableToString(..., 1, 'root'))
end

function XFG:SingleLine(SubCategory)
	XFG:Debug(SubCategory, '-------------------------------------')
end

function XFG:DoubleLine(SubCategory)
	XFG:Debug(SubCategory, '=====================================')
end