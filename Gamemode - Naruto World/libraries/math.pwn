@f(_,math.bonds(value,mini,maxi)) return max(mini,min(maxi,value));
@f(_,math.distance_3d(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2)) return floatround(floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2)));
@f(_,math.distance_2d(Float:x1,Float:y1,Float:x2,Float:y2)) return floatround(floatabs(floatsqroot(floatpower(floatabs(floatsub(x1,x2)),2)+floatpower(floatabs(floatsub(y1,y2)),2))));
@f(Float,math.max(Float:n1,Float:n2)) return n1 > n2 ? n1 : n2;
@f(Float,math.min(Float:n1,Float:n2)) return n1 < n2 ? n1 : n2;
@f(Float,math.percent(Float:value,Float:max,Float:percmax=100.0)) return floatmul(math_safefloatdiv(value,max),percmax);
@f(_,math.random(from,to)) return random(to-from)+from;
@f(Float,math.frandom(Float:from,Float:to))
{
	new Float:mul = floatpower(10.0,4.0), imin = floatround(from * mul), imax = floatround(to * mul);
	return float(random(imax - imin) + imin) / mul;
}
@f(Float,math.facepoint(Float:fromx,Float:fromy,Float:tox,Float:toy))
{
	new Float:angle = 0.0;
	angle = floatabs(atan((toy-fromy)/(tox-fromx)));
	if(tox <= fromx && toy >= fromy) angle = floatsub(180.0,angle);
	else if(tox < fromx && toy < fromy) angle = floatadd(angle,180.0);
	else if(tox >= fromx && toy <= fromy) angle = floatsub(360.0,angle);
	angle = floatsub(angle,90.0);
	if(angle >= 360.0) angle = floatsub(angle,360.0);
	return angle;
}
@f(Float,math.safefloatdiv(Float:dividend,Float:divisor)) return dividend == 0.0 || divisor == 0.0 ? 0.0 : floatdiv(dividend,divisor);
@f(_,math.xyinfront(&Float:x,&Float:y,Float:angle,Float:distance,Float:offset=0.0)) x += (distance * floatsin(-angle + offset,degrees)), y += (distance * floatcos(-angle + offset,degrees));
@f(_,math.xyinrear(&Float:x,&Float:y,Float:angle,Float:distance)) x -= (distance * floatsin(-angle,degrees)), y -= (distance * floatcos(-angle,degrees));
@f(_,math.xyinleft(&Float:x,&Float:y,Float:angle,Float:distance)) math_xyinfront(x,y,angle,distance,270.0);
@f(_,math.xyinright(&Float:x,&Float:y,Float:angle,Float:distance)) math_xyinfront(x,y,angle,distance,90.0);
