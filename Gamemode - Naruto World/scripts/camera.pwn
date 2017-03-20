// Anime Fantasy: Naruto World #13 script: camera
#define function<%1> forward camera_%1; public camera_%1
function<OnGameModeInit()>
{
	// Loading Movies
	new read[M_S], File:fh;
	for(new i = 0; i < (MAX_MOVIES*MAX_MOVIE_PATHS); i++) MoviePath[i][pathMovieID] = -1;
	for(new i = 0, c = 0; i < MAX_MOVIES; i++)
	{
		for(new j = 0; j < MAX_MOVIE_PATHS; j++) MovieInfo[i][movPath][j] = -1;
		MovieInfo[i][movValid] = false;
		if(fexist(f(DIR_MOVIES "/%d.txt",i+1)))
		{
			MovieInfo[i][movValid] = true;
			fh = fopen(fstring,io_read);
			c = 0;
			while(fread(fh,read))
			{
				if(read[0] == '#' || strlen(read) <= 5) continue;
				if(equal(str_firstchars(read,4),"----")) movie_ExecuteCommand(str_trim(read[5]),i);
				else property_StrSet(f("movie%d_cmd%d",i,c++),str_trim(read));
			}
			MovieInfo[i][movCommands] = c;
			fclose(fh);
			printf("Loaded Movie: %s",MovieInfo[i][movName]);
		}
	}
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerUpdate(playerid)>
{
	if(PlayerInfo[playerid][pCameraUpdates] > 0)
	{
		PlayerInfo[playerid][pCameraUpdates]--;
		camera_Update(playerid);
	}
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second))
	{
		const ttw = 5;
		new command[M_S];
		if(PlayerInfo[playerid][pInterpolate][0] > 0)
		{
			PlayerInfo[playerid][pInterpolate][0]--;
			if(!PlayerInfo[playerid][pInterpolate][0]) OnPlayerDoneCameraPath(playerid,PlayerInfo[playerid][pInterpolate][1],PlayerInfo[playerid][pInterpolate][2]);
		}
		if(PlayerInfo[playerid][pWatchingMovie][0] > -1)
		{
			if(PlayerInfo[playerid][pWatchingMovie][1] >= ttw)
			{
				for(new c = 0; c < MovieInfo[PlayerInfo[playerid][pWatchingMovie][0]][movCommands]; c++)
				{
					f("movie%d_cmd%d",PlayerInfo[playerid][pWatchingMovie][0],c);
					if(property_StrExist(fstring))
					{
						format(command,sizeof(command),property_StrGet(fstring));
						if(strval(str_firstchars(command,4)) == (PlayerInfo[playerid][pWatchingMovie][1]-ttw)) movie_ExecuteCommand(command[5],playerid);
					}
				}
			}
			if(!PlayerInfo[playerid][pWatchingMovie][1])
			{
				ptd_Update(playerid,e_PlayerTD:ptd_movie,MovieInfo[PlayerInfo[playerid][pWatchingMovie][0]][movName]);
				ptd_Show(playerid,e_PlayerTD:ptd_movie);
			}
			PlayerInfo[playerid][pWatchingMovie][1]++;
		}
	}
	return 1;
}
function<OnPlayerEndScreenFade(playerid,e_ScreenFade:type,fadetype,fadeparam)>
{
	if(type == e_ScreenFade:screenfade_movie && fadetype != 0) EndTheMovie(playerid,PlayerInfo[playerid][pWatchingMovie][0]);
	return 1;
}
forward StartTheMovie(playerid,movieid);
public StartTheMovie(playerid,movieid)
{
	if(player_IsConnected(playerid) && PlayerInfo[playerid][pWatchingMovie] == movieid)
	{
		new i = MovieInfo[movieid][movPath][0];
		if(i != -1)
		{
			camera_SetPos(playerid,MoviePath[i][pathFromCam][0],MoviePath[i][pathFromCam][1]+WORLD_Y_OFFSET,MoviePath[i][pathFromCam][2]);
			camera_SetLookAt(playerid,MoviePath[i][pathFromLookAt][0],MoviePath[i][pathFromLookAt][1]+WORLD_Y_OFFSET,MoviePath[i][pathFromLookAt][2]);
			Streamer_Update(playerid);
		}
		PlayerInfo[playerid][pWatchingMovie][1] = 0;
	}
}
forward EndTheMovie(playerid,movieid);
public EndTheMovie(playerid,movieid)
{
	if(player_IsConnected(playerid) && PlayerInfo[playerid][pInterpolate][1] == CIE_MOVIE && PlayerInfo[playerid][pInterpolate][2] == movieid)
	{
		movie_Stop(playerid);
		OnPlayerEndMovie(playerid,movieid);
	}
}
forward OnPlayerDoneCameraPath(playerid,cie,cieid);
public OnPlayerDoneCameraPath(playerid,cie,cieid)
{
	switch(cie)
	{
		case CIE_ACTION:
		{
			switch(cieid)
			{
				case 1: camera_Reset(playerid);
			}
		}
		case CIE_MOVIE:
		{
			// Nothing to do here!
		}
	}
	return 1;
}
#undef function
// Camera
@f(_,camera.Reset(playerid))
{
	SetCameraBehindPlayer(playerid);
	for(new i = 0; i < 6; i++) PlayerInfo[playerid][pCamera][i] = 0.0;
}
@f(_,camera.Update(playerid))
{
	if(PlayerInfo[playerid][pCamera][0] != 0.0)
	{
		SetPlayerCameraPos(playerid,PlayerInfo[playerid][pCamera][0],PlayerInfo[playerid][pCamera][1],PlayerInfo[playerid][pCamera][2]);
		SetPlayerCameraLookAt(playerid,PlayerInfo[playerid][pCamera][3],PlayerInfo[playerid][pCamera][4],PlayerInfo[playerid][pCamera][5]);
	}
}
@f(_,camera.SetPos(playerid,Float:x,Float:y,Float:z))
{
	SetPlayerCameraPos(playerid,PlayerInfo[playerid][pCamera][0] = x,PlayerInfo[playerid][pCamera][1] = y,PlayerInfo[playerid][pCamera][2] = z);
	PlayerInfo[playerid][pCameraUpdates] = 3;
}
@f(_,camera.GetPos(playerid,&Float:x,&Float:y,&Float:z)) x = PlayerInfo[playerid][pCamera][0], y = PlayerInfo[playerid][pCamera][1], z = PlayerInfo[playerid][pCamera][2];
@f(_,camera.SetLookAt(playerid,Float:x,Float:y,Float:z,type = CAMERA_CUT))
{
	SetPlayerCameraLookAt(playerid,PlayerInfo[playerid][pCamera][3] = PlayerInfo[playerid][pCamera][6] = x,PlayerInfo[playerid][pCamera][4] = PlayerInfo[playerid][pCamera][7] = y,PlayerInfo[playerid][pCamera][5] = PlayerInfo[playerid][pCamera][8] = z,type);
	PlayerInfo[playerid][pCameraUpdates] = 3;
}
@f(_,camera.GetLookAt(playerid,&Float:x,&Float:y,&Float:z)) x = PlayerInfo[playerid][pCamera][3], y = PlayerInfo[playerid][pCamera][4], z = PlayerInfo[playerid][pCamera][5];
@f(_,camera.Interpolate(playerid,cie,cieid,Float:frompos[3],Float:topos[3],Float:fromlookat[3],Float:tolookat[3],interval))
{
	if(frompos[0] != 0.0) InterpolateCameraPos(playerid,frompos[0],frompos[1]+WORLD_Y_OFFSET,frompos[2],topos[0],topos[1]+WORLD_Y_OFFSET,topos[2],interval,CAMERA_MOVE);
	if(topos[0] != 0.0) InterpolateCameraLookAt(playerid,fromlookat[0],fromlookat[1]+WORLD_Y_OFFSET,fromlookat[2],tolookat[0],tolookat[1]+WORLD_Y_OFFSET,tolookat[2],interval,CAMERA_MOVE);
	PlayerInfo[playerid][pInterpolate][0] = interval / 1000, PlayerInfo[playerid][pInterpolate][1] = cie, PlayerInfo[playerid][pInterpolate][2] = cieid;
}
@f(_,camera.RotateAtPoint(playerid,Float:x,Float:y,Float:z))
{
	const Float:OFFSET_MAX = 0.25, Float:OFFSET_MIN = 0.01;
	SetPlayerCameraLookAt(playerid,x+(math_frandom(OFFSET_MIN,OFFSET_MAX)*math_random(-1,2)),y+(math_frandom(OFFSET_MIN,OFFSET_MAX)*math_random(-1,2)),z+(math_frandom(OFFSET_MIN,OFFSET_MAX)*math_random(-1,2)),CAMERA_MOVE);
	PlayerInfo[playerid][pCamera][6] = x, PlayerInfo[playerid][pCamera][7] = y, PlayerInfo[playerid][pCamera][8] = z;
}
@f(_,camera.ToggleSpectating(playerid,bool:toggle))
{
	TogglePlayerSpectating(playerid,_:toggle);
	if(!toggle) PlayerInfo[playerid][SpawnAfterSpec] = true;
}
// Movie
@f(_,movie.Start(playerid,movieid))
{
	camera_ToggleSpectating(playerid,true);
	player_Freeze(playerid,true);
	SetPlayerVirtualWorld(playerid,VW_MOVIE);
	ptd_HideAll(playerid);
	new e_GlobalTD:gtd2hide[] = {gtd_menu,gtd_map};
	for(new i = 0; i < sizeof(gtd2hide); i++) gtd_Hide(playerid,gtd2hide[i]);
	SetPlayerWidescreen(playerid,true);
	PlayerInfo[playerid][pWatchingMovie] = movieid;
	SetTimerEx("StartTheMovie",500,0,"iii",playerid,movieid,1);
}
@f(_,movie.Stop(playerid))
{
	camera_ToggleSpectating(playerid,false);
	player_Freeze(playerid,false);
	SetPlayerVirtualWorld(playerid,VW_WORLD);
	SetCameraBehindPlayer(playerid);
	SetPlayerWidescreen(playerid,false);
	PlayerInfo[playerid][pWatchingMovie] = -1;
	if(music_IsPlaying(playerid)) music_Stop(playerid);
	gameplay_Load(playerid);
}
@f(_,movie.ExecuteCommand(cmd[],param))
{
	/*  Available commands:
	    deactivate;
	    name;string
	    author;string
	    load;id,cfromx,cfromy,cfromz,ctox,ctoy,ctoz,lafromx,lafromy,lafromz,latox,latoy,latoz
	    camera;id,interval
	    rotate;id,type
	    text;string
	    clear;
	    play;soundcode
	    end;
	*/
	new paramsStr[M_S*2], cmd_[16];
	strmid(paramsStr,cmd,strfind(cmd,";")+1,strlen(cmd));
	strmid(cmd_,cmd,0,strfind(cmd,";"));
	if(strlen(paramsStr) > 0) str_split(paramsStr,fsplitted,',');
	if(equal(cmd_,"deactivate")) MovieInfo[param][movValid] = false;
	else if(equal(cmd_,"name")) str_set(MovieInfo[param][movName],paramsStr,MAX_NAME_LENGTH);
	else if(equal(cmd_,"author")) str_set(MovieInfo[param][movAuthor],paramsStr,MAX_NAME_LENGTH);
	else if(equal(cmd_,"load"))
	{
		new pointer = -1;
		for(new i = 0; i < (MAX_MOVIES*MAX_MOVIE_PATHS) && pointer == -1; i++) if(MoviePath[i][pathMovieID] == -1) pointer = i;
		MovieInfo[param][movPath][strval(fsplitted[0])] = pointer;
		MoviePath[pointer][pathMovieID] = param;
		for(new i = 0; i < 3; i++) MoviePath[pointer][pathFromCam][i] = floatstr(fsplitted[i+1]), MoviePath[pointer][pathToCam][i] = floatstr(fsplitted[i+4]), MoviePath[pointer][pathFromLookAt][i] = floatstr(fsplitted[i+7]), MoviePath[pointer][pathToLookAt][i] = floatstr(fsplitted[i+10]);
	}
	else if(equal(cmd_,"camera"))
	{
		new Float:conv[4][3], path = strval(fsplitted[0]);
		for(new j = 0; j < 3; j++)
		{
			conv[0][j] = MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathFromCam][j];
			conv[1][j] = MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathToCam][j];
			conv[2][j] = MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathFromLookAt][j];
			conv[3][j] = MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathToLookAt][j];
		}
		camera_Interpolate(param,CIE_MOVIE,PlayerInfo[param][pWatchingMovie][0],conv[0],conv[1],conv[2],conv[3],strval(fsplitted[1]));
	}
	else if(equal(cmd_,"rotate"))
	{
		new path = strval(fsplitted[0]);
		SetPlayerCameraLookAt(param,MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathFromLookAt][0],MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathFromLookAt][1],MoviePath[MovieInfo[PlayerInfo[param][pWatchingMovie][0]][movPath][path]][pathFromLookAt][2],strval(fsplitted[1]));
	}
	else if(equal(cmd_,"text")) chat_Send(param,CC_CHAT_TEXT,paramsStr);
	else if(equal(cmd_,"clear")) chat_Clear(param);
	else if(equal(cmd_,"play")) music_Play(param,paramsStr);
	else if(equal(cmd_,"end")) screenfade_Start(param,e_ScreenFade:screenfade_movie,CC_COLOR_BLACK,5,2);
}
