local L = LibStub('AceLocale-3.0'):NewLocale('XFaction', 'esMX')
if not L then return end

--=========================================================================
-- Generic One Word Translations
--=========================================================================
L['CONFEDERATE'] = 'Confederación'
L['MOTD'] = 'Mensaje del día'
L['DATATEXT'] = 'DataText'
L['SUPPORT'] = 'Soporte'
L['RESOURCES'] = 'Rrecursos'
L['DISCORD'] = 'Discord'
L['GITHUB'] = 'GitHub'
L['DEV'] = 'Ddesarrollo'
L['DISCLAIMER'] = 'Advertencia'
--=========================================================================
-- General (tab) Specific
--=========================================================================
L['GENERAL_DESCRIPTION'] = 'Activa visibilidad de lista de miembros y comunicación entre hermandades de la confederación, incluyendo hermandades en otros reinos o de la facción contraria'
L['GENERAL_DISCLAIMER'] = 'Este addon está en fase alpha y actualmente solo da soporte a Eternal Kingdom (EK) '
L['GENERAL_WHAT'] = 'Que incluye'
L['GENERAL_GUILD_CHAT'] = '1. Chat de hermandad vinculados a través de hermandades/reinos/facciones en la condeferación'
L['GENERAL_GUILD_CHAT_ACHIEVEMENT'] = '2. Logros personales redireccioneados a los miembros de la conferecaión en otras hermandades'
L['GENERAL_SYSTEM_LOGIN'] = '1. Recibir notificaciones cuando un jugador usando el addon está en linea o se desconecta de la confederación'
L['GENERAL_DATA_BROKERS'] = 'Agentes de datos'
L['GENERAL_DTGUILD'] = '1. Hermandad (X): Lista completa de miembros visible en la confederación'
L['GENERAL_DTLINKS'] = '2. Vínculos (X): Vísibilidad de los vínculos activos de BNet en la confederación usados por el addon'
L['GENERAL_DTTOKEN'] = '4. Ficha de WoW (X): Ver el precio actual de la ficha de WoW'
--=========================================================================
-- Chat Specific
--=========================================================================
L['CHAT_GUILD_TOOLTIP'] = 'Ver chat de hermandad a través de facción y reinos '
L['CHAT_FACTION'] = 'Mostrar facción'
L['CHAT_FACTION_TOOLTIP'] = 'Mostrar el ícono de la facción del mensajero'
L['CHAT_GUILD_NAME'] = 'Mostrar nombre de hermandad'
L['CHAT_GUILD_NAME_TOOLTIP'] = 'Mostrar el nombre de hermandad abreviado para el mensajero'
L['CHAT_MAIN'] = 'Mostrar nombre del personaje principal'
L['CHAT_MAIN_TOOLTIP'] = 'Mostrar el nombre del personaje principal del mensajero si está en un personaje alterno'
L['CHAT_FONT_COLOR'] = 'Color de Fuente'
L['CHAT_ACHIEVEMENT_TOOLTIP'] = 'Ver logros individuales a través de facción y reinos'
L['CHAT_ONLINE'] = 'En linea/Desconectado'
L['CHAT_ONLINE_TOOLTIP'] = 'Mostrar mensaje para los jugadores conectandose/desconectandose en otros reinos/faccón'
--=========================================================================
-- DataText Specific
--=========================================================================
L['DT_HEADER_CONFEDERATE'] = 'Confederación: |cffffffff%s|r'
L['DT_HEADER_GUILD'] = 'Hermandad: |cffffffff%s|r'
-------------------------
-- DTGuild (X)
-------------------------
-- Broker name
L['DTGUILD_NAME'] = 'Hermandad (X)'
-- Config
L['DTGUILD_CONFIG_SORT'] = 'Clasificación de columnas predeterminada'
L['DTGUILD_CONFIG_HEADER'] = 'Mostrar campos de encabezado'
L['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'] = 'Mostrar el nombre de la confederación'
L['DTGUILD_CONFIG_GUILD_TOOLTIP'] = 'Mostrar el nombre de la hermandad actual'
L['DTGUILD_CONFIG_MOTD_TOOLTIP'] = 'Mostrar el mensaje del día de la hermandad'
L['DTGUILD_CONFIG_COLUMN_HEADER'] = 'Mostrar Columnas'
L['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'] = 'Mostrar el nombre de la Hermandad del jugador'
L['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'] = 'Mostrar el nivel del jugador'
L['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'] = 'Mostrar la nota del jugador'
L['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'] = 'Mostrar los íconos de las profesiones del jugador'
L['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'] = 'Mostrar la raza del jugador'
L['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'] = 'Mostrar el rango del jugador'
L['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'] = 'Mostrar el nombre del reino del jugador'
L['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'] = 'Mostrar el ícono de la especialización del jugador'
L['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'] = 'Mostrar el nombre del equipo del jugador'
L['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'] = 'Mostrar la zona actual del jugador'
-------------------------
-- DTLinks (X)
-------------------------
-- Broker name
L['DTLINKS_NAME'] = 'Vínculos (X)'
-- Header
L['DTLINKS_HEADER_LINKS'] = 'Vínculos de BNet activoss: |cffffffff%d|r'
-- Config
L['DTLINKS_CONFIG_ONLY_YOURS'] = 'Mostrar solo los tuyos'
L['DTLINKS_CONFIG_ONLY_YOURS_TOOLTIP'] = 'Mostrar solo tus vinculos activos'
-------------------------
-- DTShard (X)
-------------------------
-- Broker name
L['DTSHARD_NAME'] = 'Fragmento (X)'
-- Broker text
L['DTSHARD_SHARD_ID'] = 'Fragmento: %d'
-- Config
L['DTSHARD_CONFIG_FORCE_CHECK'] = 'Comprobación forzada'
L['DTSHARD_CONFIG_FORCE_CHECK_TOOLTIP'] = 'Segundos entre comprobaciónes de fragmentos sin eventos'
-------------------------
-- DTToken (X)
-------------------------
-- Broker name
L['DTTOKEN_NAME'] = 'Ficha de WoW (X)'
--=========================================================================
-- Support Specific
--=========================================================================
L['SUPPORT_UAT'] = 'Pruebas de aceptación del usuario'