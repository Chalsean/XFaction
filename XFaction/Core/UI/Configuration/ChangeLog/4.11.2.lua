local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.11.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Class = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Classic prepwork: Hardcoded list of factions, races, classes, specs, icons so classic can recognize retail identifiers.',
            },
        },
    },		
}