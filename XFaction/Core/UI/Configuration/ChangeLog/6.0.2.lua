local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.0.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Race = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Added support for Haranir allied race',
            },
            Spec = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Added support for Devourer spec',
            },
            Nameplate = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed nameplate augmentation via ElvUI, will not be supported in Midnight',
            },
            DTLinks = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated DTLinks to be more intuitive about who the addon is communicating with',
            },            
            Cleanup = {
                order = 7,
                type = 'description',
                fontSize = 'medium',
                name = 'Various code cleanup',
            },
            Library = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated Ace3 and LibSharedMedia libraries',
            },
            API = {
                order = 8,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated chat/bnet api calls to Midnight versions',
            },
            Season = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Added Midnight season 1 dungeons',
            },
            MSA = {
                order = 9,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed MSA library that was not working with Midnight',
            },
        },
    },		
}