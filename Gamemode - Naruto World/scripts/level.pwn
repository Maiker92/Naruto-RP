// Anime Fantasy: Naruto World #23 script: level
#define function<%1> forward level_%1; public level_%1
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
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	return 1;
}
function<OnPlayerTakeDamage(playerid,issuerid,Float:amount,weaponid)>
{
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second))
	{
	}
	return 1;
}
#undef function
// Level
@f(_,level.GetNextLevel(playerid)) return PlayerInfo[playerid][pLevel] + _:(PlayerInfo[playerid][pLevel] < sizeof(Levels)-1);
@f(_,level.Get(playerid)) return PlayerInfo[playerid][pLevel];
@f(_,level.Set(playerid,lvl))
{
	PlayerInfo[playerid][pLevel] = lvl;
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"lvl");
}
// XP
@f(_,xp.GetNextLevel(playerid)) return Levels[level_GetNextLevel(playerid)][lvlXP];
@f(_,xp.Get(playerid)) return PlayerInfo[playerid][pXP];
@f(_,xp.Add(playerid,amount,bool:check = true))
{
	PlayerInfo[playerid][pXP] += amount;
	if(!check || (check && !xp_LevelCheck(playerid))) ptd_Update(playerid,e_PlayerTD:ptd_stats,"lvl");
}
@f(_,xp.Set(playerid,xp))
{
	PlayerInfo[playerid][pXP] = xp;
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"lvl");
}
@f(bool,xp.LevelCheck(playerid))
{
	if(PlayerInfo[playerid][pXP] >= xp_GetNextLevel(playerid) && PlayerInfo[playerid][pLevel] != level_GetNextLevel(playerid))
	{
		PlayerInfo[playerid][pLevel] = level_GetNextLevel(playerid);
		ptd_Update(playerid,e_PlayerTD:ptd_stats,"lvl");
		// level up shit
		return true;
	}
	return false;
}
@f(_,xp.Log(playerid,amount,name[],details[]))
{
}
/*
time xp:
+1 xp for 1min play

player kill xp:
+150 +10*level xp
% given for each player contributed to the kill (damaging enemy / healing allies / cc / aura)

player kill bonus xp:
+25 last hit bonus if there were more than 1 players
+10 for each level difference if there was only 1 player

npc (villager/creeps/...) kill xp:
+0-300 based on difficulty
% for each player around

fighting xp:
+1 xp for 20s fighting

pickup xp:
+0-100 based on difficulty to find
*/
