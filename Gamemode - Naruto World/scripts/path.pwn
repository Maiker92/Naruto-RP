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
		PathInfo[pid][pathType] = path_GetTypeByID(strval(sqlite_GetField("flag")));
		str_loadxyz(sqlite_GetField("pos"),p);
		path_AddPosition(pid,p[0],p[1],p[2],floatstr(sqlite_GetField("xon")),floatstr(sqlite_GetField("xom")),floatstr(sqlite_GetField("yon")),floatstr(sqlite_GetField("yom")));
		if(newPath)
		{
			printf("Loaded Path: %s",PathInfo[pid][pathName]);
			newPath = false;
			format(n,sizeof(n),sqlite_GetField("parent"));
			if(equal(n,"N")) PathInfo[pid][pathParent] = -1;
			else
			{
				conn = path_Find(n);
				if(conn == -1) printf("Warning: Wrong path connection ('%s') in last loaded path.",n);
				else PathInfo[pid][pathParent] = conn, PathInfo[conn][pathConnection][PathInfo[conn][pathConnections]++] = pid;
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
/**
	<summary>Gets a type of path as e_PathType by path ID.</summary>
	<param name="id">The path ID.</param>
	<returns>The path type.</returns>
*/
@f(e_PathType,path.GetTypeByID(id))
{
	switch(id)
	{
		case 0: return path_point;
		case 1: return path_spawn;
		case 2: return path_endpoint;
	}
	return path_point;
}
/**
	<summary>Creates a new path.</summary>
	<param name="name">Name for the new path.</param>
	<param name="sqlid">ID of the path in the database.</param>
	<returns>The path ID or -1 if there are too many paths (above MAX_PATHS limit).</returns>
*/
@f(_,path.Create(name[],sqlid = -1))
{
	if(pathsCount >= MAX_PATHS) return -1;
	new pathid = pathsCount++;
	PathInfo[pathid][pathValid] = true;
	format(PathInfo[pathid][pathName],MAX_NAME_LENGTH,name);
	PathInfo[pathid][pathCount] = 0;
	PathInfo[pathid][pathType] = e_PathType:path_point;
	PathInfo[pathid][pathID] = sqlid;
	PathInfo[pathid][pathConnections] = 0;
	PathInfo[pathid][pathParent] = -1;
	property_IntSet(f("path-%s",name),pathid);
	return pathid;
}
/**
	<summary>Assigns a path to a specific team.</summary>
	<param name="pathid">Path ID.</param>
	<param name="teamid">Team ID to assign the path to.</param>
*/
@f(_,path.SetTeam(pathid,teamid)) PathInfo[pathid][pathTeam] = teamid;
/**
	<summary>Checks if a path ID is valid and exist.</summary>
	<param name="pathid">Path ID.</param>
	<returns>True if the given ID is valid, false otherwise.</returns>
*/
@f(bool,path.IsValid(pathid)) return pathid >= 0 && pathid < MAX_PATHS ? PathInfo[pathid][pathValid] : false;
/**
	<summary>Adds a position to a path.</summary>
	<param name="pathid">Path ID.</param>
	<param name="x">X position.</param>
	<param name="y">Y position.</param>
	<param name="z">Z position.</param>
	<param name="xon">X offset minimum.</param>
	<param name="xom">X offset maximum.</param>
	<param name="yon">Y offset minimum.</param>
	<param name="yom">Y offset maximum.</param>
*/
@f(_,path.AddPosition(pathid,Float:x,Float:y,Float:z,Float:xon=0.0,Float:xom=0.0,Float:yon=0.0,Float:yom=0.0))
{
	PathInfo[pathid][pathX][PathInfo[pathid][pathCount]] = x;
	PathInfo[pathid][pathY][PathInfo[pathid][pathCount]] = y;
	PathInfo[pathid][pathZ][PathInfo[pathid][pathCount]] = z;
	PathInfo[pathid][pathXON][PathInfo[pathid][pathCount]] = xon;
	PathInfo[pathid][pathXOM][PathInfo[pathid][pathCount]] = xom;
	PathInfo[pathid][pathYON][PathInfo[pathid][pathCount]] = yon;
	PathInfo[pathid][pathYOM][PathInfo[pathid][pathCount]] = yom;
	PathInfo[pathid][pathCount]++;
}
/**
	<summary>Gets a specific position coordinates of path.</summary>
	<param name="pathid">Path ID.</param>
	<param name="pos">Position ID.</param>
	<param name="x">X position variable.</param>
	<param name="y">Y position variable.</param>
	<param name="z">Z position variable.</param>
*/
@f(_,path.GetPosition(pathid,pos,&Float:x,&Float:y,&Float:z)) x = PathInfo[pathid][pathX][pos], y = PathInfo[pathid][pathY][pos], z = PathInfo[pathid][pathZ][pos];
/**
	<summary>Gets a specific position offsets of path.</summary>
	<param name="pathid">Path ID.</param>
	<param name="pos">Position ID.</param>
	<param name="xon">X min. offset variable.</param>
	<param name="xom">X max. offset variable.</param>
	<param name="yon">Y min. offset variable.</param>
	<param name="yom">Y max. offset variable.</param>
*/
@f(_,path.GetOffsets(pathid,pos,&Float:xon,&Float:xom,&Float:yon,&Float:yox))
{
	xon = PathInfo[pathid][pathXON][pos], xom = PathInfo[pathid][pathXOM][pos], yon = PathInfo[pathid][pathYON][pos], yom = PathInfo[pathid][pathYOM][pos];
}
/**
	<summary>Gets a specific path position counts.</summary>
	<param name="pathid">Path ID.</param>
	<returns>The amount of positions in path.</returns>
*/
@f(_,path.GetCount(pathid)) return PathInfo[pathid][pathCount];
/**
	<summary>Finds a path ID by its name.</summary>
	<param name="name">Path name.</param>
	<returns>Path ID or -1 if nothing found.</returns>
*/
@f(_,path.Find(name[]))
{
	f("path-%s",name);
	if(property_IntExist(fstring)) return property_IntGet(fstring);
	//for(new i = 0; i < MAX_PATHS; i++) if(equal(PathInfo[i][pathName],name)) return i;
	return -1;
}
/**
	<summary>Makes an entity start going through a path by creating a new route for it.</summary>
	<param name="pathid">Path ID.</param>
	<param name="ownerid">ID of the entity.</param>
	<param name="ownertype">Type of the entity as e_RouteOwnerType.</param>
	<param name="movetype">Moving type as e_RouteMoveType.</param>
	<param name="loop">Should the entity loop after finishing?</param>
	<param name="param">Moving parameter (e.g walking style, etc).</param>
	<param name="pos">Position in the path to start from. Use -1 to start from the default starting point.</param>
	<returns>The newly created route ID.</returns>
*/
@f(_,path.Go(pathid,ownerid,e_RouteOwnerType:ownertype,e_RouteMoveType:movetype,bool:loop,param = 0,pos = -1))
{
	new route = route_StartNew(); // Go with a new route
	if(route != INVALID_ROUTE)
	{
		RouteInfo[route][rtPath] = pathid;
		RouteInfo[route][rtMoveType] = movetype;
		RouteInfo[route][rtLooping] = loop;
		RouteInfo[route][rtPosition] = pos == -1 ? path_GetStartPoint(pathid,movetype) : pos;
		RouteInfo[route][rtPositionParam] = 0;
		RouteInfo[route][rtNextPosition] = -1;
		RouteInfo[route][rtParam] = param;
		#if defined DEBUG_PATH
			printf("Path %d started for %d(%d), route id = %d",pathid,ownerid,_:ownertype,route);
		#endif
		route_Assign(route,ownerid,ownertype);
		route_Set(route);
		route_Continue(route); // First move
	}
	return route;
}
/**
	<summary>Gets a connection to a path.</summary>
	<param name="pathid">Path ID.</param>
	<param name="conn">Connection index to get. Use -1 for a random connection.</param>
	<returns>The connected path ID or -1 if there are no any connections.</returns>
*/
@f(_,path.GetConnection(pathid,conn=-1)) return PathInfo[pathid][pathConnections] > 0 ? PathInfo[pathid][pathConnection][conn == -1 ? random(PathInfo[pathid][pathConnections]) : conn] : -1;
/**
	<summary>Gets the default starting point of a path.</summary>
	<param name="pathid">Path ID.</param>
	<param name="movetype">Move type of the path as e_RouteMoveType.</param>
	<returns>The starting point or -1 if a wrong movetype is given.</returns>
*/
@f(_,path.GetStartPoint(pathid,e_RouteMoveType:movetype))
{
	switch(movetype)
	{
		case routemove_path: return 0;
		case routemove_random: return random(PathInfo[pathid][pathCount]);
	}
	return -1;
}
/**
	<summary>Gets the default finishing point of a path.</summary>
	<param name="pathid">Path ID.</param>
	<param name="movetype">Move type of the path as e_RouteMoveType.</param>
	<returns>The finishing point or -1 if a wrong movetype is given or there is no finishing point.</returns>
*/
@f(_,path.GetFinishPoint(pathid,e_RouteMoveType:movetype))
{
	switch(movetype)
	{
		case routemove_path: return PathInfo[pathid][pathCount]-1;
		case routemove_random: return -1;
	}
	return -1;
}
// Route
/**
	<summary>Starts a new route.</summary>
	<returns>The newly created route ID or INVALID_ROUTE if an error has occured (e.g too many routes, etc).</returns>
*/
@f(_,route.StartNew())
{
	new route = INVALID_ROUTE;
	for(new i = 0; i < MAX_ROUTES && route == INVALID_ROUTE; i++) if(!RouteInfo[i][rtValid]) route = i;
	if(route != INVALID_ROUTE) RouteInfo[route][rtValid] = true;
	return route;
}
/**
	<summary>Assigns a route to an entity.</summary>
	<param name="routeid">Route ID.</param>
	<param name="ownerid">The entity ID to assign.</param>
	<param name="ownertype">The entity type as e_RouteOwnerType.</param>
*/
@f(_,route.Assign(routeid,ownerid,e_RouteOwnerType:ownertype))
{
	RouteInfo[routeid][rtOwnerType] = ownertype;
	RouteInfo[routeid][rtOwner] = ownerid;
	property_IntSet(f("routeid-%d-%d",ownerid,_:ownertype),routeid);
}
/**
	<summary>Makes the route owner entity go to the next position from its current position.</summary>
	<param name="routeid">Route ID.</param>
*/
@f(_,route.Continue(routeid))
{
	new prev = RouteInfo[routeid][rtPosition], next = -1;
	switch(RouteInfo[routeid][rtMoveType])
	{
		case routemove_path: if(RouteInfo[routeid][rtPosition] < path_GetFinishPoint(RouteInfo[routeid][rtPath],RouteInfo[routeid][rtMoveType])) next = prev + 1;
		case routemove_random: if(PathInfo[RouteInfo[routeid][rtPath]][pathCount] >= 2)
		{
			do next = random(PathInfo[RouteInfo[routeid][rtPath]][pathCount]);
			while next == prev;
		}
	}
	if(next != -1 && prev != next) route_Go(routeid,next);
	#if defined DEBUG_PATH
		if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) continue from %d to %d/%d",routeid,RouteInfo[routeid][rtPath],prev,next,PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1);
	//#else
	//	#pragma unused prev
	#endif
}
/**
	<summary>Gets the owner entity ID of a route.</summary>
	<param name="routeid">Route ID.</param>
	<returns>The owner ID.</returns>
*/
@f(_,route.GetOwnerID(routeid)) return RouteInfo[routeid][rtOwner];
/**
	<summary>Gets the owner entity type of a route.</summary>
	<param name="routeid">Route ID.</param>
	<returns>The owner type as e_RouteOwnerType.</returns>
*/
@f(e_RouteOwnerType,route.GetOwnerType(routeid)) return RouteInfo[routeid][rtOwnerType];
/**
	<summary>Finds a route ID based on an owner entity.</summary>
	<param name="ownerid">The owner entity ID.</param>
	<param name="ownertype">The owner entity type.</param>
	<returns>The route ID or INVALID_ROUTE if no route has been found.</returns>
*/
@f(_,route.Find(ownerid,e_RouteOwnerType:ownertype))
{
	f("routeid-%d-%d",ownerid,_:ownertype);
	return property_IntExist(fstring) ? property_IntGet(fstring) : INVALID_ROUTE;
}
/**
	<summary>Sets an owner entity position to a given position index in a route.</summary>
	<param name="routeid">Route ID.</param>
	<param name="pos">The position index to set the entity position to or -1 to just put him in his current position index.</param>
*/
@f(_,route.Set(routeid,pos=-1))
{
	if(pos == -1) pos = RouteInfo[routeid][rtPosition];
	else RouteInfo[routeid][rtPosition] = pos;
	RouteInfo[routeid][rtNextPosition] = -1;
	new Float:x = PathInfo[RouteInfo[routeid][rtPath]][pathX][pos],
		Float:y = PathInfo[RouteInfo[routeid][rtPath]][pathY][pos],
		Float:z = PathInfo[RouteInfo[routeid][rtPath]][pathZ][pos] + 0.4;
	if(PathInfo[RouteInfo[routeid][rtPath]][pathXON][pos] != 0.0 || PathInfo[RouteInfo[routeid][rtPath]][pathXOM][pos] != 0.0) x += math_frandom(PathInfo[RouteInfo[routeid][rtPath]][pathXON][pos],PathInfo[RouteInfo[routeid][rtPath]][pathXOM][pos]);
	if(PathInfo[RouteInfo[routeid][rtPath]][pathYON][pos] != 0.0 || PathInfo[RouteInfo[routeid][rtPath]][pathYOM][pos] != 0.0) x += math_frandom(PathInfo[RouteInfo[routeid][rtPath]][pathYON][pos],PathInfo[RouteInfo[routeid][rtPath]][pathYOM][pos]);
	switch(RouteInfo[routeid][rtOwnerType])
	{
		case routeowner_npc: npc_SetPosition(RouteInfo[routeid][rtOwner],x,y,z);
		case routeowner_object: object_SetPos(RouteInfo[routeid][rtOwner],x,y,z);
	}
	#if defined DEBUG_PATH
		if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) set to %d/%d",routeid,RouteInfo[routeid][rtPath],RouteInfo[routeid][rtPosition],PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1);
	#endif
}
/**
	<summary>Makes the entity go a specific given position from the position he is currently at.</summary>
	<param name="routeid">Route ID.</param>
	<param name="pos">The position index to move to, or -1 to make him move to his current defined position index.</param>
*/
@f(_,route.Go(routeid,pos=-1))
{
	if(pos == -1) pos = RouteInfo[routeid][rtPosition];
	RouteInfo[routeid][rtNextPosition] = pos;
	new Float:x = PathInfo[RouteInfo[routeid][rtPath]][pathX][pos],
		Float:y = PathInfo[RouteInfo[routeid][rtPath]][pathY][pos],
		Float:z = PathInfo[RouteInfo[routeid][rtPath]][pathZ][pos] + 0.4;
	if(PathInfo[RouteInfo[routeid][rtPath]][pathXON][pos] != 0.0 || PathInfo[RouteInfo[routeid][rtPath]][pathXOM][pos] != 0.0) x += math_frandom(PathInfo[RouteInfo[routeid][rtPath]][pathXON][pos],PathInfo[RouteInfo[routeid][rtPath]][pathXOM][pos]);
	if(PathInfo[RouteInfo[routeid][rtPath]][pathYON][pos] != 0.0 || PathInfo[RouteInfo[routeid][rtPath]][pathYOM][pos] != 0.0) x += math_frandom(PathInfo[RouteInfo[routeid][rtPath]][pathYON][pos],PathInfo[RouteInfo[routeid][rtPath]][pathYOM][pos]);
	switch(RouteInfo[routeid][rtOwnerType])
	{
		case routeowner_npc: npc_Move(RouteInfo[routeid][rtOwner],RouteInfo[routeid][rtParam],x,y,z);
		case routeowner_object: object_Move(RouteInfo[routeid][rtOwner],x,y,z,float(RouteInfo[routeid][rtParam]));
	}
	#if defined DEBUG_PATH
		if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) going to %d/%d",routeid,RouteInfo[routeid][rtPath],RouteInfo[routeid][rtPosition],PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1);
	#endif
}
/**
	<summary>Checks if the route owner entity is at the end of his current position index route (close to the start of the next position).</summary>
	<param name="routeid">Route ID.</param>
	<returns>True if it's close or at the end of his point or if there is no defined next position, false otherwise.</returns>
*/
@f(bool,route.CheckFinishPos(routeid))
{
	if(RouteInfo[routeid][rtNextPosition] == -1) return true;
	new Float:x, Float:y, Float:z;
	switch(RouteInfo[routeid][rtOwnerType])
	{
		case routeowner_npc: npc_GetPosition(RouteInfo[routeid][rtOwner],x,y,z);
		case routeowner_object: object_GetPos(RouteInfo[routeid][rtOwner],x,y,z);
	}
	return math_distance_3d(x,y,z,PathInfo[RouteInfo[routeid][rtPath]][pathX][RouteInfo[routeid][rtNextPosition]],PathInfo[RouteInfo[routeid][rtPath]][pathY][RouteInfo[routeid][rtNextPosition]],PathInfo[RouteInfo[routeid][rtPath]][pathZ][RouteInfo[routeid][rtNextPosition]]) <3; // I like this system!
}
/**
	<summary>Checks if the route current position is the finishing point of the path.</summary>
	<param name="routeid">Route ID.</param>
	<param name="checkpos">Use 'true' if you want to check if the entity can also be found at the finishing position.</param>
	<returns>True if the current position is the finishing point or false otherwise.</returns>
	<remarks>This function only checks if the current defined position index variable of the route is at the finishing point.
	Not to be confused with route_CheckFinishPos(): this function doesn't check if the owner entity is actually in the finishing position, unless 'checkpos' is used.</remarks>
*/
@f(bool,route.IsFinishPoint(routeid,bool:checkpos=false))
{
	new fp = path_GetFinishPoint(RouteInfo[routeid][rtPath],RouteInfo[routeid][rtMoveType]);
	return ((fp != -1 && RouteInfo[routeid][rtPosition] == fp) || route_IsEndPoint(routeid)) && (!checkpos || (checkpos && route_CheckFinishPos(routeid)));
}
/**
	<summary>Checks if the current route is based on an endpoint type path (respawn after any position move).</summary>
	<param name="routeid">Route ID.</param>
	<returns>Boolean value based on the mentioned condition.</returns>
*/
@f(bool,route.IsEndPoint(routeid)) return PathInfo[RouteInfo[routeid][rtPosition]][pathType] == e_PathType:path_endpoint;
/**
	<summary>Ends or restarts (loop) the route.</summary>
	<param name="routeid">Route ID.</param>
	<param name="endlooping">Use 'true' to also end the route if looping.</param>
*/
@f(_,route.End(routeid,bool:endlooping = true))
{
	if(!endlooping && RouteInfo[routeid][rtLooping])
	{
		#if defined DEBUG_PATH
			if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) looping",routeid,RouteInfo[routeid][rtPath]);
		#endif
		RouteInfo[routeid][rtPosition] = path_GetStartPoint(RouteInfo[routeid][rtPath]), RouteInfo[routeid][rtPositionParam] = 0;
		route_Set(routeid); // Go back to the start!
	}
	else
	{
		#if defined DEBUG_PATH
			if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) ended",routeid,RouteInfo[routeid][rtPath]);
		#endif
		RouteInfo[routeid][rtValid] = false;
		property_IntRemove(f("routeid-%d-%d",RouteInfo[routeid][rtOwner],_:RouteInfo[routeid][rtOwnerType]));
		RouteInfo[routeid][rtOwner] = 0;
		RouteInfo[routeid][rtOwnerType] = routeowner_none;
	}
}
/**
	<summary>Declares finishing the current route position. Calls OnPathRouteCompleted() and checks if the position was the last of the path. If so, the route is ending, otherwise the entity continues in his path.</summary>
	<param name="routeid">Route ID.</param>
	<param name="checkfinish">Use 'true' to check if the entity can actually be found at the end of the position route.</param>
	<remarks>The function won't continue or end the route if OnPathRouteCompleted() returned 0.</remarks>
*/
@f(_,route.FinishPos(routeid,bool:checkfinish))
{
	if(checkfinish) if(!route_CheckFinishPos(routeid)) return;
	if(OnPathRouteCompleted(RouteInfo[routeid][rtPath],routeid,RouteInfo[routeid][rtPosition]))
	{
		#if defined DEBUG_PATH
			if(RouteInfo[routeid][rtMoveType] != e_RouteMoveType:routemove_random) printf("Route %d(p%d) finished pos %d/%d",routeid,RouteInfo[routeid][rtPath],RouteInfo[routeid][rtPosition],PathInfo[RouteInfo[routeid][rtPath]][pathCount]-1);
		#endif
		if(route_IsFinishPoint(routeid)) route_End(routeid,false);
		else route_Continue(routeid);
	}
}
