// Anime Fantasy: Naruto World #16 script: security
#define function<%1> forward security_%1; public security_%1
function<OnGameModeInit()>
{
	// Validate Player Limit
	if(GetServerVarAsInt("maxplayers") != MAX_PLAYERS)
	{
		print("Please adjust the player limit to " #MAX_PLAYERS " in order to activate this gamemode.");
		GameModeExit();
		return 0;
	}
	// Check existance of directories
	const MAX_DIR_LEN = 32;
	new dirs[][MAX_DIR_LEN] = {DIR_MAIN,DIR_MOVIES,DIR_MAPS,DIR_INFOFILES,DIR_HELP,DIR_DESC,DIR_LOGS,DIR_DEBUG}, vname[MAX_DIR_LEN];
	for(new i = 0; i < sizeof(dirs); i++)
	{
		format(vname,MAX_DIR_LEN,"%s/",dirs[i]);
		if(!fexist(vname))
		{
			dcreate(dirs[i]);
			printf("Directory created: %s",dirs[i]);
		}
	}
	// Disable interiors
	DisableInteriorEnterExits();
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerText(playerid,text[])>
{
	if(PlayerInfo[playerid][pStatus] != e_PlayerStatus:player_status_playing) return 0;
	if(strlen(text) > 200) return security_Issue(playerid,1,"Chat message too long.");
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
	if(strlen(cmdtext) == 1) return chat_Error(playerid,"Forgot to enter the command?");
	if(strlen(cmdtext) > 200) return security_Issue(playerid,2,"Command text too long.");
	return 0;
}
function<OnPlayerSpawn(playerid)>
{
	if(PlayerInfo[playerid][SpawnAfterSpec]) return _:(PlayerInfo[playerid][SpawnAfterSpec] = false);
	return 1;
}
function<OnPlayerUpdate(playerid)>
{
	PlayerInfo[playerid][pIdleTime] = 0;
	ConnectionInfo[PlayerInfo[playerid][pConnectionID]][conIdleTime] = 0;
	// Disable any GTA SA weapon except of the camera
	if(GetPlayerWeapon(playerid) > 0 && GetPlayerWeapon(playerid) != WEAPON_CAMERA)
	{
		security_Issue(playerid,3,"Weapon detected.");
		ResetPlayerWeapons(playerid);
		return 0;
	}
	return 1;
}
function<OnVehicleSpawn(vehicleid)>
{
	// No vehicles to be spawned in my world!
	DestroyVehicle(vehicleid);
	security_Issue(-1,4,"Vehicle spawn detected.");
	return 1;
}
function<OnVehicleUpdate(vehicleid,playerid,passenger_seat,Float:new_x,Float:new_y,Float:new_z)>
{
	// Also not any vehicle movement!
	DestroyVehicle(vehicleid);
	security_Issue(-1,5,"Vehicle update detected.");
	return 0;
}
function<OnPlayerInteriorChange(playerid,newinteriorid,oldinteriorid)>
{
	// And no interiors!
	if(!newinteriorid) return 1;
	security_Issue(playerid,6,"Interior detected.");
	SetPlayerInterior(playerid,0);
	return 0;
}
function<OnPlayerKeyPress(playerid,keyid,modifier)>
{
	if(PlayerInfo[playerid][pLoading][0] != LOADING_NONE && PlayerInfo[playerid][pLoading][0] != LOADING_END2) return 0;
	return 1;
}
public OnRuntimeError(code, &bool:suppress) // from crashdetect.inc
{
	//security_Log("CrashDetect",""); like i'm going to log an unknown number of error code X_X
	return 1;
}
#undef function
// Security Issue
@f(_,security.Issue(playerid,num,text[]))
{
	f("SECURITY ISSUE #%02d: %s",num,text);
	if(player_IsConnected(playerid)) chat_Error(playerid,fstring);
	else Loop(player,i) chat_Error(i,fstring);
	return 1;
}
@f(_,security.Log(logname[],text[],playerid=INVALID_PLAYER_ID))
{
	new string[M_S_DB], date[3], File:flog;
	getdate(date[0],date[1],date[2]);
	format(string,sizeof(string),DIR_LOGS "/%s/",logname);
	if(!fexist(string)) dcreate(string);
	format(string,sizeof(string),"%s%s_%s.log",string,logname,time_GetDateAsString('_'));
	if((flog = fopen(string,fexist(string) ? io_append : io_write)))
	{
		format(string,sizeof(string),"[%s %s %s %s] ",time_GetDateAsString(),time_GetTimeAsString(true),e_ScriptName(e_CurrentScript()),logname);
		if(playerid != INVALID_PLAYER_ID) format(string,sizeof(string),"%s(P%03d/U%03d) %s: ",string,playerid,PlayerInfo[playerid][pUserID],player_GetNickname(playerid),text);
		format(string,sizeof(string),"%s%s\r\n",string,text);
		fwrite(flog,string);
		fclose(flog);
	}
	return 1;
}
