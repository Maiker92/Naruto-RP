@f(_,vworld.Set(playerid,worldid))
{
	virtualWorldPlayers[GetPlayerVirtualWorld(playerid)]--;
	virtualWorldPlayers[(SetPlayerVirtualWorld(playerid,worldid), worldid)]++;
}
@f(_,vworld.Get(playerid)) return GetPlayerVirtualWorld(playerid);
@f(_,vworld.CountPlayers(worldid)) return virtualWorldPlayers[worldid];
@f(_,vworld.FindEmpty())
{
	for(new i = VW_END; i <= MAX_VIRTUAL_WORLDS; i++)
	{
		if(virtualWorldPlayers[i] > 0) continue;
		return i;
	}
	return INVALID_VIRTUAL_WORLD;
}
