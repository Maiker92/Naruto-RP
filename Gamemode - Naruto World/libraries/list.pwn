@f(_,list.Create())
{
	new id = INVALID_LIST_ID;
	for(new i = 0; i < MAX_LISTS && id == INVALID_LIST_ID; i++) if(!ListInfo[i][listValid]) id = i;
	if(id != INVALID_LIST_ID)
	{
		ListInfo[id][listValid] = true;
		ListInfo[id][listCount] = 0;
		for(new i = 0; i < MAX_LIST_ITEMS; i++) ListInfo[id][listItems][i] = 0, ListInfo[id][listItemSet][i] = false;
	}
	return id;
}
@f(_,list.Clear(id))
{
	assert ListInfo[id][listValid];
	for(new i = 0; i < MAX_LIST_ITEMS; i++) ListInfo[id][listItems][i] = 0, ListInfo[id][listItemSet][i] = false;
	ListInfo[id][listCount] = 0;
}
@f(_,list.Add(id,value))
{
	assert ListInfo[id][listValid] && ListInfo[id][listCount] < MAX_LIST_ITEMS;
	ListInfo[id][listItemSet][ListInfo[id][listCount]] = true, ListInfo[id][listItems][ListInfo[id][listCount]] = value, ListInfo[id][listCount]++;
	return ListInfo[id][listCount] - 1;
}
@f(_,list.AddRange(id,...))
{
	assert ListInfo[id][listValid] && ListInfo[id][listCount] < MAX_LIST_ITEMS;
	for(new i = 1, m = numargs(); i < m; i++) list_Add(id,getarg(i));
}
@f(_,list.Remove(id,itemid))
{
	assert ListInfo[id][listValid] && itemid >= 0 && itemid < ListInfo[id][listCount];
	if(itemid < ListInfo[id][listCount]-1) for(new i = itemid; i < ListInfo[id][listCount] - 1; i++) ListInfo[id][listItems][i] = ListInfo[id][listItems][i + 1];
	ListInfo[id][listCount]--, ListInfo[id][listItems][ListInfo[id][listCount]] = 0, ListInfo[id][listItemSet][ListInfo[id][listCount]] = false;
}
@f(_,list.Count(id)) return ListInfo[id][listCount];
@f(_,list.Set(id,itemid,value))
{
	assert ListInfo[id][listValid] && itemid >= 0 && itemid < ListInfo[id][listCount] && ListInfo[id][listItemSet][itemid];
	ListInfo[id][listItems][itemid] = value;
}
@f(_,list.Get(id,itemid))
{
	assert ListInfo[id][listValid] && itemid >= 0 && itemid < ListInfo[id][listCount] && ListInfo[id][listItemSet][itemid];
	return ListInfo[id][listItems][itemid];
}
@f(_,list.IsValid(id)) return id >= 0 && id <= MAX_LISTS ? ListInfo[id][listValid] : false;
@f(_,list.IsItemSet(id,itemid))
{
	assert ListInfo[id][listValid] && itemid >= 0 && itemid < ListInfo[id][listCount];
	return ListInfo[id][listItemSet][itemid];
}
@f(_,list.CountValue(id,value))
{
	assert ListInfo[id][listValid];
	new c = 0;
	for(new i = 0; i < ListInfo[id][listCount]; i++) if(ListInfo[id][listItems][i] == value) c++;
	return c;
}
@f(_,list.RemoveValue(id,value,bool=true))
{
	assert ListInfo[id][listValid];
	for(new i = 0; i < ListInfo[id][listCount]; i++) if(ListInfo[id][listItems][i] == value)
	{
		list_Remove(id,i);
		if(bool) break;
	}
}
