local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.2.2'] = {
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
                name = 'Allows the enable/disable of local guild scans. The Blizzard API is what is causing excessive memory use and garbage collection, so this avoids calling it. Due to game impact, this option will be defaulted to off.\n\nWhen the option is toggled off, you will not see non-XFaction players of your local guild in Guild(X).\n\nTo toggle this option, go to Options / XFaction / DataText / Guild / Non-XFaction Users',
            },
            Dups = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed names showing up multiple times in Guild (X).',
            },
        },
    },		
}