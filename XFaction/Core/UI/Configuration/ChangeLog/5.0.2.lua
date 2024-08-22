local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.0.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            TWW = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Networking layer rewritten to work with cross realm guilds.',
            },
            Hero = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Added hero talent recognition and added to DTGuild.',
            },
            Earthen = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Added Earthen race.',
            },
            Crafting = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed a bug that sometimes prevented crafting orders from showing.',
            },            
            Links = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Reworked DTLinks to show guild and faction-channel links as well as BNet.',
            },
            Metrics = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated DTMetrics to differentiate between guild and faction-channel messages.',
            },
            Tags = {
                order = 7,
                type = 'description',
                fontSize = 'medium',
                name = 'Added logic to better avoid Blizzards too-chatty algorithm that causes disconnects.',
            },            
            Messages = {
                order = 8,
                type = 'description',
                fontSize = 'medium',
                name = 'Consolidated several messages into larger messages to better avoid Blizzards too-chatty algorithm.',
            },            
            Namespace = {
                order = 9,
                type = 'description',
                fontSize = 'medium',
                name = 'Moved all XFaction classes to own namespace to avoid collisions with other addons.',
            },
            Realm = {
                order = 10,
                type = 'description',
                fontSize = 'medium',
                name = 'Refreshed the listing of known realms.',
            },
            Zone = {
                order = 11,
                type = 'description',
                fontSize = 'medium',
                name = 'Refreshed the listing of known zones/dungeons.',
            },
        },
    },		
}