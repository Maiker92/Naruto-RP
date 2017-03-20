// Types
enum e_Cache
{
	cache_func = 0,
	cache_max_func = 70,
	cache2_skinidx = 0
}
enum e_PlayerStatus
{
	player_status_none,
	player_status_connecting,
	player_status_intro,
	player_status_playing
}
enum e_Damage
{
	damage_none,
	damage_taijutsu,
	damage_ninjutsu,
	damage_genjutsu,
	damage_true
}
enum e_Stats
{
	stats_none,
	stats_health,
	stats_healthreg,
	stats_chakra,
	stats_chakrareg,
	stats_movespeed,
	stats_attackspeed,
	stats_jump,
	stats_evasion,
	stats_critical,
	stats_cooldown,
	stats_lifesteal,
	stats_vision,
	stats_basicattack,
	stats_hearing,
	stats_noise
}
enum e_SQLiteTable
{
	// game
	st_Characters,
	st_OwnCharacters,
	st_Summonings,
	st_Teams,
	st_Sounds,
	st_Powers,
	st_Places,
	st_Items,
	st_NPCs,
	st_Missions,
	st_Events,
	st_Jinchuuriki,
	st_Factions,
	st_Auras,
	st_Behaviors,
	st_Elements,
	st_Pickups,
	st_Spawns,
	st_Intros,
	st_Paths,
	st_TextLines,
	// server
	st_Accounts,
	st_Players,
	st_Admins,
	st_AdminCommands,
	st_Permissions,
	// hybrid
	st_Settings
}
enum e_Dialog
{
	d_Null,
	d_Message,
	d_Error,
	d_CharacterSelect,
	d_Logout,
	d_InfoFile,
	d_Help,
	d_HelpSub,
	d_PowerDesc,
	d_PowerCategory,
	d_Soon,
	d_Stats,
	d_SelectNPC,
	d_SkinList,
	d_NPCCustomDist,
	d_NoCharacter,
	d_Community,
	d_InsufficientPermission,
	d_Permissions,
	d_ManagePermissions,
	d_ViewPermissions,
	d_ListPermissions,
	d_SelectPlayer,
	d_SelectPlayer_Text,
	d_SelectPlayer_Tab,
	d_SelectPlayer_Accept,
	d_SelectPlayer_Cancel,
	d_SetTime,
	d_SetWeather,
	d_PlayerInfo
}
enum e_GPropertyType
{
	gptype_null,
	gptype_int,
	gptype_str
}
enum e_Chats
{
	chat_admins
}
enum e_PowerTypes
{
	powertype_none,
	powertype_active,
	powertype_passive
}
enum e_PowerTargets
{
	powertarget_none,
	powertarget_self,
	powertarget_single,
	powertarget_radius,
	powertarget_groundline,
	powertarget_line,
	powertarget_circle,
	powertarget_square,
	powertarget_sphere,
	powertarget_point
}
enum e_PowerEffects
{
	peDamage,
	peDPS,
	peHeal,
	peSummon,
	peClone,
	peKnockback,
	peCrowdControl,
	peTransform,
	peBuff,
	peDebuff,
	peAura,
	peSilence,
	peBasicAttack,
	peProjectile,
	peChakra
}
enum e_PowerUses
{
	puNoUse,
	puOffensive,
	puDefensive,
	puEscape,
	puSensory,
	puSupport,
	puUtility
}
enum e_Animation
{
	anim_none,
	anim_death,
	anim_chat,
	anim_shout,
	anim_dance,
	anim_sit,
	anim_wave
}
enum e_SystemSound
{
	syssnd_cancel,
	syssnd_info,
	syssnd_click,
	syssnd_tick
}
enum e_SoundEffect
{
	snd_hit,
	snd_jump,
	snd_land,
	snd_cloneout,
	snd_villager_death,
	snd_villager_hit,
	snd_villager_talk,
	snd_insperm
}
enum e_BackgroundMusic
{
	bgm_home
}
enum e_TimeUnit
{
	timeunit_hour = 3600000,
	timeunit_minute = 60000,
	timeunit_second = 1000,
	timeunit_halfsec = 500,
	timeunit_quarsec = 250,
	timeunit_tenth = 100, // JUUDAIME TSUNA!
	timeunit_jiffy = 10
}
enum e_PlayerTD
{
	ptd_none,
	ptd_stats,
	ptd_powers,
	ptd_items,
	ptd_loading,
	ptd_notifications,
	ptd_buffs,
	ptd_soundtrack,
	ptd_movie
}
enum e_GlobalTD
{
	gtd_character,
	gtd_map,
	gtd_menu,
	gtd_startup
}
enum e_ProgressBar
{
	pb_health,
	pb_chakra,
	pb_loading,
	pb_xp
}
enum e_ScreenFade
{
	screenfade_none,
	screenfade_movie,
	screenfade_teleport
}
enum e_PickupType
{
	pickup_none,
	pickup_teleport,
	pickup_info
}
enum e_BuffType
{
	buff_none,
	buff_stats,
	buff_damage,
	buff_protection,
	buff_lowerstats
}
enum e_SoundType
{
	soundtype_none,
	soundtype_system,
	soundtype_effect,
	soundtype_music,
	soundtype_voice
}
enum e_AreaType
{
	areatype_none,
	areatype_circle,
	areatype_rectangle,
	areatype_sphere,
	areatype_cube
}
enum e_AreaUse
{
	areause_none,
	areause_sobject,
	areause_npc
}
enum e_LinkType
{
	link_website,
	link_teamspeak
}
enum e_PathType
{
	path_point,
	path_spawn,
	path_endpoint
}
enum e_RouteOwnerType
{
	routeowner_none,
	routeowner_npc,
	routeowner_object
}
enum e_RouteMoveType
{
	routemove_path,
	routemove_random
}
enum e_PlayerInfoType
{
	pinfotype_stats,
	pinfotype_dstats,
	pinfotype_character,
	pinfotype_profile,
	pinfotype_friends,
	pinfotype_accolades,
	pinfotype_acheivements
}
enum e_NPCUsage
{
	npcusage_none,
	npcusage_test,
	npcusage_clone,
	npcusage_pet,
	npcusage_villager,
	npcusage_intro
}
enum e_NPCBehaviour
{
	npcbehaviour_none,
	npcbehaviour_neutral,
	npcbehaviour_positive,
	npcbehaviour_negative,
	npcbehaviour_snegative
}
enum e_NPCProCommand
{
	npcprocmd_none,
	npcprocmd_offensive,
	npcprocmd_defensive
}
enum e_SideMenu
{
	sidemenu_none,
	sidemenu_npccontrol
}
enum e_TargetReason
{
	targetreason_none,
	targetreason_power,
	targetreason_sidemenu,
	targetreason_playerselect
}
enum e_VillagerAction
{
	villageract_walk,
	villageract_sit,
	villageract_rest,
	villageract_speak,
	villageract_read,
	villageract_eat,
	villageract_drink
}
enum e_SpecialObjectEffect
{
	soeffect_none,
	soeffect_damage,
	soeffect_poison,
	soeffect_plantsnd
}
enum e_SpecialObjectType
{
	sotype_none,
	sotype_plant,
	sotype_tree,
	sotype_building,
	sotype_street,
	sotype_pickup
}
enum e_VillagerMessage
{
	vilmsg_hello,
	vilmsg_sign
}
enum e_SelectionSource
{
	selsrc_none,
	selsrc_dialog
}
// Data
enum data_Player
{
	pArrayPos,
	pName[MAX_PLAYER_NAME],
	pDisplayName[MAX_PLAYER_NAME],
	pDisplayNickname[MAX_PLAYER_NAME],
	pIP[16],
	pCharacter,
	pOriginalCharacter,
	pClass,
	pConnectionID,
	pIdleTime,
	pInfoArray[10],
	#define pInfoArray_Int_Max 15
	pInfoArray_Int[pInfoArray_Int_Max],
	#define pInfoArray_Float_Max 4
	Float:pInfoArray_Float[pInfoArray_Float_Max],
	bool:pDied,
	PlayerText:pPTD[MAX_PTD],
	pPTDAlpha[MAX_PTD_ALPHA],
	e_PlayerTD:pPTDAlphaID[MAX_PTD_ALPHA],
	pPTDAlphaColor[MAX_PTD_ALPHA],
	bool:pPTDNeedAlpha,
	pLevel,
	pXP,
	pUserID,
	pPlayerID,
	e_PlayerStatus:pStatus,
	bool:pLogged,
	pFailedLogins,
	pTeam,
	Float:pCamera[9],
	pCameraUpdates,
	pInterpolate[3],
	pWatchingMovie[2],
	pPlayingSound[MAX_SOUNDS],
	pSoundPosition[MAX_SOUNDS],
	pSoundLength[MAX_SOUNDS],
	bool:pSoundLoop[MAX_SOUNDS],
	pListSound[MAX_SOUNDS],
	pListSounds,
	pLastMusicPlayed,
	pUnderAttack,
	e_ScreenFade:pScreenFade,
	pScreenFadeInfo[5], // 0 = fade type, 1 = param, 2 = pos, 3 = color, 4 = tick
	pAdmin,
	pSPID,
	pMoney,
	pLoading[2],
	bool:pLoadedAnimations,
	pHelpFile[MAX_NAME_LENGTH],
	Text3D:pNameTag,
	pNameTagDetails[3],
	pNameTagAdditional[32],
	Float:pHealth,
	Float:pChakra,
	pDOT[MAX_EFFECTS_PER_TIME],
	pHOT[MAX_EFFECTS_PER_TIME],
	pDPS[MAX_EFFECTS_PER_TIME],
	pCrowdControl[2], // 0 = cc type, 1 = cc time left
	pBuff[MAX_BUFFS_PER_PLAYER],
	bool:pBuffType[MAX_BUFFS_PER_PLAYER],
	pCooldown[MAX_POWER_CATEGORIES],
	pSavedCooldown[MAX_POWER_CATEGORIES],
	bool:pFrozen,
	bool:pCursorShow,
	pPowerSelection[2],
	pNotificationTime,
	e_TargetReason:pTargetReason,
	pTargetType,
	Float:pTargetPosition[3],
	pTargetObject[MAX_TARGET_OBJECTS],
	pTargetObjects,
	Float:pTargetFloats[3], // 0 = move rate, 1 = range, 2 = radius
	pTargetIcon[2],
	bool:pRoot,
	Float:pRootPoint[3],
	bool:pSilence[7],
	pBasicAttack[4],
	pBasicAttackCode[16],
	Float:pPosition[4],
	Float:pSpawnPos[4],
	pNPCIndex,
	bool:pSpawned,
	pPowerPrepare[4], // 0 = power idx, 1 = category, 2 = index, 3 = used
	pSideMenu[2],
	pNPC[MAX_NPCS],
	pNPCs,
	pNPCCommand[3], // 0 = control, 1 = command, 2 = parameter
	Float:pVision,
	bool:pBindedKeys[MAX_KEY_ID-MIN_KEY_ID],
	pConnected,
	pIsNPC,
	pKick,
	Float:pNPCFollowCD,
	pLastChat[MAX_CHAT_LENGTH],
	pAnimation,
	pDialogParam[32],
	bool:pDialogOneButton,
	bool:SpawnAfterSpec,
	pIntro,
	Float:pLastPos[4],
	pSObject[3], // 0 = object id, 1 = seat, 2 = stage
	pSelectionID[3], // 0 = playerid, 1 = player id, 2 = user id
	e_SelectionSource:pSelectionSource,
	pSelectionSourceID,
	pSelectionReason[64],
	e_Dialog:pDialog,
	pLastDialogInfo[3], // 0 = dialog id, 1 = response, 2 = listitem
	bool:pSuperJetpack,
	Float:pModifiedJump,
	pDialogSelect,
	bool:pDebugAnimations,
	pJumpGravityModify,
	pFocusDebugVillager,
	pTargetPlayerID,
	bool:pSavingPathCoords,
	Float:pSavingPathDistance[2]
}
enum data_Character
{
	bool:cValid,
	cID,
	cName[64],
	cDisplayName[64],
	cFirstName[64],
	cUID[16],
	cStatus,
	cNicknames,
	cAvatar[MAX_NAME_LENGTH],
	cSkin,
	cTeam,
	cTotal,
	cStr,
	cAgi,
	cInt,
	cSpc,
	cRespect,
	cLevel,
	cRank,
	cJinchuuriki,
	Text:cText[7],
	cGender
}
enum data_Connection
{
	bool:conLogged,
	conDisconnectReason[64],
	conPlayerID,
	conPlayerName[MAX_PLAYER_NAME],
	conIP[16],
	conIdleTime,
	conArrayPos,
	conHWID[64],
	conAutoLogin
}
enum data_Object
{
	oModel,
	bool:oValid,
	oArrayPos,
	Float:oPos[3],
	Float:oRot[3],
	Float:oSPos[3],
	Float:oSRot[3],
	oInteriors[OBJECT_MAX_INTERIORS],
	oWorlds[OBJECT_MAX_VIRTUAL_WORLDS],
	Float:oStreamDistance,
	oMap[2],
	oSID,
	oSArea,
	oSPlayers,
	oSPlayer[MAX_SOBJECT_SEATS]
}
enum data_Dialog
{
	dType,
	dTempType,
	e_Dialog:dParent,
	dText[M_D_L],
	dHeader[64],
	dButton1[MAX_NAME_LENGTH],
	dButton2[MAX_NAME_LENGTH]
}
enum data_GProperties
{
	bool:gpValid,
	gpName[64],
	e_GPropertyType:gpType,
	gpValue[64]
}
enum data_Team
{
	bool:tValid,
	tName[MAX_NAME_LENGTH],
	tSName[MAX_NAME_LENGTH],
	tLevel,
	tPopulation,
	tPath[MAX_TEAM_PATHS],
	tPaths,
	tLeader[MAX_NAME_LENGTH],
	tPermFamily[MAX_TEAM_PERMISSIONS],
	tPermFamilies,
	tKey[16],
	tKeyID
}
enum data_Sound
{
	bool:sndValid,
	sndName[MAX_NAME_LENGTH*2],
	sndCodeName[MAX_NAME_LENGTH*2],
	e_SoundType:sndType,
	sndAddress[128],
	sndMultiple,
	bool:sndIsURL
}
enum data_Movie
{
	bool:movValid,
	movName[MAX_NAME_LENGTH],
	movAuthor[MAX_NAME_LENGTH],
	movPath[MAX_MOVIE_PATHS],
	movCommands
}
enum data_MoviePath
{
	pathMovieID,
	Float:pathFromCam[3],
	Float:pathToCam[3],
	Float:pathFromLookAt[3],
	Float:pathToLookAt[3]
}
enum data_Map
{
	bool:mapValid,
	mapFile[64],
	mapName[MAX_NAME_LENGTH],
	mapAuthor[MAX_NAME_LENGTH],
	mapObject[MAX_OBJECTS_PER_MAP],
	mapObjects
}
enum data_Pickup
{
	bool:spValid,
	e_PickupType:spType,
	spPickupID,
	spModelID,
	Float:spPos[3],
	spParam[64],
	spPermission
}
enum data_Progress
{
	bool:pbValid,
	pbPlayerID,
	pbPTDID,
	Float:pbCoords[4],
	pbColors[2]
}
enum data_AdminCommands
{
	acCommand[32],
	acLevel,
	acHelp[128]
}
enum data_PowerEffectData
{
	e_PowerEffects:pfType,
	pfCode[16],
	pfParams
}
enum data_Power
{
	bool:pwValid,
	pwID,
	pwName[MAX_NAME_LENGTH],
	pwCode[MAX_NAME_LENGTH],
	pwAvatar[MAX_NAME_LENGTH],
	pwLevel,
	pwBuyable,
	e_PowerTypes:pwType,
	e_PowerTargets:pwTarget,
	Float:pwRange,
	Float:pwRadius,
	pwElement,
	e_PowerUses:pwUse,
	bool:pwEffect[MAX_POWER_EFFECTS]
}
enum data_List
{
	bool:listValid,
	listCount,
	listItems[MAX_LIST_ITEMS],
	bool:listItemSet[MAX_LIST_ITEMS]
}
enum data_Area
{
	bool:arValid,
	arArrayPos,
	e_AreaType:arType,
	Float:arCoords[6],
	e_AreaUse:arUse,
	arParam
}
enum data_Level
{
	lvlXP,
	lvlName[32]
}
enum data_NPC
{
	bool:npcConnected,
	e_NPCUsage:npcUsage,
	npcUsageID,
	npcCodeName[MAX_PLAYER_NAME],
	npcName[MAX_PLAYER_NAME],
	npcArrayPos,
	Text3D:npcTag,
	npcTagDetails[3],
	npcTagAdditional[32],
	npcPlayerID,
	Float:npcStats[4], // 0 = maxhealth, 1 = dmg, 2 = vision, 3 = attackspeed
	Float:npcHealth,
	e_NPCProCommand:npcProCommand,
	npcCommand,
	e_NPCBehaviour:npcBehaviour,
	npcLeader,
	npcFocus,
	npcFollow[2],
	bool:npcOnMove,
	npcAttacking[2],
	npcAbility[MAX_POWER_CATEGORIES],
	npcCooldown,
	npcPlayerIndex,
	npcDuration,
	npcArea,
	npcUnderAttack
}
enum data_SideMenu
{
	bool:smValid,
	e_SideMenu:smID,
	smHeader[32],
	smButton[MAX_SIDE_BUTTONS],
	smButtons,
	smParent,
	smSubID,
	Text:smMenuTD[2]
}
enum data_SideMenuButton
{
	bool:smbValid,
	smbMenu,
	smbKey[4],
	smbKeyID,
	smbCode[8],
	smbText[32],
	Text:smbButtonTD
}
enum data_Skin
{
	skID,
	skName[MAX_NAME_LENGTH]
}
enum data_Intros
{
	bool:itrValid,
	itrName[MAX_NAME_LENGTH],
	itrCharacter,
	itrMusic[MAX_NAME_LENGTH],
	itrScript,
	itrNPC[MAX_INTRO_NPCS],
	itrNPCs,
	itrWorld[2]
}
enum data_StartupButtons
{
	stbName[MAX_NAME_LENGTH],
	stbColor,
	Text:stbTD
}
enum data_Link
{
	lnkTarget[MAX_NAME_LENGTH],
	lnkURL[MAX_NAME_LENGTH],
	e_LinkType:lnkType
}
enum data_Path
{
	bool:pathValid,
	pathID,
	pathName[MAX_NAME_LENGTH],
	pathTeam,
	pathCount,
	Float:pathX[MAX_PATH_POSITIONS],
	Float:pathY[MAX_PATH_POSITIONS],
	Float:pathZ[MAX_PATH_POSITIONS],
	Float:pathXON[MAX_PATH_POSITIONS],
	Float:pathXOM[MAX_PATH_POSITIONS],
	Float:pathYON[MAX_PATH_POSITIONS],
	Float:pathYOM[MAX_PATH_POSITIONS],
	pathParent,
	pathConnection[MAX_PATH_CONNECTIONS],
	pathConnections,
	e_PathType:pathType
}
enum data_Route
{
	bool:rtValid,
	rtPath,
	e_RouteOwnerType:rtOwnerType,
	rtOwner,
	e_RouteMoveType:rtMoveType,
	rtParam,
	rtPosition,
	rtPositionParam,
	rtNextPosition,
	bool:rtLooping
}
enum data_Villager
{
	bool:vgrValid,
	vgrName[MAX_PLAYER_NAME],
	vgrGender,
	vgrNPC,
	vgrTeam,
	vgrPath,
	vgrRoute,
	vgrPos,
	e_VillagerAction:vgrAction,
	vgrActionInfo[2], // 0 = duration, 1 = stage
	vgrRespawnTime,
	vgrAArrayPos,
	vgrDArrayPos,
	bool:vgrBeingDebugged
}
enum data_SpecialObject
{
	e_SpecialObjectType:soType,
	soModelID,
	Float:soRadius,
	Float:soHeight,
	soMaxSeats,
	e_SpecialObjectEffect:soEffect,
	Float:soEffectParam,
	Float:soHealth
}
enum data_TextLines
{
	bool:tlValid,
	tlCode[32],
	tlCount
}
enum data_Name
{
	nameString[MAX_NAME_LENGTH],
	nameType // 1 = male, 2 = female, 3 = last name
}
enum data_PermissionFamilies
{
	permfamCode[MAX_NAME_LENGTH],
	permfamName[MAX_NAME_LENGTH]
}
enum data_Permissions
{
	permFamily,
	permCode[MAX_NAME_LENGTH],
	permName[64]
}
enum data_AdminOptions
{
	admoptName[MAX_NAME_LENGTH],
	admoptValue
}
// Elements
new Cache[MAX_CACHE_ITEMS] = {INVALID_CACHE,...};
new PlayerInfo[MAX_PLAYERS][data_Player];
new CharacterInfo[MAX_CHARACTERS][data_Character];
new ConnectionInfo[MAX_CONNECTIONS][data_Connection];
new ObjectInfo[MAX_STREAMED_OBJECTS][data_Object];
new DialogInfo[MAX_DIALOGS][data_Dialog];
new GPropertyInfo[MAX_GPROPERTIES][data_GProperties];
new TeamInfo[MAX_TEAMS][data_Team];
new SoundInfo[MAX_SOUNDS][data_Sound];
new MovieInfo[MAX_MOVIES][data_Movie];
new MoviePath[MAX_MOVIE_PATHS*MAX_MOVIES][data_MoviePath];
new MapInfo[MAX_MAPS][data_Map];
new SPickupInfo[MAX_SPICKUPS][data_Pickup];
new ProgressBar[MAX_PROGRESS_BARS][data_Progress];
new PowerInfo[MAX_POWERS][data_Power];
new ListInfo[MAX_LISTS][data_List];
new AreaInfo[MAX_STREAMED_AREAS][data_Area];
new NPCInfo[MAX_NPCS][data_NPC];
new SideMenuInfo[MAX_SIDE_MENUS][data_SideMenu];
new SideMenuButtonInfo[MAX_SIDE_MENUS*MAX_SIDE_BUTTONS][data_SideMenuButton];
new IntroductionInfo[MAX_INTROS][data_Intros];
new PathInfo[MAX_PATHS][data_Path];
new RouteInfo[MAX_ROUTES][data_Route];
new VillagerInfo[MAX_VILLAGERS][data_Villager];
new TextLinesInfo[MAX_TEXT_LINES][data_TextLines];
// Element Arrays
#define ElementArray<%1,%2,%3> new %1[%2+1] = {%3,...}, %1s = 0
ElementArray<player,MAX_PLAYERS,INVALID_PLAYER_ID>;
ElementArray<connection,MAX_CONNECTIONS,INVALID_CONNECTION>;
ElementArray<object,MAX_STREAMED_OBJECTS,INVALID_STREAMED_OBJECT>;
ElementArray<area,MAX_STREAMED_AREAS,INVALID_AREA>;
ElementArray<npc,MAX_NPCS,INVALID_PLAYER_ID>;
ElementArray<avillager,MAX_VILLAGERS,INVALID_VILLAGER_ID>;
ElementArray<dvillager,MAX_VILLAGERS,INVALID_VILLAGER_ID>;
#undef ElementArray
// Variables
new // Formatted / splitted strings
	fstring[256], fint = 0, fsplitted[20][M_S], n2s[16];
