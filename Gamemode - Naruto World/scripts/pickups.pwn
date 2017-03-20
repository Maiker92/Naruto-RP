// Anime Fantasy: Naruto World #15 script: pickups
#define function<%1> forward pickups_%1; public pickups_%1
function<OnGameModeInit()>
{
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Pickups)));
	new m = sqlite_NumRows(), spid = 0, Float:p[3], permission[MAX_NAME_LENGTH];
	if(m >= 1 && m <= MAX_SPICKUPS) for(new i = 0; i < m; i++)
	{
		spid = strval(sqlite_GetField("id"));
		SPickupInfo[spid][spValid] = true;
		SPickupInfo[spid][spType] = pickup_GetTypeFromID(strval(sqlite_GetField("type")));
		SPickupInfo[spid][spModelID] = strval(sqlite_GetField("modelid"));
		str_loadxyz(sqlite_GetField("pos"),p);
		SPickupInfo[spid][spPos] = p;
		SPickupInfo[spid][spPickupID] = CreatePickup(SPickupInfo[spid][spModelID],1,SPickupInfo[spid][spPos][0],SPickupInfo[spid][spPos][1],SPickupInfo[spid][spPos][2],VW_WORLD);
		format(SPickupInfo[spid][spParam],64,sqlite_GetField("param"));
		if(SPickupInfo[spid][spType] == e_PickupType:pickup_info) infofile_Check(infofile_Format("Pickup",SPickupInfo[spid][spParam]));
		format(permission,sizeof(permission),sqlite_GetField("permission"));
		SPickupInfo[spid][spPermission] = strlen(permission) > 0 ? perm_Index(permission) : -1;
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerPickUpPickup(playerid,pickupid)>
{
	new spid = -1;
	for(new i = 0; i < MAX_SPICKUPS && spid == -1; i++) if(SPickupInfo[i][spValid] && SPickupInfo[i][spPickupID] == pickupid) spid = i;
	if(spid != -1)
	{
		if(PlayerInfo[playerid][pSPID] == spid) return 1;
		if(SPickupInfo[spid][spPermission] != -1) if(!perm_Check(playerid,Permissions[SPickupInfo[spid][spPermission]][permCode])) return 1;
		PlayerInfo[playerid][pSPID] = spid;
		switch(SPickupInfo[spid][spType])
		{
			case pickup_teleport:
			{
				screenfade_Start(playerid,e_ScreenFade:screenfade_teleport,CC_COLOR_BLACK,10,2,spid);
				player_Freeze(playerid,true);
			}
			case pickup_info: infofile_Show(playerid,infofile_Format("Pickup",SPickupInfo[spid][spParam]));
		}
	}
	return 1;
}
function<OnPlayerEndScreenFade(playerid,e_ScreenFade:type,fadetype,fadeparam)>
{
	if(type == e_ScreenFade:screenfade_teleport && fadetype == 2)
	{
		new Float:p[4];
		str_loadxyza(SPickupInfo[fadeparam][spParam],p);
		player_SetPosition(playerid,p[0],p[1],p[2]);
		player_SetAngle(playerid,p[3]);
		player_Freeze(playerid,false);
		camera_Reset(playerid);
	}
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(interval % 1000 == 0 && PlayerInfo[playerid][pSPID] != INVALID_SPICKUP) if(!IsPlayerInRangeOfPoint(playerid,3.0,SPickupInfo[PlayerInfo[playerid][pSPID]][spPos][0],SPickupInfo[PlayerInfo[playerid][pSPID]][spPos][1],SPickupInfo[PlayerInfo[playerid][pSPID]][spPos][2])) PlayerInfo[playerid][pSPID] = INVALID_SPICKUP;
	return 1;
}
#undef function
// Pickup
@f(e_PickupType,pickup.GetTypeFromID(id))
{
	new e_PickupType:ret = e_PickupType:pickup_none;
	switch(id)
	{
		case 1: ret = e_PickupType:pickup_teleport;
		case 2: ret = e_PickupType:pickup_info;
	}
	return ret;
}
