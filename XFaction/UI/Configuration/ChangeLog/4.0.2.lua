local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.0.2'] = {
    New = {
        order = 1,
        type = 'group',
        name = XF.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Recognize Dracthyr and Evoker specs.',
            },
            Two = {
                order = 2,
                type = 'description',
                name = 'Removed covenant/soulbind logic.',
                fontSize = 'medium',
            },
            Three = {
                order = 3,
                type = 'description',
                name = 'Removed Soulbind (X) DT.',
                fontSize = 'medium',
            },
            Four = {
                order = 4,
                type = 'description',
                name = 'Fixed or replaced several Blizzard API calls that changed with DF.',
                fontSize = 'medium',
            },
            Five = {
                order = 5,
                type = 'description',
                name = 'Reworked channel communication logic to match bnet for performance boost.',
                fontSize = 'medium',
            },
            Six = {
                order = 6,
                type = 'description',
                name = 'Smarter caching for performance boost during a reloadui.',
                fontSize = 'medium',
            },
            Seven = {
                order = 7,
                type = 'description',
                name = 'Increased compression level to send less data packets.',
                fontSize = 'medium',
            },
            Eight = {
                order = 8,
                type = 'description',
                name = 'Replaced following libraries with own logic: Ace3 Addon, Bucket, Comm, Console, GUI, Hook, Serializer, Tab, Timer; LibBabble; LibClass; LibProfession; LibRace; LibSpec',
                fontSize = 'medium',
            },
        }
    },			
}