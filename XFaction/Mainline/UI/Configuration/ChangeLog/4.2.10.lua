local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.2.10'] = {
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
                name = 'Fixed receiving multiple copies of the same gchat message being caused by Ace3 Event module.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed DTMetrics not updating.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed RaiderIO now showing on DTGuild.',
            },
            Four = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed setup for brand new confederates.',
            },
            Five = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed middle mouse button opening whisper window when scrolling thru DTGuild.',
            },
            Six = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed time delay on login message send.',
            },
        }
    },			
}