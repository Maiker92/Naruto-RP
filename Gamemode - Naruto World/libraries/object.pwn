@f(_,object.Create(modelid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz,interior=0,world=0,playerid=-1))
{
	if(object_IsForbidden(modelid)) return -1;
	new Float:showdis = modelid < 10000 ? OBJECT_STREAM_DISTANCE_S : OBJECT_STREAM_DISTANCE_L,
		oid = CreateDynamicObject(modelid,x + objectOffsets[0],y + objectOffsets[1],z + objectOffsets[2],objectOffsets[3] == -999.0 ? rx : objectOffsets[3],objectOffsets[4] == -999.0 ? ry : objectOffsets[4],objectOffsets[5] == -999.0 ? rz : objectOffsets[5],world,interior,playerid,showdis);
	if(oid == -1) return -1;
	ElementArrayAdd(object,ObjectInfo[oid][oArrayPos],oid);
	ObjectInfo[oid][oModel] = modelid;
	ObjectInfo[oid][oValid] = true;
	ObjectInfo[oid][oPos][0] = x + objectOffsets[0];
	ObjectInfo[oid][oPos][1] = y + objectOffsets[1];
	ObjectInfo[oid][oPos][2] = z + objectOffsets[2];
	ObjectInfo[oid][oRot][0] = rx;
	ObjectInfo[oid][oRot][1] = ry;
	ObjectInfo[oid][oRot][2] = rz;
	ObjectInfo[oid][oSPos][0] = x + objectOffsets[0];
	ObjectInfo[oid][oSPos][1] = y + objectOffsets[1];
	ObjectInfo[oid][oSPos][2] = z + objectOffsets[2];
	ObjectInfo[oid][oSRot][0] = objectOffsets[3] == -999.0 ? rx : objectOffsets[3];
	ObjectInfo[oid][oSRot][1] = objectOffsets[4] == -999.0 ? ry : objectOffsets[4];
	ObjectInfo[oid][oSRot][2] = objectOffsets[5] == -999.0 ? rz : objectOffsets[5];
	ObjectInfo[oid][oInteriors][0] = interior;
	ObjectInfo[oid][oWorlds][0] = world;
	ObjectInfo[oid][oStreamDistance] = showdis;
	ObjectInfo[oid][oMap] = {INVALID_MAP,0};
	ObjectInfo[oid][oSID] = -1;
	ObjectInfo[oid][oSArea] = INVALID_AREA;
	ObjectInfo[oid][oSPlayers] = 0;
	for(new i = 0; i < MAX_SOBJECT_SEATS; i++) ObjectInfo[oid][oSPlayer][i] = INVALID_PLAYER_ID;
	return oid;
}
@f(_,object.Destroy(oid))
{
	ElementArrayDel(object,ObjectInfo[oid][oArrayPos],INVALID_STREAMED_OBJECT);
	ObjectInfo[oid][oModel] = -1;
	ObjectInfo[oid][oValid] = false;
	for(new i = 0; i < 3; i++) ObjectInfo[oid][oPos][i] = 0.0, ObjectInfo[oid][oRot][i] = 0.0, ObjectInfo[oid][oSPos][i] = 0.0, ObjectInfo[oid][oSRot][i] = 0.0;
	ObjectInfo[oid][oInteriors] = 0;
	ObjectInfo[oid][oWorlds] = 0;
	ObjectInfo[oid][oStreamDistance] = 0;
	DestroyDynamicObject(oid);
}
@f(_,object.Count()) return CountDynamicObjects();
@f(_,object.IsValid(oid)) return oid >= 0 && oid <= MAX_STREAMED_OBJECTS && ObjectInfo[oid][oValid] && IsValidDynamicObject(oid);
@f(_,object.Move(oid,Float:x,Float:y,Float:z,Float:s,Float:rx = -1000.0,Float:ry = -1000.0,Float:rz = -1000.0))
{
	StopDynamicObject(oid);
	MoveDynamicObject(oid,ObjectInfo[oid][oPos][0] = x,ObjectInfo[oid][oPos][1] = y,ObjectInfo[oid][oPos][2] = z,s,rx,ry,rz);
}
@f(_,object.Stop(oid)) StopDynamicObject(oid);
@f(_,object.IsMoving(oid)) return IsDynamicObjectMoving(oid);
@f(_,object.GetPos(oid,&Float:x,&Float:y,&Float:z)) GetDynamicObjectPos(oid,x,y,z);
@f(_,object.SetPos(oid,Float:x,Float:y,Float:z)) SetDynamicObjectPos(oid,ObjectInfo[oid][oPos][0] = x,ObjectInfo[oid][oPos][1] = y,ObjectInfo[oid][oPos][2] = z);
@f(_,object.GetRot(oid,&Float:x,&Float:y,&Float:z)) GetDynamicObjectRot(oid,ObjectInfo[oid][oRot][0] = x,ObjectInfo[oid][oRot][1] = y,ObjectInfo[oid][oRot][2] = z);
@f(_,object.SetRot(oid,Float:x,Float:y,Float:z)) SetDynamicObjectRot(oid,ObjectInfo[oid][oRot][0] = x,ObjectInfo[oid][oRot][1] = y,ObjectInfo[oid][oRot][2] = z);
@f(_,object.SetOffset(Float:x,Float:y,Float:z)) objectOffsets[0] = x, objectOffsets[1] = y, objectOffsets[2] = z;
@f(_,object.SetROffset(Float:x,Float:y,Float:z)) objectOffsets[3] = x, objectOffsets[4] = y, objectOffsets[5] = z;
@f(_,object.ResetOffset()) objectOffsets[0] = 0.0, objectOffsets[1] = 0.0, objectOffsets[2] = 0.0, objectOffsets[3] = -999.0, objectOffsets[4] = -999.0, objectOffsets[5] = -999.0;
@f(_,object.GetModel(oid)) return ObjectInfo[oid][oModel];
@f(_,object.SetModel(oid,newmodel))
{
	DestroyDynamicObject(oid);
	CreateDynamicObject(ObjectInfo[oid][oModel] = newmodel,ObjectInfo[oid][oPos][0],ObjectInfo[oid][oPos][1],ObjectInfo[oid][oPos][2],ObjectInfo[oid][oRot][0],ObjectInfo[oid][oRot][1],ObjectInfo[oid][oRot][2],ObjectInfo[oid][oWorld],ObjectInfo[oid][oInterior],-1,ObjectInfo[oid][oStreamDistance]);
}
@f(bool,object.IsForbidden(modelid))
{
	new crashingIDs[] = {18964,18986}; // 18964 = gate
	for(new i = 0; i < sizeof(crashingIDs); i++) if(modelid == crashingIDs[i]) return true;
	return false;
}
@f(_,object.Colorize(oid,color)) for(new i = 0, c = color_RGBA2ARGB(color); i < 5; i++) SetDynamicObjectMaterial(oid,i,-1,"none","none",c);
/* Incognito's Streamer:
native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 300.0);
native DestroyDynamicObject(objectid);
native IsValidDynamicObject(objectid);
native SetDynamicObjectPos(objectid, Float:x, Float:y, Float:z);
native GetDynamicObjectPos(objectid, &Float:x, &Float:y, &Float:z);
native SetDynamicObjectRot(objectid, Float:rx, Float:ry, Float:rz);
native GetDynamicObjectRot(objectid, &Float:rx, &Float:ry, &Float:rz);
native MoveDynamicObject(objectid, Float:x, Float:y, Float:z, Float:speed, Float:rx = -1000.0, Float:ry = -1000.0, Float:rz = -1000.0);
native StopDynamicObject(objectid);
native IsDynamicObjectMoving(objectid);
native AttachCameraToDynamicObject(playerid, objectid);
native AttachDynamicObjectToVehicle(objectid, vehicleid, Float:offsetx, Float:offsety, Float:offsetz, Float:rx, Float:ry, Float:rz);
native EditDynamicObject(playerid, objectid);
native GetDynamicObjectMaterial(objectid, materialindex, &modelid, txdname[], texturename[], &materialcolor, maxtxdname = sizeof txdname, maxtexturename = sizeof texturename);
native SetDynamicObjectMaterial(objectid, materialindex, modelid, const txdname[], const texturename[], materialcolor = 0);
native GetDynamicObjectMaterialText(objectid, materialindex, text[], &materialsize, fontface[], &fontsize, &bold, &fontcolor, &backcolor, &textalignment, maxtext = sizeof text, maxfontface = sizeof fontface);
native SetDynamicObjectMaterialText(objectid, materialindex, const text[], materialsize = OBJECT_MATERIAL_SIZE_256x128, const fontface[] = "Arial", fontsize = 24, bold = 1, fontcolor = 0xFFFFFFFF, backcolor = 0, textalignment = 0);
native DestroyAllDynamicObjects();
native CountDynamicObjects(); */
