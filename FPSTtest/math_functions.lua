local math_functions = {};
x = 0
function math_functions.packageLocation(x,y)
	local location = {};
	location.X = x;
	location.Y = y;
	return location;
end

function math_functions.getAngleTo(from,too)
	inv = 1;
	x = 1
	if too.X < from.X then
		f = too;
		t = from;
		x = -1;
	elseif too.X >= from.X then
		t = too;
		f = from;
		x = 1;
	end
	local Angle = math.atan2(((f.Y-t.Y))/((from.X-too.X)),x);
	if Angle ~= nan then
		return Angle;
	else
		return 0;
	end
end

function math_functions.getDistanceTo(from,too)
	return math.sqrt(((from.X-too.X)^2) + ((from.Y-too.Y)^2));
end

return math_functions;