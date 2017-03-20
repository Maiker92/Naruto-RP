// Anime Fantasy: Naruto World #10 script: teams
#define function<%1> forward teams_%1; public teams_%1
function<OnGameModeInit()>
{
	// Loading Teams
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Teams)));
	new m = sqlite_NumRows(), tid = 0;
	if(m >= 1 && m <= MAX_TEAMS) for(new i = 0; i < m; i++)
	{
		tid = strval(sqlite_GetField("id"));
		TeamInfo[tid][tValid] = true;
		format(TeamInfo[tid][tName],32,sqlite_GetField("name"));
		format(TeamInfo[tid][tSName],32,sqlite_GetField("sname"));
		format(TeamInfo[tid][tLeader],32,sqlite_GetField("leader"));
		TeamInfo[tid][tLevel] = strval(sqlite_GetField("level"));
		TeamInfo[tid][tPopulation] = strval(sqlite_GetField("population"));
		format(TeamInfo[tid][tKey],16,sqlite_GetField("key"));
		TeamInfo[tid][tKeyID] = -1;
		for(new j = 0; j < sizeof(TeamKeys) && TeamInfo[tid][tKeyID] == -1; j++) if(equal(TeamInfo[tid][tKey],TeamKeys[j])) TeamInfo[tid][tKeyID] = j;
		for(new j = 0; j < sizeof(PermissionFamilies); j++) if(strfind(PermissionFamilies[j][permfamCode],TeamInfo[tid][tKey],true) != -1) TeamInfo[tid][tPermFamily][TeamInfo[tid][tPermFamilies]++] = j;
		description_Check("Teams",TeamInfo[tid][tSName]);
		printf("Loaded Team: %s (key %d)",TeamInfo[tid][tName],TeamInfo[tid][tKeyID]);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	// Loading Team Spawn Points
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Spawns)));
	m = sqlite_NumRows();
	for(new i = 0; i < m; i++)
	{
		tid = strval(sqlite_GetField("tid"));
		str_loadxyza(sqlite_GetField("pos"),teamSpawn[tid][teamSpawns[tid]++]);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
#undef function
@f(_,teams.GetCount())
{
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Teams)));
	return sqlite_NumRows();
}
@f(_,teams.IsValidTeam(teamid)) return teamid >= 1 && teamid <= teams_GetCount() && TeamInfo[teamid][tValid];
@f(_,teams.GetSpawnPoint(teamid,spawnid,&Float:x,&Float:y,&Float:z,&Float:a)) x = teamSpawn[teamid][spawnid][0], y = teamSpawn[teamid][spawnid][1], z = teamSpawn[teamid][spawnid][2], a = teamSpawn[teamid][spawnid][3];
@f(_,teams.GetRandomSpawnPoint(teamid,&Float:x,&Float:y,&Float:z,&Float:a))
{
	new r = random(teamSpawns[teamid]);
	x = teamSpawn[teamid][r][0], y = teamSpawn[teamid][r][1], z = teamSpawn[teamid][r][2], a = teamSpawn[teamid][r][3];
}
@f(bool,teams.IsAlly(playerid,playerid2)) return PlayerInfo[playerid][pTeam] == PlayerInfo[playerid2][pTeam];
@f(_,teams.ApplyFriendlyFire(playerid))
{
	#pragma unused playerid
	// Bullshit
}
@f(_,teams.AssignPath(teamid,pathid)) TeamInfo[teamid][tPath][TeamInfo[teamid][tPaths]++] = pathid, PathInfo[pathid][pathTeam] = teamid;
@f(_,teams.GetRandomPath(teamid)) return TeamInfo[teamid][tPath][random(TeamInfo[teamid][tPaths])];
@f(bool,teams.ContainsPermissionFamily(teamid,familyid))
{
	for(new i = 0; i < TeamInfo[teamid][tPermFamilies]; i++) if(familyid == TeamInfo[teamid][tPermFamily][i]) return true;
	return false;
}
