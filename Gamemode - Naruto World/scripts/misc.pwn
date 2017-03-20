// Anime Fantasy: Naruto World #01 script: misc
#define function<%1> forward misc_%1; public misc_%1
function<OnGameModeInit()>
{
	// Incognito's Streamer Settings
	Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT,MAX_OBJECTS - 1);
	Streamer_SetMaxItems(STREAMER_TYPE_OBJECT,MAX_STREAMED_OBJECTS);
	Streamer_SetVisibleItems(STREAMER_TYPE_AREA,MAX_STREAMED_AREAS);
	Streamer_SetMaxItems(STREAMER_TYPE_AREA,MAX_STREAMED_AREAS);
	Streamer_SetTickRate(20);
	// Creating Default Dialogs
	dialog_Create(d_Message,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Message","OK","",d_Null);
	dialog_AddLine(@c(DIALOG_HEADER) "(!) MESSAGE\n\n" @c(DIALOG_NOTICE) "{1}");
	dialog_Create(d_Error,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Error","OK","",d_Null);
	dialog_AddLine(@c(DIALOG_HEADER) "(!) ERROR\n\n" @c(DIALOG_ERROR) "{1}");
	dialog_Create(d_Soon,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Soon","OK","",d_Null);
	dialog_AddLine(@c(DIALOG_HEADER) "(!) COMING SOON!\n\n" @c(DIALOG_EXPLAIN) "The option or feature you're trying to access (" @c(DIALOG_BOLD) "{1}" @c(DIALOG_EXPLAIN) ") is not available right now.\nIt will be activated on future versions.");
	infofile_Initialize(); // Info File Dialogs
	// Checking Server SQL
	new serverDatabaseTables[][M_S_DB] =
	{
		"`accounts` (`id` INTEGER PRIMARY KEY, `name` TEXT, `password` TEXT, `code` TEXT)",
		"`players` (`uid` INTEGER, `cuid` TEXT, `type` INTEGER, `dna` TEXT, `status` INTEGER, `xp` INTEGER, `level` INTEGER, `lastpos` TEXT)",
		"`admins` (`id` INTEGER PRIMARY KEY, `level` INTEGER)",
		"`admincmds` (`cmdtext` TEXT, `level` INTEGER)",
		"`settings` (`name` TEXT, `value` TEXT)"
	};
	for(new i = 0; i < sizeof(serverDatabaseTables); i++) sqlite_Query(serverDatabase,f("CREATE TABLE IF NOT EXISTS %s",serverDatabaseTables[i]));
	// Loading Settings
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Settings)));
	for(new i = 0, m = sqlite_NumRows(); i < m; i++)
	{
		property_StrSet(f("setting_%s",sqlite_GetField("name")),sqlite_GetField("value"));
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Settings)));
	for(new i = 0, m = sqlite_NumRows(); i < m; i++)
	{
		property_StrSet(f("setting_%s",sqlite_GetField("name")),sqlite_GetField("value"));
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	// Side Menus Initialize
	for(new i = 0; i < MAX_SIDE_MENUS; i++) SideMenuInfo[i][smValid] = false, SideMenuInfo[i][smID] = e_SideMenu:sidemenu_none, SideMenuInfo[i][smParent] = -1, SideMenuInfo[i][smSubID] = 0;
	for(new i = 0, m = MAX_SIDE_MENUS * MAX_SIDE_BUTTONS; i < m; i++) SideMenuButtonInfo[i][smbValid] = false;
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
	PlayerInfo[playerid][pIdleTime] = 0;
	// Temporary commands
 	command(kill,cmdtext);
 	command(movie,cmdtext);
 	command(end,cmdtext);
 	command(refreshgproperties,cmdtext);
 	command(snd,cmdtext);
 	command(camerapos,cmdtext);
 	command(cam,cmdtext);
	return 0;
}
function<OnPlayerDeath(playerid,killerid,reason)>
{
	// Temporary death list
	SendDeathMessage(killerid,playerid,reason);
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second))
	{
		// Calculating Idle Time
		if(!cursor_IsVisible(playerid)) PlayerInfo[playerid][pIdleTime]++;
		// Hiding Notifications
		if(PlayerInfo[playerid][pNotificationTime] > 0)
		{
			PlayerInfo[playerid][pNotificationTime]--;
			if(!PlayerInfo[playerid][pNotificationTime]) ptd_Hide(playerid,e_PlayerTD:ptd_notifications);
		}
	}
	if(timer_MeetsTimeUnit(interval,timeunit_halfsec))
	{
		new trg = GetPlayerTargetPlayer(playerid);
		if(PlayerInfo[playerid][pTargetPlayerID] != trg)
		{
			OnPlayerTargetPlayer(playerid,PlayerInfo[playerid][pTargetPlayerID],trg);
			PlayerInfo[playerid][pTargetPlayerID] = trg;
		}
	}
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	PlayerInfo[playerid][pIdleTime] = 0;
	return 1;
}
function<OnPlayerText(playerid,text[])>
{
	PlayerInfo[playerid][pIdleTime] = 0;
	return 1;
}
function<OnPlayerKeyPress(playerid,keyid,modifier)>
{
	// Detect side menu keys
	new m = sidemenu_GetCurrent(playerid);
	if(m > -1)
	{
		new listitem = -1;
		for(new i = 0; i < SideMenuInfo[m][smButtons] && listitem == -1; i++) if(keyid == SideMenuButtonInfo[SideMenuInfo[m][smButton][i]][smbKeyID]) listitem = i;
		if(listitem != -1)
		{
			sound_PlaySystem(playerid,e_SystemSound:syssnd_click);
			return OnSideMenuClick(playerid,SideMenuInfo[m][smID],SideMenuInfo[m][smSubID],SideMenuButtonInfo[SideMenuInfo[m][smButton][listitem]][smbCode]), 0;
		}
	}
	return 1;
}
function<OnPlayerClickTD(playerid,Text:clickedid)>
{
	if(clickedid == INVALID_TEXT_DRAW)
	{
		if(cursor_IsVisible(playerid)) cursor_Show(playerid);
		return 1; // Don't call the event when player have cancelled the selection
	}
	sound_PlaySystem(playerid,e_SystemSound:syssnd_click);
	return 0;
}
function<OnPlayerClickPTD(playerid,PlayerText:playertextid)>
{
	sound_PlaySystem(playerid,e_SystemSound:syssnd_click);
	return 0;
}
function<OnPlayerEnterArea(playerid,areaid)>
{
	if(GetPVarType(playerid,areaformat(areaid)) != PLAYER_VARTYPE_NONE) return 0;
	SetPVarInt(playerid,areaformat(areaid),1);
	return 1;
}
function<OnPlayerLeaveArea(playerid,areaid)>
{
	if(GetPVarType(playerid,areaformat(areaid)) == PLAYER_VARTYPE_NONE) return 0;
	DeletePVar(playerid,areaformat(areaid));
	return 1;
}
#undef function
// Private
static stock areaformat(areaid)
{
	new s[32];
	return (format(s,sizeof(s),"in_area_%d",areaid), s);
}
// Misc
@f(_,misc.Setting(key[]))
{
	new val[64];
	format(val,sizeof(val),property_StrGet(f("setting_%s",key)));
	return val;
}
@f(_,misc.Notification(playerid,type,message[]))
{
	new col = 0, e_SystemSound:snd;
	switch(type)
	{
		case NOTIFICATION_ERROR: col = -939511041, snd = syssnd_cancel;
		case NOTIFICATION_INFO: col = 947568191, snd = syssnd_info;
		default: return 1;
	}
	PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][91],col);
	PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][91],message);
	ptd_Show(playerid,e_PlayerTD:ptd_notifications);
	sound_PlaySystem(playerid,snd);
	PlayerInfo[playerid][pNotificationTime] = 2 + (str_countchar(message,' ') / 2);
	return 1;
}
@f(_,misc.GenerateRandomName(type))
{
	new r, s[MAX_NAME_LENGTH];
	do r = random(sizeof(Names));
	while Names[r][nameType] != type;
	format(s,sizeof(s),Names[r][nameString]);
	return s;
}
// Commands
cmd.kill(playerid,params[])
{
	#pragma unused params
	health_Kill(playerid);
	return 1;
}
cmd.movie(playerid,params[])
{
	#pragma unused params
	movie_Start(playerid,0);
	return 1;
}
cmd.end(playerid,params[])
{
	#pragma unused params
	movie_Stop(playerid);
	return 1;
}
cmd.refreshgproperties(playerid,params[])
{
	#pragma unused playerid, params
	property_Refresh();
	return 1;
}
cmd.snd(playerid,params[]) return PlayerPlaySound(playerid,strval(params),0.0,0.0,0.0), 1;
cmd.camerapos(playerid,params[])
{
	#pragma unused playerid
	idx = 0;
	for(new i = 0; i < 3; i++) cmdt = str_tok(params,idx), PlayerInfo[playerid][pCamera][i] += floatstr(cmdt);
	camera_SetPos(playerid,PlayerInfo[playerid][pCamera][0],PlayerInfo[playerid][pCamera][1],PlayerInfo[playerid][pCamera][2]);
	return 1;
}
cmd.cam(playerid,params[])
{
	SetPlayerCameraDistance(playerid,floatstr(params));
	return 1;
}
