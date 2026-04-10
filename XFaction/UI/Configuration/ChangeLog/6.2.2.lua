local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.2.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Channel = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed channel number moving around',
            },
            Frame = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Changed how messages are written to chat frame',
            },
            Secret = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Switched from event driven addon restriction to issecret checks',
            },
            Simplified = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Simplified various logic sections',
            },
            Deprecated = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed deprecated code segments in Guild(X)',
            }
        },
    },		
}