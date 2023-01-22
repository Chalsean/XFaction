local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XFG.ChangeLog['4.3.3'] = {
    Improvements = {
        order = 1,
        type = 'group',
        name = XFG.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Better performance on local guild scans. Should see lower overall memory usage and CPU hit from Blizz spamming GUILD_ROSTER_UPDATE events.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Similarly better performance on BNet friend scans from Blizz spamming BN_FRIEND_INFO_CHANGED.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Attempt at hiding the login spam when someone realm transfers.',
            },
            Four = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'More consistency in receiving logout messages.',
            },
        }
    },			
}