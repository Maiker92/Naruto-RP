@f(_,color.SetRed(hexColor,r)) return (hexColor & 0x00ffffff) | (math_bonds(r,0,255) << 24);
@f(_,color.SetGreen(hexColor,g)) return (hexColor & 0xff00ffff) | (math_bonds(g,0,255) << 16);
@f(_,color.SetBlue(hexColor,b)) return (hexColor & 0xffff00ff) | (math_bonds(b,0,255) << 8);
@f(_,color.SetAlpha(hexColor,alpha)) return (hexColor & 0xffffff00) | math_bonds(alpha,0,255);
@f(_,color.GetRed(hexColor)) return (hexColor >> 24) & 0x000000ff;
@f(_,color.GetGreen(hexColor)) return (hexColor >> 16) & 0x000000ff;
@f(_,color.GetBlue(hexColor)) return (hexColor >> 8) & 0x000000ff;
@f(_,color.GetAlpha(hexColor)) return hexColor & 0x000000ff;
@f(_,color.IsGrey(hexColor)) return ((hexColor >> 24) & 0x000000ff) == ((hexColor >> 16) & 0x000000ff) && ((hexColor >> 24) & 0x000000ff) == ((hexColor >> 8) & 0x000000ff) && hexColor != 0 && hexColor != -1;
@f(_,color.AddRGBA(hexColor,amountR,amountG,amountB,amountA))
{
	new ret = hexColor;
	ret = color_SetRed(ret,color_GetRed(hexColor)+amountR);
	ret = color_SetGreen(ret,color_GetGreen(hexColor)+amountG);
	ret = color_SetBlue(ret,color_GetBlue(hexColor)+amountB);
	ret = color_SetAlpha(ret,color_GetAlpha(hexColor)+amountA);
	return ret;
}
@f(_,color.SetShade(absoluteColor,shadeLevel))
{
	if(!shadeLevel) return absoluteColor;
	new hexColor = absoluteColor, s = 0;
	s = math_bonds(shadeLevel,color_IsGrey(absoluteColor) ? -128 : -255,color_IsGrey(absoluteColor) ? 128 : 255);
	hexColor = color_AddRGBA(hexColor,s,s,s,0);
	return hexColor;
}
@f(_,color.rgba2hex(r,g,b,a)) return (r * 16777216) + (g * 65536) + (b * 256) + a;
@f(_,color.hex2rgba(hex,&r,&g,&b,&a)) r = (hexColor >> 24) & 0x000000ff, g = (hexColor >> 16) & 0x000000ff, b = (hexColor >> 8) & 0x000000ff, a = hexColor & 0x000000ff;
@f(_,color.ToString(c))
{
	new hexcolor[8];
	format(hexcolor,sizeof(hexcolor),"%s%s%s",convert_num2hexstr(color_GetRed(c)),convert_num2hexstr(color_GetGreen(c)),convert_num2hexstr(color_GetBlue(c)));
	return hexcolor;
}
@f(_,color.RGBA2ARGB(rgba)) return rgba >>> 8 | rgba << 24;
