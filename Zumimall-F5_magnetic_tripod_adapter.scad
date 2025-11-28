include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

mountArcWidth = 22.2;
mountArcDepth = 5;

// https://www.mathopenref.com/arcradius.html
// The formula for the radius is:
// r = h/2 + w^2/8h
//
// where:
// W  is the length of the chord defining the base of the arc
// H  is the height measured at the midpoint of the arc's base.
mountArcRadius = mountArcDepth/2 + (mountArcWidth*mountArcWidth)/(8*mountArcDepth); //14.6;
echo(str("mountArcRadius = ", mountArcRadius));


module itemModule()
{
	
}

module clip(d=0)
{
	//tcu([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
