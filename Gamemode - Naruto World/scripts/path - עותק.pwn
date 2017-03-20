// Anime Fantasy: Naruto World #29 script: path
#define function<%1> forward path_%1; public path_%1
//#define DEBUG_PATH // Used to print route movement
static pathsCount = 0;
function<OnGameModeInit()>
{
	// Loading paths
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Paths)));
	new m = sqlite_NumRows(), pid = 0, n[MAX_NAME_LENGTH], Float:p[3];
	for(new i = 0, bool:newPath = false, conn = -1; i < m && pathsCount < MAX_PATHS; i++)
	{
		format(n,sizeof(n),sqlite_GetField("name"));
		if((pid = path_Find(n)) == -1) pid = path_Create(n,strval(sqlite_GetField("id"))), newPath = true;
		PathInfo[pid][pathTeam] = strval(sqlite_GetField("tid"));
		if(newPath && PathInfo[pid][pathTeam] != -1) teams_AssignPath(PathInfo[pid][pathTeam],pid);
		str_loadxyz(sqlite_GetField("pos"),p);
		path_AddPosition(pid,p[0],p[1],p[2],floatstr(sqlite_GetField("maxxoffset")),floatstr(sqlite_GetField("maxyoffset")));
		if(strval(sqlite_GetField("endpoint"))) PathInfo[pid][pathEndPoint] = PathInfo[pid][pathCount] - 1;
		if(newPath)
		{
			printf("Loaded Path: %s",PathInfo[pid][pathName]);
			newPath = false;
			format(n,sizeof(n),sqlite_GetField("connection"));
			if(equal(n,"N")) PathInfo[pid][pathConnectedTo] = 0;
			else
			{
				conn = path_Find(n);
				if(conn == -1) printf("Warning: Wrong path connection ('%s') in last loaded path.",n);
				else PathInfo[pid][pathConnectedTo] = conn, PathInfo[conn][pathConnection][PathInfo[conn][pathConnections]++] = pid;
			}
		}
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
// Path
@f(_,path.Create(name[],sqlid = -1))
{
	if(pathsCount >= MAX_PATHS) return -1;
	new pathid = pathsCount++;
	PathInfo[pathid][pathValid] = true;
	format(PathInfo[pathid][pathName],MAX_NAME_LENGTH,name);
	PathInfo[pathid][pathCount] = 0;
	PathInfo[pathid][pathEndPoint] = -1;
	PathInfo[pathid][pathTeam] = -1;
	PathInfo[pathid][pathID] = sqlid;
	PathInfo[pathid][pathConnections] = 0;
	PathInfo[pathid][pathConnectedTo] = 0;
	property_IntSet(f("path-%s",name),pathid);
	return pathid;
}
@f(_,path.SetTeam(pathid,teamid)) PathInfo[pathid][pathTeam] = teamid;
@f(bool,path.IsValid(pathid)) return pathid >= 0 && pathid < MAX_PATHS ? PathInfo[pathid][pathValid] : false;
@f(_,path.AddPosition(pathid,Float:x,Float:y,Float:z,Float:ox=0.0,Float:oy=0.0))
{
	PathInfo[pathid][pathX][PathInfo[pathid][pathCount]] = x;
	PathInfo[pathid][pathY][PathInfo[pathid][pathCount]] = y;
	PathInfo[pathid][pathZ][PathInfo[pathid][pathCount]] = z;
	PathInfo[pathid][pathOX][PathInfo[pathid][pathCount]] = ox;
	PathInfo[pathid][pathOY][PathInfo[pathid][pathCount]] = oy;
	PathInfo[pathid][pathCount]++;
}
@f(_,path.GetPosition(pathid,pos,&Float:x,&Float:y,&Float:z,&Float:ox,&Float:oy)) x = PathInfo[pathid][pathX][pos], y = PathInfo[pathid][pathY][pos], z = PathInfo[pathid][pathZ][pos], ox = PathInfo[pathid][pathOX][pos], oy = PathInfo[pathid][pathOY][pos];
@f(_,path.GetCount(pathid)) return PathInfo[pathid][pathCount];
@f(_,path.Find(name[]))
{
	f("path-%s",name);
	if(property_IntExist(fstring)) return property_IntGet(fstring);
	//for(new i = 0; i < MAX_PATHS; i++) if(equal(PathInfo[i][pathName],name)) return i;
	return -1;
}
@f(_,path.Go(pathid,ownerid,e_RouteOwnerType:ownertype,e_RouteMoveType:movetype,bool:loop,param = 0,pos = -1))
{
	new route = route_StartNew(); // Go with a new route
	if(route != INVALID_ROUTE)
	{
		RouteInfo[route][rtPath] = pathid;
		RouteInfo[route][rtMoveType] = movetype;
		RouteInfo[route][rtLooping] = loop;
		RouteInfo[route][rtPosition] = pos == -1 ? route_GetStartPoint(route) : pos;
		RouteInfo[route][rtPositionParam] = 0;
		RouteInfo[route][rtParam] = param;
		#if defined DEBUG_PATH
			printf("Path %d started for %d(%d), route id = %d",pathid,ownerid,_:ownertype,route);
		#endif
		route_Assign(route,ownerid,ownertype);
		route_Continue(route); // First move
	}
	return route;
}
@f(_,path.GetConnection(pathid,conn=-1)) return PathInfo[pathid][pathConnections] > 0 ? PathInfo[pathid][pathConnection][conn == -1 ? random(PathInfo[pathid][pathConnections]) : conn] : 0;
// Route
@f(_,route.StartNew())
{
	new route = INVALID_ROUTE;
	for(new i = 0; i < MAX_ROUTES && route == INVALID_ROUTE; i++) if(!RouteInfo[i][rtValid]) route = i;
	if(route != INVALID_ROUTE) RouteInfo[route][rtValid] = true;
	return route;
}
@f(_,route.Assign(routeid,ownerid,e_RouteOwnerType:ownertype))
{
	RouteInfo[routeid][rtOwnerType] = ownertype;
	RouteInfo[routeid][rtOwner] = ownerid;
	property_IntSet(f("routeid-%d-%d",ownerid,_:ownertype),routeid);
}
@f(_,route.Continue(routeid))
{
	new prev = RouteInfo[routeid][rtPosition];
	switch(RouteInfo[routeid][rtMoveType])
	{
		case routemove_path: if(RouteInfo[routeid][rtPosition] < PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1) RouteInfo[routeid][rtPosition]++;
		case routemove_random:
		{
			new rnd = 0;
			if(PathInfo[RouteInfo[routeid][rtPath]][pathCount] >= 2)
			{
				do rnd = random(PathInfo[RouteInfo[routeid][rtPath]][pathCount]);
				while rnd == RouteInfo[routeid][rtPosition];
			}
			RouteInfo[routeid][rtPosition] = rnd;
		}
		case routemove_pathb: if(RouteInfo[routeid][rtPosition] > 0) RouteInfo[routeid][rtPosition]--;
	}
	if(prev != RouteInfo[routeid][rtPosition]) route_Go(routeid);
	#if defined DEBUG_PATH
		if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) continue from %d to %d/%d",routeid,RouteInfo[routeid][rtPath],prev,RouteInfo[routeid][rtPosition],PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1);
	//#else
	//	#pragma unused prev
	#endif
}
@f(_,route.GetOwnerID(routeid)) return RouteInfo[routeid][rtOwner];
@f(e_RouteOwnerType,route.GetOwnerType(routeid)) return RouteInfo[routeid][rtOwnerType];
@f(_,route.Find(ownerid,e_RouteOwnerType:ownertype))
{
	f("routeid-%d-%d",ownerid,_:ownertype);
	return property_IntExist(fstring) ? property_IntGet(fstring) : INVALID_ROUTE;
}
@f(_,route.Go(routeid,pos=-1))
{
	if(pos == -1) pos = RouteInfo[routeid][rtPosition];
	new Float:x = PathInfo[RouteInfo[routeid][rtPath]][pathX][pos] + (PathInfo[RouteInfo[routeid][rtPath]][pathOX][pos] > 0.0 ? math_frandom(-PathInfo[RouteInfo[routeid][rtPath]][pathOX][pos],PathInfo[RouteInfo[routeid][rtPath]][pathOX][pos]) : 0.0),
		Float:y = PathInfo[RouteInfo[routeid][rtPath]][pathY][pos] + (PathInfo[RouteInfo[routeid][rtPath]][pathOY][pos] > 0.0 ? math_frandom(-PathInfo[RouteInfo[routeid][rtPath]][pathOY][pos],PathInfo[RouteInfo[routeid][rtPath]][pathOY][pos]) : 0.0),
		Float:z = PathInfo[RouteInfo[routeid][rtPath]][pathZ][pos] + 0.4;
	switch(RouteInfo[routeid][rtOwnerType])
	{
		case routeowner_npc: npc_Move(RouteInfo[routeid][rtOwner],RouteInfo[routeid][rtParam],x,y,z);
		case routeowner_object: object_Move(RouteInfo[routeid][rtOwner],x,y,z,float(RouteInfo[routeid][rtParam]));
	}
	#if defined DEBUG_PATH
		if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) going to %d/%d",routeid,RouteInfo[routeid][rtPath],RouteInfo[routeid][rtPosition],PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1);
	#endif
}
@f(_,route.GetStartPoint(routeid))
{
	switch(RouteInfo[routeid][rtMoveType])
	{
		case routemove_path: return 0;
		case routemove_random: return random(PathInfo[RouteInfo[routeid][rtPath]][pathCount]);
		case routemove_pathb: return PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1;
	}
	return -1;
}
@f(_,route.GetFinishPoint(routeid))
{
	switch(RouteInfo[routeid][rtMoveType])
	{
		case routemove_path: return PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1;
		//case routemove_random: return -1;
		case routemove_pathb: return 0;
	}
	return -1;
}
@f(bool,route.CheckFinishPos(routeid))
{
	new Float:x, Float:y, Float:z;
	switch(RouteInfo[routeid][rtOwnerType])
	{
		case routeowner_npc: npc_GetPosition(RouteInfo[routeid][rtOwner],x,y,z);
		case routeowner_object: object_GetPos(RouteInfo[routeid][rtOwner],x,y,z);
	}
	return math_distance_3d(x,y,z,PathInfo[RouteInfo[routeid][rtPath]][pathX][RouteInfo[routeid][rtPosition]],PathInfo[RouteInfo[routeid][rtPath]][pathY][RouteInfo[routeid][rtPosition]],PathInfo[RouteInfo[routeid][rtPath]][pathZ][RouteInfo[routeid][rtPosition]]) <3; // I like this system!
}
@f(bool,route.IsFinishPoint(routeid,bool:checkpos=false)) // checks if the current pos of the route is the end of it. DOESN'T checks if the owner actually finished the path, unless 'checkpos' is used
{
	new fp = route_GetFinishPoint(routeid);
	return fp == -1 ? false : ((RouteInfo[routeid][rtPosition] == fp || route_IsEndPoint(routeid)) && (!checkpos || (checkpos && route_CheckFinishPos(routeid))));
}
@f(bool,route.IsEndPoint(routeid)) return PathInfo[RouteInfo[routeid][rtPath]][pathEndPoint] > -1 && RouteInfo[routeid][rtPosition] == PathInfo[RouteInfo[routeid][rtPath]][pathEndPoint];
@f(_,route.ConfirmEnd(routeid,bool:endlooping = true))
{
	if(!endlooping && RouteInfo[routeid][rtLooping])
	{
		#if defined DEBUG_PATH
			if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) looping",routeid,RouteInfo[routeid][rtPath]);
		#endif
		RouteInfo[routeid][rtPosition] = route_GetStartPoint(routeid), RouteInfo[routeid][rtPositionParam] = 0;
		route_Go(routeid); // Go back to the start!
	}
	else
	{
		#if defined DEBUG_PATH
			if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) ended",routeid,RouteInfo[routeid][rtPath]);
		#endif
		RouteInfo[routeid][rtValid] = false;
		property_IntRemove(f("routeid-%d-%d",RouteInfo[routeid][rtOwner],_:RouteInfo[routeid][rtOwnerType]));
	}
	return 1;
}
@f(_,route.FinishPos(routeid,bool:checkfinish))
{
	if(checkfinish) if(!route_CheckFinishPos(routeid)) return;
	if(OnPathRouteCompleted(RouteInfo[routeid][rtPath],routeid,RouteInfo[routeid][rtPosition]))
	{
		if(route_IsFinishPoint(routeid)) route_ConfirmEnd(routeid);
		else route_Continue(routeid);
	}
}
