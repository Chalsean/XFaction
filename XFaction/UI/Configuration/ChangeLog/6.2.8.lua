local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.2.8'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Chattynator = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Revert Chattynator changes',
            },
            GuildX = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed a reload wiping Guild(X) list',
            },
            Guild = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Applies XFaction information to local guild communications if they are not secret',
            },            
        },
    },		
}