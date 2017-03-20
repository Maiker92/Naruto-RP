// Anime Fantasy: Naruto World #11 script: map
#define function<%1> forward map_%1; public map_%1
static loadingMap = INVALID_MAP, maxObjectsPerModel = 0;
function<OnGameModeInit()>
{
	// Player map markers
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	LimitPlayerMarkerRadius(GetServerVarAsInt("stream_distance"));
	// Object offsets
	object_ResetOffset();
	object_SetOffset(0.0,WORLD_Y_OFFSET,0.0);
	object_SetROffset(-999.0,-999.0,-999.0);
	// Load maps
	map_Load(0,"amigakre");
	map_Load(1,"basicmap");
	map_Load(2,"danzo");
	map_Load(3,"derevniarisovihpolei");
	map_Load(4,"dopolnenie");
	map_Load(5,"grup");
	map_Load(6,"kamen");
	map_Load(7,"konohamelochi");
	map_Load(8,"madaramap");
	map_Load(9,"obloco");
	map_Load(10,"okraina");
	map_Load(11,"pustinia");
	map_Load(12,"puti");
	map_Load(13,"shinobi");
	map_Load(14,"svsd");
	map_Load(15,"svsi");
	map_Load(16,"tuman");
	map_Load(17,"tumanosnovnoi");
	// Create special objects
	map_CreateObject(899,-1024.45886,-1081.92908,9.37980,120.00000,-98.00000,273.00000); // Akatsuki Stone
	// Reset dat offset again
	object_ResetOffset();
	// Object info
	printf("Total objects: %d / Total object models: %d / Max objects per model: %d)",CountDynamicObjects(),omodelUpper,maxObjectsPerModel);
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	map_KillGTASA(playerid);
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	Streamer_ToggleItemUpdate(playerid,STREAMER_TYPE_OBJECT,1);
	Streamer_ToggleIdleUpdate(playerid,1);
	return 1;
}
function<OnPlayerClickMap(playerid,Float:fX,Float:fY,Float:fZ)>
{
	if(admin_IsAdmin(playerid)) player_SetPosition(playerid,fX,fY+WORLD_Y_OFFSET,fZ+50.0);
	return 1;
}
#undef function
// Map
@f(_,map.Exist(mapid)) return mapid >= 0 && mapid < MAX_MAPS && MapInfo[mapid][mapValid];
@f(_,map.Load(mapid,filename[]))
{
	MapInfo[mapid][mapName][0] = EOS;
	MapInfo[mapid][mapAuthor][0] = EOS;
	format(MapInfo[mapid][mapFile],64,DIR_MAPS "/%s.map",filename);
	if(fexist(MapInfo[mapid][mapFile]))
	{
		loadingMap = mapid;
		new File:fh = fopen(MapInfo[mapid][mapFile],io_read), read[M_S];
		if(fh)
		{
			MapInfo[mapid][mapValid] = true;
			while(fread(fh,read))
			{
				if(read[0] == '#') continue;
				if(strfind(read,"=") != -1)
				{
					idx = 0;
					fsplitted[0] = str_tok(read,idx,'='), fsplitted[1] = str_rest(read,idx,'=');
					if(equal(fsplitted[0],"disable")) MapInfo[mapid][mapValid] = strval(fsplitted[1]) != 1;
					else if(equal(fsplitted[0],"name")) format(MapInfo[mapid][mapName],MAX_NAME_LENGTH,fsplitted[1]);
					else if(equal(fsplitted[0],"author")) format(MapInfo[mapid][mapAuthor],MAX_NAME_LENGTH,fsplitted[1]);
				}
				else if(strlen(read) > 20)
				{
					if(!MapInfo[mapid][mapValid]) continue;
					str_split(read,fsplitted,',');
					map_CreateObject(strval(fsplitted[0]),floatstr(fsplitted[1]),floatstr(fsplitted[2]),floatstr(fsplitted[3]),floatstr(fsplitted[4]),floatstr(fsplitted[5]),floatstr(fsplitted[6]));

				}
			}
		}
		fclose(fh);
		loadingMap = INVALID_MAP;
	}
}
@f(_,map.Unload(mapid))
{
	MapInfo[mapid][mapValid] = false;
	MapInfo[mapid][mapName][0] = EOS;
	MapInfo[mapid][mapAuthor][0] = EOS;
	map_ResetObjects(mapid);
}
@f(_,map.CreateObject(modelid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz))
{
	// Create the object
	new	oid = object_Create(modelid,x,y,z,rx,ry,rz),
		Float:showdis = modelid < 10000 ? OBJECT_STREAM_DISTANCE_S : OBJECT_STREAM_DISTANCE_L,
		worlds[OBJECT_MAX_VIRTUAL_WORLDS] = {VW_WORLD,VW_LOGIN,VW_MOVIE,VW_INTRO},
		interiors[OBJECT_MAX_INTERIORS] = {-1};
	if(oid == -1) return -1;
	// Make it invisible in the game
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT,oid,E_STREAMER_STREAM_DISTANCE,showdis);
	Streamer_SetFloatData(STREAMER_TYPE_OBJECT,oid,E_STREAMER_DRAW_DISTANCE,showdis*2);
	Streamer_SetArrayData(STREAMER_TYPE_OBJECT,oid,E_STREAMER_WORLD_ID,worlds);
	Streamer_SetArrayData(STREAMER_TYPE_OBJECT,oid,E_STREAMER_INTERIOR_ID,interiors);
	// Assign it to its map
	if(loadingMap != INVALID_MAP)
	{
		ObjectInfo[oid][oMap][0] = loadingMap, ObjectInfo[oid][oMap][1] = MapInfo[loadingMap][mapObjects];
		MapInfo[loadingMap][mapObject][MapInfo[loadingMap][mapObjects]++] = oid;
	}
	// Add to model ID list
	omodel_Add(oid);
	// Apply special features
	if(sobject_IsSpecial(oid)) sobject_ApplySpeciality(oid);
	return oid;
}
@f(_,map.DestroyObject(oid))
{
	object_Destroy(oid);
	for(new i = 0; i < MAX_OBJECTS_PER_MAP-1; i++) MapInfo[ObjectInfo[oid][oMap][0]][mapObject][i] = MapInfo[ObjectInfo[oid][oMap][0]][mapObject][i+1];
	MapInfo[ObjectInfo[oid][oMap][0]][mapObject][MAX_OBJECTS_PER_MAP-1] = 0, MapInfo[ObjectInfo[oid][oMap][0]][mapObjects]--;
	ObjectInfo[oid][oMap] = {INVALID_MAP,0};
}
@f(_,map.ResetObjects(mapid))
{
	for(new i = 0; i < MapInfo[mapid][mapObjects]; i++)
	{
		ObjectInfo[MapInfo[mapid][mapObject][i]][oMap] = {INVALID_MAP,0};
		object_Destroy(MapInfo[mapid][mapObject][i]);
		MapInfo[mapid][mapObject][i] = 0;
	}
	MapInfo[mapid][mapObjects] = 0;
}
@f(_,map.KillGTASA(playerid)) RemoveBuildingForPlayer(playerid,-1,0.0,0.0,0.0,10000.0);
// Object Models
@f(_,omodel.Index(modelid))
{
	new omidx[32], r = 0;
	format(omidx,sizeof(omidx),"omodel%05d",modelid);
	if(property_IntExist(omidx)) r = property_IntGet(omidx);
	else property_IntSet(omidx,r = omodelUpper++);
	return r;
}
@f(_,omodel.Add(objectid))
{
	new i = omodel_Index(ObjectInfo[objectid][oModel]);
	mobject[i][mobjects[i]++] = objectid;
	if(mobjects[i] > maxObjectsPerModel) maxObjectsPerModel = mobjects[i];
}
/*
Useful object IDs:
	18920 = gaara's mother
	18921 = garra's seal grave
	18780 = kyuubi room (part)
	18714 = kyuubi room (full)
	18924 = kyuubi
	18923 = gamabunta
	18922 = manda
	19061 = rashumon

IMPORTANT NOTES:
	Object Model Offset ID:	13632 (OBJECT_MODEL_ID_OFFSET)
	Crashing IDs:			18964 18986
	Map files have been generated from IPL files made by Bugagastic
*/
