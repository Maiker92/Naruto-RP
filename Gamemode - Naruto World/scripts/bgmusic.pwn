// Anime Fantasy: Naruto World #33 script: bgmusic
#define function<%1> forward bgmusic_%1; public bgmusic_%1
function<OnGameModeInit()>
{
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	SetPVarInt(playerid,"bgmusic_idx",-1);
	SetPVarString(playerid,"bgmusic_spc","none");
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	// Spawn Background Music
	bgmusic_Play(playerid,e_BackgroundMusic:bgm_home);
	return 1;
}
function<OnBackgroundMusicEnd(playerid,e_BackgroundMusic:bgmusic,bgmusicname[],soundid)>
{
	SendClientMessage(playerid,-1,f("Finished: %s",bgmusicname));
	if(bgmusic == e_BackgroundMusic:bgm_home) bgmusic_Play(playerid,e_BackgroundMusic:bgm_home,.forcerandom = true);
	return 1;
}
#undef function
forward BGMusicPlay(playerid,bgidx,bgmusicname[]);
public BGMusicPlay(playerid,bgidx,bgmusicname[])
{
	if(music_IsPlaying(playerid)) music_Stop(playerid);
	music_Play(playerid,bgmusicname);
	SetPVarInt(playerid,"bgmusic_idx",bgidx);
	SetPVarString(playerid,"bgmusic_spc",bgmusicname);
	return 1;
}
// Background Music
@f(_,bgmusic.Play(playerid,e_BackgroundMusic:bgm,param[]="",bool:forcerandom=false))
{
	#pragma unused param
	new musicname[MAX_NAME_LENGTH];
	if(!PlayerInfo[playerid][pTeam]) return musicname;
	do switch(bgm)
	{
		case bgm_home:
		{
			switch(TeamInfo[PlayerInfo[playerid][pTeam]][tKeyID])
			{
				case TEAMKEY_KONOHA: switch(random(8))
				{
					case 0: musicname = "uns3mmt";
					case 1: musicname = "unsgmmt";
					case 2: musicname = "mnost0205";
					case 3: musicname = "mnost0904";
					case 4: musicname = "mnost0508";
					case 5: musicname = "mnost0509";
					case 6: musicname = "mnost0607";
					case 7: musicname = "nost0202";
				}
				case TEAMKEY_SAND: switch(random(7))
				{
					case 0: musicname = "uns3mmt";
					case 1: musicname = "unsgmmt";
					case 2: musicname = "mnost0904";
					case 3: musicname = "mnost0607";
					case 4: musicname = "mnost0201";
					case 5: musicname = "uns2st";
					case 6: musicname = "uns3fbst";
				}
				case TEAMKEY_AKATSUKI: switch(random(3))
				{
					case 0: musicname = "dbzost0227";
					case 1: musicname = "mnost0804";
					case 2: musicname = "mnost0502";
				}
			}
		}
	}
	while forcerandom && equal(musicname,bgmusic_GetCurrentName(playerid));
	SendClientMessage(playerid,-1,f("Play: %s",musicname));
	new last = GetTickCount()-PlayerInfo[playerid][pLastMusicPlayed];
	if(last <= DELAY_BETWEEN_MUSIC) SetTimerEx("BGMusicPlay",max(10,DELAY_BETWEEN_MUSIC-last),0,"iis",playerid,_:bgm,musicname);
	else BGMusicPlay(playerid,_:bgm,musicname);
	return musicname;
}
@f(e_BackgroundMusic,bgmusic.GetCurrent(playerid)) return e_BackgroundMusic:GetPVarInt(playerid,"bgmusic_idx");
@f(_,bgmusic.GetCurrentName(playerid))
{
	new musicname[MAX_NAME_LENGTH];
	GetPVarString(playerid,"bgmusic_spc",musicname,sizeof(musicname));
	return musicname;
}
