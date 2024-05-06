local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.10.2'] = {
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
                name = 'Expect to see multiple releases as TWW draws closer.',
            },
            TOC = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Bumped toc to 10.2.7.',
            },
            Network = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed a rare networking issue where a packet could get lost.',
            },
            Logout = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Implemented more robust logout detection.',
            },
            Refactor = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Restructured code to distinguish between retail and classic.',
            },
            LibSharedMedia = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated SharedMedia library to version 10.2.2.',
            },
            LibAce = {
                order = 7,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated Ace3 libraries to version 1320.',
            },
            LibTourist = {
                order = 8,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated Tourist libraries to version 10.2.6.1.',
            },
        },
    },		
}