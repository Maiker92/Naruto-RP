// Anime Fantasy: Naruto World #05 script: sockets
#define function<%1> forward net_%1; public net_%1
#define MAX_SOCKETS_PER_RECIEVE 8
#define MAX_SOCKET_LENGTH 512
#define MAX_IP_CONNECTIONS 3
#define DEBUG_NET // Used to print socket information on console
/*	Int Array: fireproof = 0, joypad = 1, playerstate = 2, jumpstate = 3,
	runstate = 4, radio = 5, sfx = 6 moonsize = 7, nightvision = 8,
	thermalvision = 9, hud = 10
*/
/*	Float Array: gravity = 0, wavelevel = 1
*/
static Socket:S, bind[16], splitedData[MAX_SOCKETS_PER_RECIEVE][MAX_SOCKET_LENGTH], pType:socket_type = TCP;
function<OnGameModeInit()>
{
	GetServerVarAsString("bind",bind,sizeof(bind));
	S = socket_create(socket_type);
	if(socket_type == TCP) socket_set_max_connections(S,MAX_CONNECTIONS);
	socket_bind(S,bind);
	if(equal(bind,"127.0.0.1")) SS_ListenToPort(0,0,"7776");
	else HTTP(0,HTTP_GET,f(AFURL "assign/request.php?bind=%d",GetServerVarAsInt("port")),"","SS_ListenToPort");
	for(new i = 0; i < MAX_CONNECTIONS; i++) ResetConnectionInfo(i);
	return 1;
}
function<OnGameModeExit()>
{
	if(is_socket_valid(S))
	{
		socket_stop_listen(S);
		socket_destroy(S);
	}
	return 1;
}
forward SS_ListenToPort(index,response_code,data[]);
public SS_ListenToPort(index,response_code,data[])
{
	#pragma unused index
	#pragma unused response_code
	socket_listen(S,strval(data));
	printf("SS port: %s",data);
}
function<OnPlayerConnect(playerid)>
{
	if(player_IsNPC(playerid)) return 1;
	PlayerInfo[playerid][pConnectionID] = INVALID_CONNECTION;
	if(!player_IsNPC(playerid)) LoopEx(connection,i,<PlayerInfo[playerid][pConnectionID] == INVALID_CONNECTION>) if(ConnectionInfo[i][conLogged])
	{
		#if defined DEBUG_NET
			printf("conpid: %d uid: %s c-uid: %s",ConnectionInfo[i][conPlayerID],UniqueID(playerid,true),UniqueID(i,false));
		#endif
		if(ConnectionInfo[i][conPlayerID] == INVALID_PLAYER_ID && equal(UniqueID(playerid,true),UniqueID(i,false)))
		{
			PlayerInfo[playerid][pConnectionID] = i, ConnectionInfo[i][conPlayerID] = playerid;
			SendToClient(i,f("id:%d",playerid));
		}
	}
	if(PlayerInfo[playerid][pConnectionID] == INVALID_CONNECTION)
	{
		chat_Error(playerid,"To play this server you should download Anime Fantasy launcher and connect with it.");
		chat_Error(playerid,"Download the launcher in our site: " WEBURL);
		dialog_Show(playerid,d_Error,"s","To play this server you should download Anime Fantasy launcher and connect with it.\nDownload the launcher in our site: " WEBURL);
		Kick(playerid);
		return 0;
	}
	return 1;
}
function<OnPlayerDisconnect(playerid, reason)>
{
	if(PlayerInfo[playerid][pConnectionID] != INVALID_CONNECTION) if(ConnectionInfo[PlayerInfo[playerid][pConnectionID]][conPlayerID] != INVALID_PLAYER_ID) ConnectionInfo[PlayerInfo[playerid][pConnectionID]][conPlayerID] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pConnectionID] = INVALID_CONNECTION;
	return 1;
}
function<OnPlayerText(playerid,text[])>
{
	//if(PlayerInfo[playerid][pConnectionID] != INVALID_CONNECTION) SendToClient(PlayerInfo[playerid][pConnectionID],"chatsent");
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
	//if(PlayerInfo[playerid][pConnectionID] != INVALID_CONNECTION) SendToClient(PlayerInfo[playerid][pConnectionID],"chatsent");
	return 0;
}
function<GlobalScriptTimer(interval)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second)) Loop(connection,i)
	{
		ConnectionInfo[i][conIdleTime]++;
		if(ConnectionInfo[i][conIdleTime] >= (ConnectionInfo[i][conPlayerID] == INVALID_PLAYER_ID ? MAX_CON_IDLE_TIME : MAX_CONPL_IDLE_TIME)) CloseClientConnection(i);
	}
	return 1;
}
public onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid)
{
	assert id == S && socket_type == TCP;
	#if defined DEBUG_NET
	printf("Connected (%d)",remote_clientid);
	#endif
	new c = 0;
	for(new i = 0, ip[16]; i < MAX_CONNECTIONS && c < MAX_IP_CONNECTIONS; i++) if(ConnectionInfo[i][conLogged])
	{
		if(remote_clientid == i) format(ip,sizeof(ip),remote_client);
		else get_remote_client_ip(id,i,ip);
		if(equal(ip,remote_client)) c++;
	}
	ResetConnectionInfo(remote_clientid);
	if(c >= MAX_IP_CONNECTIONS) socket_close_remote_client(id,remote_clientid);
	else format(ConnectionInfo[remote_clientid][conIP],16,remote_client);
	ElementArrayAdd(connection,ConnectionInfo[remote_clientid][conArrayPos],remote_clientid);
	return 1;
}
public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	assert id == S && socket_type == TCP;
	new cmd[M_S], p, bool:reset = true;
	idx = 0;
	if((p = strfind(data,";",true)) != -1)
	{
		if(p == data_len-1) data[(data_len--)-1] = EOS;
		else
		{
			str_split(data,splitedData,';');
			for(new i = 0; i < MAX_SOCKETS_PER_RECIEVE; i++) if(strlen(splitedData[i]) > 1) onSocketReceiveData(id,remote_clientid,splitedData[i],strlen(splitedData[i]));
			return 1;
		}
	}
	#if defined DEBUG_NET
	printf("Recieved (%d): %s",remote_clientid,data);
	#endif
	cmd = str_tok(data,idx);
	if(equal(cmd,"query")) SendToClient(remote_clientid,f("query:%d:%d:%d",onlinePlayers,MAX_PLAYERS,strval(misc_Setting("GAME_LEVEL"))));
	else if(equal(cmd,"connect"))
	{
		cmd = str_tok(data,idx);
		new vers[64], bool:already = false;
		LoopEx(connection,i,<!already>) if(ConnectionInfo[i][conLogged]) if(equal(cmd,UniqueID(i,false))) already = true;
		if(already) return socket_close_remote_client(id,remote_clientid);
		format(vers,sizeof(vers),str_rest(data,idx));
		if(!equal(vers,LAUNCHER_VERSION)) socket_close_remote_client(id,remote_clientid);
		else
		{
			ConnectionInfo[remote_clientid][conLogged] = true;
			ConnectionInfo[remote_clientid][conPlayerID] = INVALID_PLAYER_ID;
			strmid(cmd,cmd,0,strfind(cmd,"/"));
			format(ConnectionInfo[remote_clientid][conPlayerName],MAX_PLAYER_NAME,cmd);
			LoopEx(player,i,<ConnectionInfo[remote_clientid][conPlayerID] == INVALID_PLAYER_ID>) if(PlayerInfo[i][pConnectionID] == INVALID_CONNECTION && equal(UniqueID(i,true),UniqueID(remote_clientid,false))) PlayerInfo[i][pConnectionID] = remote_clientid, ConnectionInfo[remote_clientid][conPlayerID] = i, ConnectionInfo[remote_clientid][conLogged] = true;
			SendToClient(remote_clientid,f("connected:%d:%d",remote_clientid,ConnectionInfo[remote_clientid][conPlayerID] == INVALID_PLAYER_ID ? -1 : ConnectionInfo[remote_clientid][conPlayerID]));
		}
	}
	else if(equal(cmd,"disconnect")) str_set(ConnectionInfo[remote_clientid][conDisconnectReason],str_rest(data,idx),64);
	else if(equal(cmd,"hwid")) str_set(ConnectionInfo[remote_clientid][conHWID],str_rest(data,idx),64);
	else if(equal(cmd,"login"))
	{
		new username[64], uid = 0, status = 0;
		str_set(username,str_tok(data,idx),64);
		cmd = str_rest(data,idx);
		uid = str_isnum(username) ? strval(username) : user_GetID(username);
		if(!uid) status = 0;
		else if(!strlen(username) || !strlen(cmd)) status = 1;
		else if(!strcmp(cmd,user_GetKey(uid,"password"))) status = 2;
		else status = 3;
		if(status == 2)
		{
			ConnectionInfo[remote_clientid][conAutoLogin] = uid;
			SendToClient(remote_clientid,f("logged:%d:%d",status,uid));
		}
		else SendToClient(remote_clientid,f("logged:%d",status));
	}
	else if(equal(cmd,"infoint"))
	{
		new playerid = INVALID_PLAYER_ID;
		if(((playerid = ConnectionInfo[remote_clientid][conPlayerID]) != INVALID_PLAYER_ID) && player_IsConnected(playerid)) for(new i = 0; i < pInfoArray_Int_Max; i++)
		{
			cmd = str_tok(data,idx);
			PlayerInfo[playerid][pInfoArray_Int][i] = strval(cmd);
		}
		reset = false;
	}
	else if(equal(cmd,"infofloat"))
	{
		new playerid = INVALID_PLAYER_ID;
		if(((playerid = ConnectionInfo[remote_clientid][conPlayerID]) != INVALID_PLAYER_ID) && player_IsConnected(playerid)) for(new i = 0; i < pInfoArray_Float_Max; i++)
		{
			cmd = str_tok(data,idx);
			PlayerInfo[playerid][pInfoArray_Float][i] = floatstr(cmd);
		}
		reset = false;
	}
	else if(equal(cmd,"key"))
	{
		new playerid = INVALID_PLAYER_ID;
		if(((playerid = ConnectionInfo[remote_clientid][conPlayerID]) != INVALID_PLAYER_ID) && player_IsConnected(playerid) && PlayerInfo[playerid][pIdleTime] < 10)
		{
			cmd = str_tok(data,idx);
			new vk = strval(cmd);
			cmd = str_tok(data,idx);
			new mod = strval(cmd);
			OnPlayerKeyPress(playerid,vk,mod);
		}
	}
	else if(equal(cmd,"sndlen"))
	{
		new playerid = INVALID_PLAYER_ID;
		if(((playerid = ConnectionInfo[remote_clientid][conPlayerID]) != INVALID_PLAYER_ID) && player_IsConnected(playerid) && PlayerInfo[playerid][pIdleTime] < 10)
		{
			cmd = str_tok(data,idx);
			new len = strval(cmd);
			cmd = str_rest(data,idx);
			new i = audio_FindByAddress(cmd);
			if(i != -1) audio_UpdateLength(playerid,i,len);
		}
	}
	if(reset) ConnectionInfo[remote_clientid][conIdleTime] = 0;
	return 1;
}
public onSocketRemoteDisconnect(Socket:id, remote_clientid)
{
	assert id == S && socket_type == TCP;
	if(ConnectionInfo[remote_clientid][conLogged])
	{
		#if defined DEBUG_NET
		printf("Disconnect (%d)",remote_clientid);
		#endif
		ConnectionInfo[remote_clientid][conLogged] = false;
		if(ConnectionInfo[remote_clientid][conPlayerID] != INVALID_PLAYER_ID && IsPlayerConnected(ConnectionInfo[remote_clientid][conPlayerID])) admin_Kick(ConnectionInfo[remote_clientid][conPlayerID],"Connection lost");
		ElementArrayDel(connection,ConnectionInfo[remote_clientid][conArrayPos],INVALID_CONNECTION);
		ResetConnectionInfo(remote_clientid);
	}
	return 1;
}
public onUDPReceiveData(Socket:id, data[], data_len, remote_client_ip[], remote_client_port)
{
	assert id == S && socket_type == UDP;
	return 1;
}
stock ResetConnectionInfo(id)
{
	ConnectionInfo[id][conLogged] = false;
	ConnectionInfo[id][conDisconnectReason][0] = EOS;
	ConnectionInfo[id][conPlayerID] = INVALID_PLAYER_ID;
	ConnectionInfo[id][conPlayerName][0] = EOS;
	ConnectionInfo[id][conIP][0] = EOS;
	ConnectionInfo[id][conArrayPos] = -1;
	ConnectionInfo[id][conHWID][0] = EOS;
	ConnectionInfo[id][conIdleTime] = 0;
	ConnectionInfo[id][conAutoLogin] = 0;
	for(new i = 0; i < pInfoArray_Int_Max; i++) PlayerInfo[id][pInfoArray_Int][i] = -1;
	for(new i = 0; i < pInfoArray_Float_Max; i++) PlayerInfo[id][pInfoArray_Float][i] = -1.0;
	return 1;
}
stock SendToAll(data[]) Loop(connection,i) if(ConnectionInfo[i][conLogged]) SendToClient(i,data);
stock SendToClient(clientid,data[])
{
	#if defined DEBUG_NET
	printf("Sent: %s",data);
	#endif
	if(strfind(data,";") == -1) socket_sendto_remote_client(S,clientid,f("%s;",data));
}
stock UniqueID(id,bool:pla)
{
	new uid[64];
	return ((pla ? format(uid,sizeof(uid),"%s/%s",player_GetNickname(id),player_GetIP(id)) : format(uid,sizeof(uid),"%s/%s",ConnectionInfo[id][conPlayerName],ConnectionInfo[id][conIP])), uid);
}
stock ClosePlayerConnection(playerid)
{
	new c = PlayerInfo[playerid][pConnectionID];
	SendToClient(c,"close");
	Kick(playerid);
	CloseClientConnection(c);
}
stock CloseClientConnection(clientid)
{
	printf("KICK %d",ConnectionInfo[clientid][conIdleTime]);
	//socket_close_remote_client(S,clientid);
	//onSocketRemoteDisconnect(S,clientid);
}
//============================= [ Function List ] ==============================
#define isClientAPlayer(%1) (%1 >= 0 && %1 < MAX_CONNECTIONS && ConnectionInfo[%1][conPlayerID] != INVALID_PLAYER_ID && PlayerInfo[ConnectionInfo[%1][conPlayerID]][pIdleTime] < 10)
#define isPlayerAClient(%1) (%1 >= 0 && %1 < MAX_PLAYERS && PlayerInfo[%1][pConnectionID] != INVALID_CONNECTION && PlayerInfo[%1][pIdleTime] < 10 && !player_IsNPC(%1))
#define isPlayerAClientNAFK(%1) (%1 >= 0 && %1 < MAX_PLAYERS && PlayerInfo[%1][pConnectionID] != INVALID_CONNECTION && !player_IsNPC(%1))
#define FUNC<%1,%2> forward %1:%2; stock %1:%2
FUNC<_,GetPlayerHWID(playerid)> return isPlayerAClient(playerid) ? ConnectionInfo[PlayerInfo[playerid][pConnectionID]][conHWID] : 0;
FUNC<_,OpenWebpage(playerid,url[])> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("webpage:%s",url));
FUNC<_,IsPlayerUsingJoypad(playerid)> return isPlayerAClient(playerid) ? (_:(!PlayerInfo[playerid][pInfoArray_Int][1])) : -1;
FUNC<_,ForceRemoveJoypad(playerid)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],"removejoypad");
FUNC<Float,GetPlayerGravity(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Float][0] : -1.0;
FUNC<_,SetPlayerGravity(playerid,Float:gravity)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("gravity:%f",gravity));
FUNC<_,GetPlayerControlState(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][2] : -1;
FUNC<_,GetPlayerJumpState(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][3] : -1;
FUNC<_,GetPlayerRunState(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][4] : -1;
FUNC<_,GetPlayerFireproof(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][0] : -1;
FUNC<_,SetPlayerFireproof(playerid,enabled)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("fireproof:%d",_:bool:enabled));
FUNC<_,GetPlayerWaveLevel(playerid)> return isPlayerAClient(playerid) ? floatround(PlayerInfo[playerid][pInfoArray_Float][1]) : -1;
FUNC<_,SetPlayerWaveLevel(playerid,wavelevel)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("waves:%f",float(wavelevel)));
FUNC<_,SetPlayerRain(playerid)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],"rain");
FUNC<_,SetPlayerCameraDistance(playerid,Float:distance)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("camera:%f",distance));
FUNC<Float,GetPlayerCamera1Distance(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Float][3] : -1.0;
FUNC<_,ResetPlayerCameraDistance(playerid)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],"camerareset");
FUNC<_,GetPlayerVolume(playerid,volumetype)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][!volumetype ? 5 : 6] : -1;
FUNC<_,CloseConnection(playerid)> if(isPlayerAClient(playerid)) ClosePlayerConnection(playerid);
FUNC<_,QuitFromGame(playerid)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],"quit");
FUNC<_,GetPlayerHUD(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][10] : -1;
FUNC<_,SetPlayerHUD(playerid,bool:showing)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("hud:%d",_:showing));
FUNC<_,GetPlayerVision(playerid,vistype)> return isPlayerAClient(playerid) && (vistype == 0 || vistype == 1) ? PlayerInfo[playerid][pInfoArray_Int][8+vistype] : -1;
FUNC<_,SetPlayerVision(playerid,vistype,activated)> if(isPlayerAClient(playerid) && (vistype == 0 || vistype == 1)) SendToClient(PlayerInfo[playerid][clientID],f("vision:%d:%d",vistype,_:bool:activated));
FUNC<_,UseSoundOption(playerid,option[],sound[]="",soundtype=-1)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("sound:%s:%s:%d",option,sound,audio_GetIDFromType(soundtype)));
FUNC<_,Use3DSoundOption(playerid,option[],sound[]="",soundtype=-1,Float:x,Float:y,Float:z,Float:distance)> if(isPlayerAClient(playerid))
{
	SendToClient(PlayerInfo[playerid][pConnectionID],f("sound:%s:%s:%d:%f,%f,%f,%f",option,sound,audio_GetIDFromType(soundtype),x,y,z,distance));
}
FUNC<_,GetPlayerControl(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][11] : -1;
FUNC<_,SetPlayerControl(playerid,bool:locked)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("lock:%d",_:locked));
FUNC<_,SetClipboardText(playerid,text[])> if(isPlayerAClient(playerid) && strlen(text) > 0) SendToClient(PlayerInfo[playerid][pConnectionID],f("clipboard:%s",text));
FUNC<_,BindKey(playerid,keyid,modifiers = 0)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("hotkey:1:%d:%d",keyid,modifiers));
FUNC<_,UnbindKey(playerid,keyid,modifiers = 0)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("hotkey:2:%d:%d",keyid,modifiers));
FUNC<_,GetPlayerWidescreen(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][12] : -1;
FUNC<_,SetPlayerWidescreen(playerid,bool:toggle)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("widescreen:%d",_:toggle));
FUNC<Float,GetPlayerRotationSpeed(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Float][2] : -1.0;
FUNC<_,SetPlayerRotationSpeed(playerid,Float:speed)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("rotspeed:%f",speed));
FUNC<_,GetPlayerInfiniteRun(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][13] : -1;
FUNC<_,SetPlayerInfiniteRun(playerid,enabled)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("infiniterun:%d",_:bool:enabled));
FUNC<_,GetPlayerSuperJump(playerid)> return isPlayerAClient(playerid) ? PlayerInfo[playerid][pInfoArray_Int][14] : -1;
FUNC<_,SetPlayerSuperJump(playerid,enabled)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("superjump:%d",_:bool:enabled));
FUNC<_,SetCursorPosition(playerid,x,y)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("cursor:%d:%d",x,y));
FUNC<_,OpenTeamSpeak(playerid,ip[],port)> if(isPlayerAClient(playerid)) SendToClient(PlayerInfo[playerid][pConnectionID],f("teamspeak:%s:%d",ip,port));
#undef FUNC
#undef isPlayerAClientNAFK
#undef isPlayerAClient
#undef isClientAPlayer
#undef function
/*	Int Array: fireproof = 0, joypad = 1, playerstate = 2, jumpstate = 3,
	runstate = 4, radio = 5, sfx = 6 moonsize = 7, nightvision = 8,
	thermalvision = 9, hud = 10
*/
/*	Float Array: gravity = 0, wavelevel = 1
*/
