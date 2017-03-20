@f(_,property.IntExist(name[])) return existproperty(.name=name);
@f(_,property.IntGet(name[])) return getproperty(.name=name);
@f(_,property.IntSet(name[],value))
{
	new flag = -1, bool:ex = bool:property_IntExist(name);
	for(new i = 0; i < MAX_GPROPERTIES && flag == -1; i++) if((ex && equal(GPropertyInfo[i][gpName],name)) || (!ex && !GPropertyInfo[i][gpValid])) flag = i;
	GPropertyInfo[flag][gpValid] = true;
	GPropertyInfo[flag][gpType] = gptype_int;
	format(GPropertyInfo[flag][gpName],64,name);
	valstr(GPropertyInfo[flag][gpValue],value);
	return setproperty(.name=name,.value=value);
}
@f(_,property.IntRemove(name[]))
{
	if(!property_IntExist(name)) return 1;
	new flag = -1;
	for(new i = 0; i < MAX_GPROPERTIES && flag == -1; i++) if(equal(GPropertyInfo[i][gpName],name)) flag = i;
	GPropertyInfo[flag][gpValid] = false;
	format(GPropertyInfo[flag][gpName],64,"");
	format(GPropertyInfo[flag][gpValue],64,"");
	GPropertyInfo[flag][gpType] = gptype_null;
	return deleteproperty(.name=name);
}
@f(_,property.StrExist(name[])) return existproperty(.value=encrypt_Property(name));
@f(_,property.StrGet(name[]))
{
	new getAs[M_S];
	getproperty(.value=encrypt_Property(name),.string=getAs);
	strunpack(getAs,getAs,sizeof(getAs));
	return getAs;
}
@f(_,property.StrSet(name[],value[]))
{
	new flag = -1, bool:ex = bool:property_StrExist(name);
	for(new i = 0; i < MAX_GPROPERTIES && flag == -1; i++) if((ex && equal(GPropertyInfo[i][gpName],name)) || (!ex && !GPropertyInfo[i][gpValid])) flag = i;
	GPropertyInfo[flag][gpValid] = true;
	GPropertyInfo[flag][gpType] = gptype_str;
	format(GPropertyInfo[flag][gpName],64,name);
	format(GPropertyInfo[flag][gpValue],64,value);
	return setproperty(.value=encrypt_Property(name),.string=value);
}
@f(_,property.StrRemove(name[]))
{
	if(!property_StrExist(name)) return 1;
	new flag = -1;
	for(new i = 0; i < MAX_GPROPERTIES && flag == -1; i++) if(equal(GPropertyInfo[i][gpName],name)) flag = i;
	GPropertyInfo[flag][gpValid] = false;
	format(GPropertyInfo[flag][gpName],64,"");
	format(GPropertyInfo[flag][gpValue],64,"");
	GPropertyInfo[flag][gpType] = gptype_null;
	return deleteproperty(.value=encrypt_Property(name));
}
@f(_,property.Refresh())
{
	for(new i = 0; i < MAX_GPROPERTIES; i++) if(GPropertyInfo[i][gpValid]) switch(GPropertyInfo[i][gpType])
	{
		case gptype_int: setproperty(.name=GPropertyInfo[i][gpName],.value=strval(GPropertyInfo[i][gpValue]));
		case gptype_str: setproperty(.value=encrypt_Property(GPropertyInfo[i][gpName]),.string=GPropertyInfo[i][gpValue]);
	}
	return 1;
}
