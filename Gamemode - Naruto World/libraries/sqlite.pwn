#define SQLite_Query(%1,%2) sqlite_Query(%1,f(%2))
@f(DB,sqlite.Connect(dbfname[])) return db_open(dbfname);
@f(_,sqlite.Disconnect(DB:db)) db_close(db);
@f(_,sqlite.Query(DB:db,text[]))
{
	//if(dbResVar != NO_DB_RESULT) sqlite_FreeResults();
	dbResVar = db_query(db,f("%s;",text));
	dbResult[0] = EOS;
	if(db_num_rows(dbResVar) == 1) db_get_field(dbResVar,0,dbResult,sizeof(dbResult));
	//db_free_result(dbResVar);
	return dbResult;
}
/*@f(_,sqlite.Query(DB:db,text[]))
{
	//if(dbResVar != NO_DB_RESULT) sqlite_FreeResults();
	dbResVar = db_query(db,f("%s;",text));
	return 1;
}*/
@f(_,sqlite.NumRows()) return db_num_rows(dbResVar);
@f(_,sqlite.GetField(field[]))
{
	dbResult[0] = EOS;
	db_get_field_assoc(dbResVar,field,dbResult,sizeof(dbResult));
	return dbResult;
}
@f(_,sqlite.GetFieldByID(field=0))
{
	dbResult[0] = EOS;
	db_get_field(dbResVar,field,dbResult,sizeof(dbResult));
	return dbResult;
}
@f(_,sqlite.NextRow()) return db_next_row(dbResVar);
@f(_,sqlite.FreeResults())
{
	if(dbResVar != NO_DB_RESULT)
	{
		db_free_result(dbResVar);
		dbResVar = NO_DB_RESULT;
	}
}
@f(_,sqlite.SetString(DB:db,table[],id,key[],value[],idname[]="id")) return SQLite_Query(db,"UPDATE `%s` SET `%s` = '%s' WHERE `%s` = %d",sqlite_TableName(table),key,value,idname,id);
@f(_,sqlite.SetInt(DB:db,e_SQLiteTable:table,id,key[],value,idname[]="id")) return SQLite_Query(db,"UPDATE `%s` SET `%s` = %d WHERE `%s` = %d",sqlite_TableName(table),key,value,idname,id);
@f(_,sqlite.SetFloat(DB:db,e_SQLiteTable:table,id,key[],Float:value,idname[]="id")) return SQLite_Query(db,"UPDATE `%s` SET `%s` = '%.4f' WHERE `%s` = %d",sqlite_TableName(table),key,value,idname,id);
@f(_,sqlite.SetBool(DB:db,e_SQLiteTable:table,id,key[],bool:value,idname[]="id")) return SQLite_Query(db,"UPDATE `%s` SET `%s` = '%s' WHERE `%s` = %d",sqlite_TableName(table),key,_:value,idname,id);
@f(_,sqlite.GetString(DB:db,e_SQLiteTable:table,id,key[],idname[]="id"))
{
	sqlite_Query(db,f("SELECT `%s` FROM `%s` WHERE `%s` = %d",key,sqlite_TableName(table),idname,id));
	new str[M_S_DB];
	format(str,sizeof(str),sqlite_GetFieldByID());
	sqlite_FreeResults();
	return str;
}
@f(_,sqlite.GetInt(DB:db,e_SQLiteTable:table,id,key[],idname[]="id")) return strval(sqlite_GetString(db,table,id,key,idname));
@f(Float,sqlite.GetFloat(DB:db,e_SQLiteTable:table,id,key[],idname[]="id")) return floatstr(sqlite_GetString(db,sqlite_TableName(table),id,key,idname));
@f(bool,sqlite.GetBool(DB:db,e_SQLiteTable:table,id,key[],idname[]="id")) return bool:strval(sqlite_GetString(db,sqlite_TableName(table),id,key,idname));
@f(_,sqlite.Delete(DB:db,e_SQLiteTable:table,id,idname[]="id")) return SQLite_Query(db,"DELETE FROM `%s` WHERE `%s` = %d",sqlite_TableName(table),idname,id);
@f(_,sqlite.GetHighestID(DB:db,e_SQLiteTable:table,idname[]="id"))
{
	SQLite_Query(db,"SELECT `id` FROM `%s` ORDER BY `%s` DESC LIMIT 1",sqlite_TableName(table),idname);
	return dbResult[0] != EOS ? strval(dbResult) : 1;
}
@f(_,sqlite.IsExist(DB:db,e_SQLiteTable:table,id,idname[]="id"))
{
	SQLite_Query(db,"SELECT * FROM `%s` WHERE `%s` = %d",sqlite_TableName(table),idname,id);
	return dbResult[0] != EOS;
}
@f(_,sqlite.IsExistS(DB:db,e_SQLiteTable:table,s[],idname[]="id"))
{
	SQLite_Query(db,"SELECT * FROM `%s` WHERE `%s` = '%s'",sqlite_TableName(table),idname,s);
	return dbResult[0] != EOS;
}
@f(_,sqlite.Count(DB:db,e_SQLiteTable:table))
{
	SQLite_Query(db,"SELECT * FROM `%s`",key,table);
	return db_num_rows(dbResVar);
}
@f(_,sqlite.Add(DB:db,e_SQLiteTable:table,frmt[],{Float,_}:...))
{
	new n = numargs(), keys[M_S], values[M_S], got[64];
	for(new i = 3; i < n; i += 2)
	{
		GetStringArg(i,got);
		format(keys,sizeof(keys),"%s%s`%s`",keys,i == 3 ? ("") : (","),got);
		switch(frmt[(i/2)-1])
		{
			case 's':
			{
				GetStringArg(i+1,got);
				format(values,sizeof(values),"%s%s'%s'",values,i == 3 ? ("") : (","),got);
			}
			case 'i', 'd': format(values,sizeof(values),"%s%s%d",values,i == 3 ? ("") : (","),getarg(i+1));
			//case 'n': format(values,sizeof(values),"%s%snull",values,i == 3 ? ("") : (","),got);
		}
	}
	SQLite_Query(db,"INSERT INTO `%s` (%s) VALUES (%s)",sqlite_TableName(table),keys,values);
	return 1;
}
@f(_,sqlite.AddString(DB:db,e_SQLiteTable:table,key[],value[])) return SQLite_Query(db,"INSERT INTO `%s` (`%s`) VALUES ('%s')",sqlite_TableName(table),key,value);
@f(_,sqlite.AddInt(DB:db,e_SQLiteTable:table,key[],value)) return SQLite_Query(db,"INSERT INTO `%s` (`%s`) VALUES (%d)",sqlite_TableName(table),key,value);
@f(_,sqlite.AddFloat(DB:db,e_SQLiteTable:table,key[],Float:value)) return SQLite_Query(db,"INSERT INTO `%s` (`%s`) VALUES ('%.4f')",sqlite_TableName(table),key,value);
@f(_,sqlite.AddBool(DB:db,e_SQLiteTable:table,key[],bool:value)) return SQLite_Query(db,"INSERT INTO `%s` (`%s`) VALUES (%d)",sqlite_TableName(table),key,_:value);
@f(_,sqlite.FindID(DB:db,e_SQLiteTable:table,key[],value[]))
{
	SQLite_Query(db,"SELECT `id` FROM `%s` WHERE `%s` = '%s'",sqlite_TableName(table),key,value);
	return db_num_rows(dbResVar) > 0 ? strval(dbResult) : 0;
	//new ret = db_num_rows(dbResVar) > 0 ? strval(dbResult) : 0;
	//db_free_result(dbResVar);
	//return ret;
}
@f(_,sqlite.TableName(e_SQLiteTable:table))
{
	new ret[32];
	switch(table)
	{
		// game
		case st_Characters: ret = "characters";
		case st_OwnCharacters: ret = "owncharacters";
		case st_Summonings: ret = "summonings";
		case st_Teams: ret = "teams";
		case st_Sounds: ret = "sounds";
		case st_Powers: ret = "powers";
		case st_Places: ret = "places";
		case st_Items: ret = "items";
		case st_NPCs: ret = "npcs";
		case st_Missions: ret = "missions";
		case st_Events: ret = "events";
		case st_Jinchuuriki: ret = "jinchuuriki";
		case st_Factions: ret = "factions";
		case st_Auras: ret = "auras";
		case st_Behaviors: ret = "behaviors";
		case st_Elements: ret = "elements";
		case st_Pickups: ret = "pickups";
		case st_Spawns: ret = "spawns";
		case st_Intros: ret = "intros";
		case st_Paths: ret = "paths";
		case st_TextLines: ret = "textlines";
		// server
		case st_Accounts: ret = "accounts";
		case st_Players: ret = "players";
		case st_Admins: ret = "admins";
		case st_AdminCommands: ret = "admincmds";
		case st_Permissions: ret = "perms";
		// hybrid
		case st_Settings: ret = "settings";
	}
	return ret;
}
