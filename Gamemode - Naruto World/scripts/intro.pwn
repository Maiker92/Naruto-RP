// Anime Fantasy: Naruto World #28 script: intro
#define function<%1> forward intro_%1; public intro_%1
static lastIntro = -1, paths[10] = {-1,...};
function<OnGameModeInit()>
{
	// NPC Paths (need to do that before loading the NPCs)
	intro_CreatePaths();
	// Loading Introductions
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Intros)));
	new m = sqlite_NumRows(), iid = 0;
	if(m >= 1 && m <= MAX_INTROS) for(new i = 0; i < m; i++)
	{
		iid = strval(sqlite_GetField("id"));
		IntroductionInfo[iid][itrValid] = true;
		format(IntroductionInfo[iid][itrName],MAX_NAME_LENGTH,sqlite_GetField("name"));
		IntroductionInfo[iid][itrScript] = strval(sqlite_GetField("modelid"));
		IntroductionInfo[iid][itrCharacter] = chars_Index(sqlite_GetField("character"));
		IntroductionInfo[iid][itrMusic] = audio_Index(sqlite_GetField("music"));
		IntroductionInfo[iid][itrNPCs] = 0;
		IntroductionInfo[iid][itrWorld][0] = strval(sqlite_GetField("time"));
		IntroductionInfo[iid][itrWorld][1] = strval(sqlite_GetField("weather"));
		intro_LoadNPCs(iid);
		lastIntro = iid;
		printf("Loaded Introduction: %s",IntroductionInfo[iid][itrName]);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	// Game Info & Background
	infofile_Check(infofile_Format("Intro","Game Info & Background"));
	// Dialogs
	dialog_Create(d_NoCharacter,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "No Character","OK","",d_Null);
	dialog_AddLine(@c(DIALOG_TEXT) "You have no any character yet.\n");
	dialog_AddLine("In order to play the Naruto World,");
	dialog_AddLine("you will need to register at least one character.\n");
	dialog_AddLine(f("For further information click " @c(DIALOG_BOLD) "%s" @c(DIALOG_TEXT) ".",StartOptions[START_OPTION_BG][stbName]));
	dialog_Create(d_Community,DIALOG_STYLE_TABLIST_HEADERS,@c(DIALOG_DHEADER) "Community","Go","Close",d_Null);
	dialog_AddLine("Target\tLink");
	for(new i = 0; i < sizeof(CommunityLinks); i++) dialog_AddLine(f(@c(LIST_ITEMS) "%s\t" @c(DIALOG_LINK) "%s",CommunityLinks[i][lnkTarget],CommunityLinks[i][lnkURL]));
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerClickTD(playerid,Text:clickedid)>
{
	new startupButton = -1;
	for(new i = 0; i < MAX_STARTUP_BUTTONS && startupButton == -1; i++) if(clickedid == StartOptions[i][stbTD]) startupButton = i;
	if(startupButton != -1)
	{
		switch(startupButton)
		{
			case START_OPTION_WORLD:
			{
				if(chars_GetAssignedCharacters(PlayerInfo[playerid][pUserID]) > 0)
				{
					chat_Send(playerid,CC_CHAT_TEXT,"Please " @c(CHAT_BOLD) "select your character" @c(CHAT_TEXT) ".");
					user_SelectCharacter(playerid);
				}
				else dialog_Show(playerid,d_NoCharacter);
			}
			case START_OPTION_BATTLE: dialog_Show(playerid,d_Soon,"s","Free Battles");
			case START_OPTION_TRAINING: dialog_Show(playerid,d_Soon,"s","Training");
			case START_OPTION_MOVIE: dialog_Show(playerid,d_Soon,"s","Movie Maker");
			case START_OPTION_TUTORIALS: dialog_Show(playerid,d_Soon,"s","Tutorials");
			case START_OPTION_MOVIES: dialog_Show(playerid,d_Soon,"s","Movies");
			case START_OPTION_BG: infofile_Show(playerid,infofile_Format("Intro","Game Info & Background"));
			case START_OPTION_COMMUNITY: dialog_Show(playerid,d_Community);
			case START_OPTION_SETTINGS: dialog_Show(playerid,d_Soon,"s","Settings");
			case START_OPTION_EXIT: QuitFromGame(playerid);
		}
		return 1;
	}
	return 0;
}
function<OnPlayerSpawn(playerid)>
{
	intro_Stop(playerid);
	return 1;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_NoCharacter) intro_PointAtButton(playerid,START_OPTION_BG);
	if(dialogid == _:d_Community && response) switch(CommunityLinks[listitem][lnkType])
	{
		case link_website: OpenWebpage(playerid,CommunityLinks[listitem][lnkURL]);
		case link_teamspeak:
		{
			new ip[16], port, sep = strfind(CommunityLinks[listitem][lnkURL],":");
			if(sep != -1)
			{
				strmid(ip,CommunityLinks[listitem][lnkURL],sep+1,strlen(CommunityLinks[listitem][lnkURL]));
				port = strval(ip);
				strmid(ip,CommunityLinks[listitem][lnkURL],0,sep);
				OpenTeamSpeak(playerid,ip,port);
			}
		}
	}
	return 1;
}
function<OnPathRouteCompleted(pathid,routeid,pos)>
{
	if(pathid == paths[0]) Loop(player,i) if(PlayerInfo[i][pStatus] == e_PlayerStatus:player_status_intro) camera_RotateAtPoint(i,PathInfo[pathid][pathX][pos],PathInfo[pathid][pathY][pos],PathInfo[pathid][pathZ][pos]);
	return 1;
}
/*function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,1750) && PlayerInfo[playerid][pStatus] == e_PlayerStatus:player_status_intro) camera_RotateAtPoint(playerid,PlayerInfo[playerid][pCamera][3],PlayerInfo[playerid][pCamera][4],PlayerInfo[playerid][pCamera][5]);
	return 1;
}*/
#undef function
// Introduction
@f(_,intro.Go(playerid,iid))
{
	// Script (playing with their camera)
	camera_ToggleSpectating(playerid,true);
	vworld_Set(playerid,VW_INTRO);
	switch(IntroductionInfo[iid][itrScript])
	{
		case 1:
		{
			camera_SetPos(playerid,-28.7018,-448.7470,62.7606);
			camera_SetLookAt(playerid,-28.4099,-449.7077,62.4605);
		}
	}
	PlayerInfo[playerid][pStatus] = e_PlayerStatus:player_status_intro, PlayerInfo[playerid][pIntro] = iid;
	// World
	world_SetTimeForPlayer(playerid,IntroductionInfo[iid][itrWorld][0]);
	world_SetWeatherForPlayer(playerid,IntroductionInfo[iid][itrWorld][1]);
	// Music
	if(IntroductionInfo[iid][itrMusic] != -1) music_Play(playerid,SoundInfo[IntroductionInfo[iid][itrMusic]][sndCodeName],true);
	// Buttons
	gtd_Show(playerid,e_GlobalTD:gtd_startup);
	cursor_Show(playerid);
}
@f(_,intro.GoLast(playerid)) intro_Go(playerid,lastIntro);
@f(_,intro.Stop(playerid))
{
	camera_ToggleSpectating(playerid,false);
	camera_Reset(playerid);
	if(music_IsPlaying(playerid)) music_Stop(playerid);
	gtd_Hide(playerid,e_GlobalTD:gtd_startup);
	cursor_Hide(playerid);
	PlayerInfo[playerid][pIntro] = -1;
}
@f(_,intro.LoadNPCs(iid))
{
	if(IntroductionInfo[iid][itrCharacter] != INVALID_CHARACTER)
	{
		IntroductionInfo[iid][itrNPC][0] = npc_Spawn(e_NPCUsage:npcusage_intro,0.0,0.0,0.0,.vworld = VW_INTRO);
		IntroductionInfo[iid][itrNPCs]++;
		npc_SetSkin(IntroductionInfo[iid][itrNPC][0],CharacterInfo[IntroductionInfo[iid][itrCharacter]][cSkin]);
	}
	switch(IntroductionInfo[iid][itrScript])
	{
		case 1:
		{
			// Put Lord Third at -28.1540, -471.5950, 51.2442
			npc_SetPosition(IntroductionInfo[iid][itrNPC][0],-28.1540,-471.5950,51.2442);
			path_Go(paths[0],IntroductionInfo[iid][itrNPC][0],e_RouteOwnerType:routeowner_npc,e_RouteMoveType:routemove_random,true,MOVE_TYPE_SPRINT);
		}
	}
}
@f(_,intro.PointAtButton(playerid,button)) cursor_SetPosition(playerid,127+223,200+(50*button));
@f(_,intro.CreatePaths())
{
	paths[0] = path_Create("Sarutobi-BetaIntro");
	path_AddPosition(paths[0],-4.08006,-493.45609,51.2442);
	path_AddPosition(paths[0],-1.93353,-476.15860,51.2442);
	path_AddPosition(paths[0],-16.43067,-466.73523,51.2442);
	path_AddPosition(paths[0],-28.28370,-473.82932,51.2442);
	path_AddPosition(paths[0],-30.46044,-489.89523,51.2442);
	path_AddPosition(paths[0],-17.14447,-499.30664,51.2442);
	path_AddPosition(paths[0],-15.54932,-482.89120,51.2442);
}
