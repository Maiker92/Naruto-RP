static tmpstr[MAX_CHAT_LENGTH];
@f(_,textline.LoadAll())
{
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_TextLines)));
	new m = sqlite_NumRows(), tlid = 0, n[32];
	for(new i = 0; i < m; i++)
	{
		format(n,sizeof(n),sqlite_GetField("tlcode"));
		tlid = textline_Index(n);
		if(!TextLinesInfo[tlid][tlValid])
		{
			TextLinesInfo[tlid][tlValid] = true;
			format(TextLinesInfo[tlid][tlCode],32,n);
			TextLinesInfo[tlid][tlCount] = 0;
			printf("Loaded Text Lines: %s",n);
		}
		textline_SetLine(n,TextLinesInfo[tlid][tlCount],sqlite_GetField("tlline"));
		TextLinesInfo[tlid][tlCount]++;
		sqlite_NextRow();
	}
	sqlite_FreeResults();
}
@f(_,textline.Index(tlcode[]))
{
	new id = -1, s[16];
	format(s,sizeof(s),"textline-%s",tlcode);
	if(property_IntExist(s)) id = property_IntGet(s);
	else
	{
		for(new i = 0; i < MAX_TEXT_LINES && id == -1; i++) if(!TextLinesInfo[i][tlValid]) id = i;
		if(id != -1) property_IntSet(s,id);
	}
	return id;
}
@f(_,textline.SetLine(tlcode[],line,text[]))
{
	f("textline-%s-%d",tlcode,line);
	property_StrSet(fstring,text);
}
@f(_,textline.GetLine(tlcode[],line))
{
	f("textline-%s-%d",tlcode,line);
	format(tmpstr,sizeof(tmpstr),property_StrGet(fstring));
	return tmpstr;
}
@f(_,textline.GetRandomLine(tlcode[]))
{
	new r = random(TextLinesInfo[textline_Index(tlcode)][tlCount]);
	format(tmpstr,sizeof(tmpstr),textline_GetLine(tlcode,r));
	return tmpstr;
}
