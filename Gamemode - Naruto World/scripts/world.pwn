// Anime Fantasy: Naruto World #21 script: world
#define function<%1> forward world_%1; public world_%1
function<OnGameModeInit()>
{
	SetWeather(worldDefault[0] = worldCurrent[0] = 5);
	SetWorldTime(worldDefault[1] = worldCurrent[1] = 9);
	SetGravity(WORLD_GRAVITY);
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	world_Update(playerid);
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second))
	{
		world_TimeUpdate(playerid);
		if(isRainy) SetPlayerRain(playerid);
	}
	return 1;
}
#undef function
@f(_,world.Update(playerid))
{
	TogglePlayerClock(playerid,1);
	SetPlayerTime(playerid,worldCurrent[1],worldCurrent[2]);
	SetPlayerWeather(playerid,worldCurrent[0]);
}
@f(_,world.TimeUpdate(playerid)) SetPlayerTime(playerid,worldCurrent[1],worldCurrent[2]);
@f(_,world.TimeTick())
{
	worldCurrent[2]++;
	if(worldCurrent[2] == 60)
	{
		worldCurrent[2] = 0, worldCurrent[1]++;
		if(worldCurrent[1] == 24) worldCurrent[1] = 0;
	}
}
@f(_,world.SetTimeForPlayer(playerid,hour,minute = 0)) SetPlayerTime(playerid,hour,minute);
@f(_,world.SetWeatherForPlayer(playerid,weatherid)) SetPlayerWeather(playerid,weatherid);
@f(_,world.SetTime(hour,minute = 0))
{
	SetWorldTime(hour);
	Loop(player,i) SetPlayerTime(i,hour,minute);
	worldCurrent[1] = hour, worldCurrent[2] = minute;
}
@f(_,world.SetWeather(weatherid))
{
	SetWeather(weatherid);
	//Loop(player,i) SetPlayerWeather(i,weatherid); (CJ) I don't need this shit!
	worldCurrent[0] = weatherid;
}
