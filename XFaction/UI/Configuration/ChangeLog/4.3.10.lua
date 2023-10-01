local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.3.10'] = {
    Improvements = {
        order = 1,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed memory leak issue with 4.3.4 logic.',
            },
            Bar1 = {
                order = 2,
                name = '',
                type = 'header'
            },
            Two = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Attempt at hiding the login spam when someone realm transfers.',
            },
            Bar2 = {
                order = 4,
                name = '',
                type = 'header'
            },
            Three = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Better performance on local guild scans. Should see lower memory and CPU fluctuations from XF caused by Blizz spamming GUILD_ROSTER_UPDATE events.',
            },
            Bar3 = {
                order = 6,
                name = '',
                type = 'header'
            },
            Four = {
                order = 7,
                type = 'description',
                fontSize = 'medium',
                name = 'Similarly better performance on BNet friend scans from Blizz spamming BN_FRIEND_INFO_CHANGED.',
            },
            Bar4 = {
                order = 8,
                name = '',
                type = 'header'
            },
            Five = {
                order = 9,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed bug where achievements sometimes had a blank name.',
            },
        }
    },			
}