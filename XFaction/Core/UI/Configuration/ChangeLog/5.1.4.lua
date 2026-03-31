local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.1.4'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Stutter = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed stutter issue when player is not on the guilds home realm.',
            },
        },
    },		
}