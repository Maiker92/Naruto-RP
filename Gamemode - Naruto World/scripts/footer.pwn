// Anime Fantasy: Naruto World #03 script: footer
#define function<%1> forward footer_%1; public footer_%1
function<OnGameModeInit()>
{
	security_Log("Server","Started");
	return 1;
}
function<OnGameModeExit()>
{
	sqlite_FreeResults();
	sqlite_Disconnect(gameDatabase);
	sqlite_Disconnect(serverDatabase);
	security_Log("Server","Stopped");
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	ElementArrayDel(player,PlayerInfo[playerid][pArrayPos],INVALID_PLAYER_ID);
	PlayerInfo[playerid][pArrayPos] = -1;
	player_ResetInfo(playerid);
	player_ResetCharacterInfo(playerid);
	return 1;
}
function<OnNPCReachDestination(npcid)>
{
	if(PlayerInfo[npcid][pNPCIndex] != INVALID_PLAYER_ID)
	{
		new r = route_Find(PlayerInfo[npcid][pNPCIndex],e_RouteOwnerType:routeowner_npc);
		if(r != INVALID_ROUTE) route_FinishPos(r,false); // No need to check NPC position thanks to FCNPC
	}
	return 1;
}
function<OnSObjectMoved(objectid)>
{
	new r = route_Find(objectid,e_RouteOwnerType:routeowner_object);
	if(r != INVALID_ROUTE) route_FinishPos(r,false); // No need to check object position thanks to Incognito's Streamer & SA-MP
	return 1;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	PlayerInfo[playerid][pLastDialogInfo][0] = dialogid;
	PlayerInfo[playerid][pLastDialogInfo][1] = response;
	PlayerInfo[playerid][pLastDialogInfo][2] = listitem;
	if(DialogInfo[dialogid][dParent] != d_Null && (!response || PlayerInfo[playerid][pDialogOneButton])) dialog_GoBack(playerid);
	return 1;
}
#undef function
