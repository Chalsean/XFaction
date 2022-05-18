local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MProfessions'
local Initialized = false

function CON:RefreshGuildTradeSkills()

	local tmp,skillHeader = {},{};
	local num = GetNumGuildTradeSkill();
	for index=1, num do
		skillID,isCollapsed,iconTexture,headerName,_,_,_,_,playerFullName,_,_,_,skill,classFileName = GetGuildTradeSkillInfo(index);
		if headerName then
			skillHeader = {headerName,iconTexture,skillID};
		elseif playerFullName then
			if tmp[playerFullName]==nil then
				tmp[playerFullName]={};
			end
			tinsert(
				tmp[playerFullName],
				{
					skillHeader[1],
					skillHeader[2] or ns.icon_fallback,
					skill,
					skillHeader[3] or skillID
				}
			);
		end
	end
end