@f(_,area.Create(e_AreaType:areatype,e_AreaUse:areause,areaparam,Float:coords[6],Float:size = 0.0))
{
	new aid = -1;
	switch(areatype)
	{
		case areatype_circle: aid = CreateDynamicCircle(coords[0],coords[1],size);
		case areatype_rectangle: aid = CreateDynamicRectangle(coords[0],coords[1],coords[2],coords[3]);
		case areatype_sphere: aid = CreateDynamicSphere(coords[0],coords[1],coords[2],size);
		case areatype_cube: aid = CreateDynamicCube(coords[0],coords[1],coords[2],coords[3],coords[4],coords[5]);
	}
	if(aid == -1) return -1;
	ElementArrayAdd(area,AreaInfo[aid][arArrayPos],aid);
	AreaInfo[aid][arType] = areatype;
	AreaInfo[aid][arValid] = true;
	AreaInfo[aid][arCoords] = coords;
	AreaInfo[aid][arUse] = areause;
	AreaInfo[aid][arParam] = areaparam;
	return aid;
}
@f(_,area.Destroy(aid))
{
	ElementArrayDel(area,AreaInfo[aid][arArrayPos],INVALID_AREA);
	AreaInfo[aid][arType] = e_AreaType:areatype_none;
	AreaInfo[aid][arValid] = false;
	for(new i = 0; i < 6; i++) AreaInfo[aid][arCoords][i] = 0.0;
	DestroyDynamicArea(aid);
}
@f(_,area.Count()) return CountDynamicAreas();
@f(_,area.IsValid(aid)) return aid >= 0 && aid < MAX_STREAMED_AREAS && AreaInfo[aid][arValid] && IsValidDynamicArea(aid);
@f(_,area.IsPlayerIn(aid,playerid)) return IsPlayerInDynamicArea(playerid,aid);
@f(_,area.AttachToObject(aid,oid)) AttachDynamicAreaToObject(aid,oid);
@f(_,area.AttachToPlayer(aid,pid)) AttachDynamicAreaToPlayer(aid,pid);
@f(_,area.AttachToNPC(aid,nid)) AttachDynamicAreaToPlayer(aid,NPCInfo[nid][npcPlayerID]);
/* Streamer:
native CreateDynamicCircle(Float:x, Float:y, Float:size, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicRectangle(Float:minx, Float:miny, Float:maxx, Float:maxy, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicSphere(Float:x, Float:y, Float:z, Float:size, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicCube(Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz, worldid = -1, interiorid = -1, playerid = -1);
native CreateDynamicPolygon(Float:points[], Float:minz = -FLOAT_INFINITY, Float:maxz = FLOAT_INFINITY, maxpoints = sizeof points, worldid = -1, interiorid = -1, playerid = -1);
native DestroyDynamicArea(areaid);
native IsValidDynamicArea(areaid);
native GetDynamicPolygonPoints(areaid, Float:points[], maxlength = sizeof points);
native GetDynamicPolygonNumberPoints(areaid);
native TogglePlayerDynamicArea(playerid, areaid, toggle);
native TogglePlayerAllDynamicAreas(playerid, toggle);
native IsPlayerInDynamicArea(playerid, areaid, recheck = 0);
native IsPlayerInAnyDynamicArea(playerid, recheck = 0);
native IsAnyPlayerInDynamicArea(areaid, recheck = 0);
native IsAnyPlayerInAnyDynamicArea(recheck = 0);
native GetPlayerDynamicAreas(playerid, areas[], maxlength = sizeof areas);
native GetPlayerNumberDynamicAreas(playerid);
native IsPointInDynamicArea(areaid, Float:x, Float:y, Float:z);
native IsPointInAnyDynamicArea(Float:x, Float:y, Float:z);
native AttachDynamicAreaToObject(areaid, objectid, type = STREAMER_OBJECT_TYPE_DYNAMIC, playerid = INVALID_PLAYER_ID);
native AttachDynamicAreaToPlayer(areaid, playerid);
native AttachDynamicAreaToVehicle(areaid, vehicleid); */
