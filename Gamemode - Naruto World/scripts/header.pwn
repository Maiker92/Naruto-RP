// Anime Fantasy: Naruto World #02 script: header
#define function<%1> forward header_%1; public header_%1
function<OnGameModeInit()>
{
	// Gamemode Settings
	SetGameModeText("AF:NW " VERSION);
	security_Log("Server","Starting...");
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	UsePlayerPedAnims();
	// Server Settings
	SendRconCommand("stream_rate 500");
	SendRconCommand("stream_distance " #PLAYER_STREAM_DISTANCE);
	// Database Connections
	gameDatabase = sqlite_Connect(FILE_GAMEDATA);
	serverDatabase = sqlite_Connect(FILE_SERVERDATA);
	return 1;
}
function<OnGameModeExit()>
{
	security_Log("Server","Stopping...");
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	PlayerInfo[playerid][pStatus] = e_PlayerStatus:player_status_connecting;
	SetPlayerColor(playerid,CC_COLOR_WHITE);
	player_ResetInfo(playerid);
	player_ResetCharacterInfo(playerid);
	PlayerInfo[playerid][pIdleTime] = 0;
	GetPlayerName(playerid,PlayerInfo[playerid][pName],MAX_PLAYER_NAME);
	GetPlayerIp(playerid,PlayerInfo[playerid][pIP],16);
	if(!player_IsNPC(playerid))
	{
		onlinePlayers++;
		//Streamer_CallbackHook(STREAMER_OPC,playerid);
		ElementArrayAdd(player,PlayerInfo[playerid][pArrayPos],playerid);
	}
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(!player_IsNPC(playerid))
	{
		onlinePlayers--;
		//Streamer_CallbackHook(STREAMER_OPDC,playerid,reason);
	}
	return 1;
}
/*function<OnPlayerEditObject(playerid,playerobject,objectid,response,Float:fX,Float:fY,Float:fZ,Float:fRotX,Float:fRotY,Float:fRotZ)>
{
	if(playerobject) Streamer_CallbackHook(STREAMER_OPEO,playerid,playerobject,objectid,response,fX,fY,fZ,fRotX,fRotY,fRotZ);
	return 1;
}
function<OnPlayerSelectObject(playerid,type,objectid,modelid,Float:fX,Float:fY,Float:fZ)>
{
	if(type == SELECT_OBJECT_PLAYER_OBJECT) Streamer_CallbackHook(STREAMER_OPSO,playerid,type,objectid,modelid,fX,fY,fZ);
	return 1;
}
function<OnPlayerPickUpPickup(playerid,pickupid)>
{
	Streamer_CallbackHook(STREAMER_OPPP,playerid,pickupid);
	return 1;
}
function<OnPlayerEnterCheckpoint(playerid)>
{
	Streamer_CallbackHook(STREAMER_OPEC,playerid);
	return 1;
}
function<OnPlayerLeaveCheckpoint(playerid)>
{
	Streamer_CallbackHook(STREAMER_OPLC,playerid);
	return 1;
}
function<OnPlayerEnterRaceCP(playerid)>
{
	Streamer_CallbackHook(STREAMER_OPERC,playerid);
	return 1;
}
function<OnPlayerLeaveRaceCP(playerid)>
{
	Streamer_CallbackHook(STREAMER_OPLRC,playerid);
	return 1;
}*/
#undef function
