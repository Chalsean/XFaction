local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.1.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Elephant = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Will log guild chat messages in Elephant if the user has the addon installed and enabled. Elephant records various chat communications for visibility when reloading or switching toons.',
            },
            Addon = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Added ability to better identify guild members not using addon per request.',
            },
            Messaging = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'More performance optimizations.',       
            },
            Shutdown = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Recognizes the user leaving guild and shuts down.',
            },
            Ignore = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Adheres to ignore list.',
            },
            Crafting = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed crafting order notifications.',
            },
            DTGuild = {
                order = 7,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed duplicate DTGuild entries.',
            },
            DTGuild2 = {
                order = 8,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed opening whisper when clicking on DTGuild entry.',
            },
            Dirty = {
                order = 9,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed exception being thrown by using dirty objects.',
            },            
            Media = {
                order = 10,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed ElvUI confederate member icon on nameplates.',
            },
        },
    },		
}