local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['3.5.2'] = {
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
                name = 'Readjust channel colors based on ID after Blizzard sets them by #.',
            },
            Two = {
                order = 2,
                type = 'description',
                name = 'Implemented try/catch/finally exception handling for all timers/events/inputs.',
                fontSize = 'medium',
            },
            Three = {
                order = 3,
                type = 'description',
                name = 'Prompts user when it detects a newer version available.',
                fontSize = 'medium',
            },
            Four = {
                order = 4,
                type = 'description',
                name = 'Localized zone text.',
                fontSize = 'medium',
            },
            Five = {
                order = 5,
                type = 'description',
                name = 'Reduced message size by sending zone IDs instead of full text.',
                fontSize = 'medium',
            },
            Six = {
                order = 6,
                type = 'description',
                name = 'Added Metrics (X) DT that displays the following total/average values: Total/BNet/Local messages sent/received, Warnings, Errors.',
                fontSize = 'medium',
            },
        }
    },	
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed spaces in channel listing causing addon to break.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed exception caused by friend playing neutral faction on same realm.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed random exception on initial login.',
            },
            Four = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed receiving local guild logoff messages if login/logoff option unchecked.',
            },
            Five = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed race condition with ElvUI chat handler.',
            },
            Six = {
                order = 6,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed Guild right-click menu showing behind the tooltip (Zoombara).',
            },
        }
    },		
}