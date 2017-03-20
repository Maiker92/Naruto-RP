// Anime Fantasy: Naruto World #12 script: sound
#define function<%1> forward sound_%1; public sound_%1
static bool:ONLY_URL_MODE = false;
function<OnGameModeInit()>
{
	// Loading Sounds
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Sounds)));
	new m = sqlite_NumRows(), sid = 0;
	if(m >= 1 && m <= MAX_SOUNDS) for(new i = 0; i < m; i++)
	{
		sid = strval(sqlite_GetField("id"));
		SoundInfo[sid][sndValid] = true;
		format(SoundInfo[sid][sndName],MAX_NAME_LENGTH,sqlite_GetField("name"));
		format(SoundInfo[sid][sndCodeName],MAX_NAME_LENGTH*2,sqlite_GetField("code"));
		format(SoundInfo[sid][sndAddress],64,sqlite_GetField("address"));
		if(strfind(SoundInfo[sid][sndAddress],"#") != -1) SoundInfo[sid][sndMultiple] = strval(sqlite_GetField("multi"));
		SoundInfo[sid][sndType] = audio_GetTypeFromID(strval(sqlite_GetField("type")));
		audio[_:SoundInfo[sid][sndType]-1][audios[_:SoundInfo[sid][sndType]-1]++] = sid;
		SoundInfo[sid][sndIsURL] = strfind(SoundInfo[sid][sndAddress],"http:") != -1;
		property_IntSet(f("sound_%s",SoundInfo[sid][sndCodeName]),sid);
		property_IntSet(f("soundaddr_%s",SoundInfo[sid][sndAddress]),sid);
		printf("Loaded Sound: %s (%s)",SoundInfo[sid][sndName],SoundInfo[sid][sndCodeName]);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(audio_IsPlayingAny(playerid)) audio_StopAll(playerid);
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(PlayerInfo[playerid][pListSounds] > 0 && timer_MeetsTimeUnit(interval,timeunit_second))
	{
		new musicEnded = -1;
		for(new i = 0, s = -1; i < PlayerInfo[playerid][pListSounds]; i++)
		{
			s = PlayerInfo[playerid][pListSound][i];
			//SendClientMessage(playerid,-1,f("%s / current: %d / end: %d",SoundInfo[s][sndName],PlayerInfo[playerid][pSoundPosition][s],PlayerInfo[playerid][pSoundLength][s]));
			if(PlayerInfo[playerid][pSoundLength][s] > 0)
			{
				PlayerInfo[playerid][pSoundPosition][s] += 1000;
				if(PlayerInfo[playerid][pSoundPosition][s] >= PlayerInfo[playerid][pSoundLength][s])
				{
					//SendClientMessage(playerid,-1,f("sound end: %s",SoundInfo[s][sndName]));
					if(PlayerInfo[playerid][pSoundLoop][s]) PlayerInfo[playerid][pSoundPosition][s] = 0;
					else
					{
						musicEnded = s;
						audio_Dispose(playerid,i);
					}
					break;
				}
			}
		}
		if(musicEnded != -1) OnBackgroundMusicEnd(playerid,bgmusic_GetCurrent(playerid),bgmusic_GetCurrentName(playerid),musicEnded);
	}
	return 1;
}
#undef function
static stock ParseSoundURL(address[])
{
	new ad[128];
	format(ad,sizeof(ad),address);
	if(ONLY_URL_MODE) format(ad,sizeof(ad),"http://" NWURL "sounds/%s",address);
	return ad;
}
// Audio
@f(_,audio.Play(playerid,codename[],bool:loop=false,bool:stack=true,num=-1,bool:use3d=false,Float:x=0.0,Float:y=0.0,Float:z=0.0,Float:dist=0.0))
{
	new i = audio_Index(codename);
	if(i != -1 && SoundInfo[i][sndValid])
	{
		if(!stack && PlayerInfo[playerid][pPlayingSound][i] != 0) audio_StopID(playerid,i,PlayerInfo[playerid][pPlayingSound][i]);
		if(!PlayerInfo[playerid][pPlayingSound][i] && num == -1)
		{
			SetPVarInt(playerid,f("ps-idx-%d",i),PlayerInfo[playerid][pListSounds]);
			PlayerInfo[playerid][pListSound][PlayerInfo[playerid][pListSounds]++] = i;
		}
		PlayerInfo[playerid][pPlayingSound][i] = num, PlayerInfo[playerid][pSoundPosition][i] = 0, PlayerInfo[playerid][pSoundLoop][i] = loop;
		if(SoundInfo[i][sndIsURL] || ONLY_URL_MODE) audio_Stream(playerid,ParseSoundURL(audio_GetAddress(i,num)));
		else
		{
			if(use3d) Use3DSoundOption(playerid,loop ? ("loop3d") : ("play3d"),audio_GetAddress(i,num),SoundInfo[i][sndType],x,y,z,dist);
			else UseSoundOption(playerid,loop ? ("loop") : ("play"),audio_GetAddress(i,num),SoundInfo[i][sndType]);
		}
	}
}
@f(_,audio.Stream(playerid,url[]))
{
	if(!str_startswith(url,"http://")) format(url,M_S,"http://%s",url);
	return PlayAudioStreamForPlayer(playerid,url);
}
@f(_,audio.GetAddress(i,num=-1))
{
	new addr[128];
	format(addr,sizeof(addr),SoundInfo[i][sndAddress]);
	if(num != -1) for(new j = 0, m = strlen(addr); j < m; j++) if(addr[j] == '#') addr[j] = 48 + num, j = m;
	return addr;
}
@f(_,audio.Stop(playerid,codename[],num=-1))
{
	new i = audio_Index(codename);
	if(i != -1 && SoundInfo[i][sndValid]) audio_StopID(playerid,i,num);
}
@f(_,audio.StopAll(playerid)) for(new i = 0; i < MAX_SOUNDS; i++) if(SoundInfo[i][sndValid] && PlayerInfo[playerid][pPlayingSound][i]) audio_StopID(playerid,i,0);
@f(_,audio.StopType(playerid,e_SoundType:type,bool:smooth=false)) for(new i = 0; i < audios[_:type-1]; i++) audio_StopID(playerid,audio[_:type-1][i],0,smooth);
@f(_,audio.StopID(playerid,i,num=-1,bool:smooth=false))
{
	if(PlayerInfo[playerid][pPlayingSound][i] != 0 && SoundInfo[i][sndValid])
	{
		new k[8];
		k = "stop";
		if(smooth) strcat(k,"s");
		if(SoundInfo[i][sndIsURL] || ONLY_URL_MODE) StopAudioStreamForPlayer(playerid);
		else switch(num)
		{
			case -1: UseSoundOption(playerid,k,SoundInfo[i][sndAddress]);
			case 0: if(SoundInfo[i][sndMultiple] > 0) for(new j = 1; j <= SoundInfo[i][sndMultiple]; j++) UseSoundOption(playerid,k,audio_GetAddress(i,j)); else UseSoundOption(playerid,k,SoundInfo[i][sndAddress]);
			default: UseSoundOption(playerid,k,audio_GetAddress(i,num));
		}
		f("ps-idx-%d",i);
		if(GetPVarType(playerid,fstring) != PLAYER_VARTYPE_NONE) audio_Dispose(playerid,GetPVarInt(playerid,fstring));
	}
}
@f(_,audio.Dispose(playerid,i))
{
	PlayerInfo[playerid][pPlayingSound][i] = 0, PlayerInfo[playerid][pSoundPosition][i] = 0, PlayerInfo[playerid][pSoundLoop][i] = false;
	if(PlayerInfo[playerid][pListSounds] > 0)
	{
		for(new j = i; j < PlayerInfo[playerid][pListSounds] && j < MAX_SOUNDS-1; j++) PlayerInfo[playerid][pListSound][j] = PlayerInfo[playerid][pListSound][j+1];
		PlayerInfo[playerid][pListSounds]--;
	}
}
@f(bool,audio.IsPlaying(playerid,codename[]))
{
	new i = audio_Index(codename);
	if(i != -1 && SoundInfo[i][sndValid]) return PlayerInfo[playerid][pPlayingSound][i] != 0;
	return false;
}
@f(bool,audio.IsPlayingType(playerid,e_SoundType:type))
{
	for(new i = 0; i < audios[_:type-1]; i++) if(SoundInfo[audio[_:type-1][i]][sndValid] && PlayerInfo[playerid][pPlayingSound][audio[_:type-1][i]] != 0) return true;
	return false;
}
@f(bool,audio.IsPlayingAny(playerid))
{
	for(new i = 0; i < MAX_SOUNDS; i++) if(SoundInfo[i][sndValid] && PlayerInfo[playerid][pPlayingSound][i] != 0) return true;
	return false;
}
@f(e_SoundType,audio.GetTypeFromID(id))
{
	new e_SoundType:ret = e_SoundType:soundtype_none;
	switch(id)
	{
		case 1: ret = e_SoundType:soundtype_system;
		case 2: ret = e_SoundType:soundtype_effect;
		case 3: ret = e_SoundType:soundtype_music;
		case 4: ret = e_SoundType:soundtype_voice;
	}
	return ret;
}
@f(_,audio.GetIDFromType(id))
{
	switch(id)
	{
		case soundtype_system: return 1;
		case soundtype_effect: return 2;
		case soundtype_music: return 3;
		case soundtype_voice: return 4;
	}
	return 0;
}
@f(_,audio.UpdateLength(playerid,soundid,len)) PlayerInfo[playerid][pSoundLength][soundid] = len;
@f(_,audio.FindByAddress(address[])) return property_IntExist(f("soundaddr_%s",address)) ? property_IntGet(fstring) : -1;
@f(_,audio.Index(codename[])) return property_IntExist(f("sound_%s",codename)) ? property_IntGet(fstring) : -1;
// Sound Effects
@f(_,sound.PlaySystem(playerid,e_SystemSound:sound))
{	// Play from GTA SA sounds
	new snd = -1;
	switch(sound)
	{
		case syssnd_cancel: snd = 1085;
		case syssnd_info: snd = 1056;
		case syssnd_click: snd = 1056;
		case syssnd_tick: snd = 1057;
	}
	if(snd != -1) PlayerPlaySound(playerid,snd,0.0,0.0,0.0);
}
@f(_,sound.PlayEffect(playerid,e_SoundEffects:sound))
{	// Play a random sound effect
	new soundcn[32];
	format(soundcn,sizeof(soundcn),sound_GetCodeName(sound));
	if(strlen(soundcn) > 0)
	{
		new i = audio_Index(soundcn), rnd = -1;
		if(i != -1 && SoundInfo[i][sndValid] && SoundInfo[i][sndType] == e_SoundType:soundtype_effect)
		{
			if(SoundInfo[i][sndMultiple] > 0) rnd = math_random(1,SoundInfo[i][sndMultiple]+1);
			audio_Play(playerid,SoundInfo[i][sndCodeName],.num = rnd);
		}
	}
}
@f(_,sound.PlayEffect3D(Float:x,Float:y,Float:z,e_SoundEffects:sound,playerid=INVALID_PLAYER_ID,Float:d=0.0))
{	// Play a random sound effect at position
	new soundcn[32];
	format(soundcn,sizeof(soundcn),sound_GetCodeName(sound));
	if(strlen(soundcn) > 0)
	{
		new i = audio_Index(soundcn), rnd = -1, Float:rad = d == 0.0 ? DEFAULT_SOUND_RADIUS : d;
		if(i != -1 && SoundInfo[i][sndValid] && SoundInfo[i][sndType] == e_SoundType:soundtype_effect)
		{
			if(SoundInfo[i][sndMultiple] > 0) rnd = math_random(1,SoundInfo[i][sndMultiple]+1);
			Loop(player,p)
			{
				if(d == 0.0) rad = sound_GetDistance(sound,p);
				if(IsPlayerInRangeOfPoint(p,rad,x,y,z))
				{
					if(p == playerid) audio_Play(p,SoundInfo[i][sndCodeName],.num = rnd);
					else audio_Play(p,SoundInfo[i][sndCodeName],.num = rnd,.use3d = true,.x = x,.y = y,.z = z,.dist = rad);
				}
			}
		}
	}
}
@f(_,sound.GetCodeName(e_SoundEffects:sound))
{
	new soundcn[32];
	switch(sound)
	{
		case snd_hit: soundcn = "hit";
		case snd_jump: soundcn = "jump";
		case snd_land: soundcn = "land";
		case snd_cloneout: soundcn = "cloneout";
		case snd_villager_death: soundcn = "villagerdeath";
		case snd_villager_hit: soundcn = "villagerhit";
		case snd_villager_talk: soundcn = "villagertalk";
		case snd_insperm: soundcn = "insperm";
	}
	return soundcn;
}
@f(Float,sound.GetDistance(e_SoundEffects:sound,playerid=INVALID_PLAYER_ID))
{
	new Float:vol = DEFAULT_SOUND_RADIUS;
	switch(sound)
	{
		case snd_hit: vol = 35.0;
		case snd_jump: vol = 25.0;
		case snd_land: vol = 15.0;
		case snd_cloneout: vol = 40.0;
		case snd_villager_death: vol = 80.0;
		case snd_villager_hit: vol = 65.0;
		case snd_villager_talk: vol = 45.0;
	}
	if(playerid != INVALID_PLAYER_ID) vol = floatmul(vol,floatdiv(stats_GetStats(playerid,stats_hearing),100.0));
	return vol;
}
// Music
@f(_,music.Play(playerid,music[],bool:loop=false))
{	// Stop any playing music, play the new music and notice the player
	new i = audio_Index(music);
	if(i != -1 && SoundInfo[i][sndValid] && SoundInfo[i][sndType] == e_SoundType:soundtype_music)
	{
		for(new j = 0; j < audios[_:soundtype_music-1]; j++) audio_StopID(playerid,audio[_:soundtype_music-1][j]);
		audio_Play(playerid,SoundInfo[i][sndCodeName],loop);
		ptd_Update(playerid,e_PlayerTD:ptd_soundtrack,SoundInfo[i][sndCodeName]);
		ptd_Show(playerid,e_PlayerTD:ptd_soundtrack);
	}
}
@f(_,music.Stop(playerid))
{
	audio_StopType(playerid,e_SoundType:soundtype_music,.smooth = true);
	PlayerInfo[playerid][pLastMusicPlayed] = GetTickCount();
}
@f(bool,music.IsPlaying(playerid)) return audio_IsPlayingType(playerid,e_SoundType:soundtype_music);
