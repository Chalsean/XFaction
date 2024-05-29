local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.13.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Links1 = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Link detection and reporting is more stable.',
            },
            Addons = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed exception getting thrown when selecting Addon menu.',
            },
            Friend = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Detects logouts by friends.',
            },
            DTLinks1 = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Added players own link count to broker text.',
            },
            DTLinks2 = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Links window now scrollable.',
            },
            Expansion = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Added expansion identifier to messaging to distinguish between retail and classic.',
            },
            Messages = {
                order = 7,
                type = 'description',
                fontSize = 'medium',
                name = 'Early work to reduce overall number of messages by increasing the size of each message. Once everyone upgrades to this version, can reduce the overall number of messages by removing backwards compat logic.',
            },
            Links2 = {
                order = 8,
                type = 'description',
                fontSize = 'medium',
                name = 'Increased links messages from every 2 minutes to every 5 minutes to reduce overall message traffic.',
            },
            Kui = {
                order = 9,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed Kui addon logic as it wasnt working for months but nobody seemed to notice.',
            },
        },
    },		
}