new // Used for player commands working with strtok
	cmdt[256], idx = 0;
new // SQLite DB
	DB:gameDatabase, DB:serverDatabase, dbResult[M_S], DBResult:dbResVar = NO_DB_RESULT;
new // Objects
	Float:objectOffsets[6];
new // Dialog
	e_Dialog:lastDialog = d_Null;
new // Teams
	Float:teamSpawn[MAX_TEAMS][MAX_TEAM_SPAWNS][4], teamSpawns[MAX_TEAMS] = {0,...};
new // Virtual worlds
	virtualWorldPlayers[MAX_VIRTUAL_WORLDS] = {0,...};
new // Screen fade text draw
	Text:fadeText;
new // Online players count
	onlinePlayers = 0, onlineAdmins = 0, totalPlayers = 0;
new // Global HUD instances
	Text:map, Text:menuButtons[MAX_MENU_BUTTONS+1];
new	// Lists
	collections[MAX_LISTS] = {INVALID_LIST_ID,...};
new // Server Uptime Interval
	serverUptime = 0;
new // World Definitions
	bool:isRainy = false, worldDefault[3] = {0,0,0}, worldCurrent[3] = {0,0,0};
new // Scripts Information
	currentScript = -1;
new // Audio Lists
	audio[MAX_SOUND_TYPES][MAX_SOUNDS] = {{-1,...},{-1,...},{-1,...}}, audios[MAX_SOUND_TYPES] = {0,...};
new // Object Lists
	mobject[MAX_OBJECT_MODELS][MAX_OBJECTS_PER_MODEL], mobjects[MAX_OBJECT_MODELS] = {0,...}, omodelUpper = 0;
