include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

mountArcWidth = 22.2;
mountArcDepth = 5;

boltHeadDia = 21.8; // Hex
boltThreadDia = 12.65;
boltHeadRecessDepth = 7.5 + 2.5;

// https://www.mathopenref.com/arcradius.html
// The formula for the radius is:
// r = h/2 + w^2/8h
//
// where:
// W  is the length of the chord defining the base of the arc
// H  is the height measured at the midpoint of the arc's base.
mountArcRadius = mountArcDepth/2 + (mountArcWidth*mountArcWidth)/(8*mountArcDepth); //14.6;
echo(str("mountArcRadius = ", mountArcRadius));

$fn=360;

module itemModule()
{
	difference()
	{
		union()
		{
			tsp([0,0,0], d=mountArcRadius*2);
		}

		// Bolt threaded part:
		tcy([0,0,-100], d=boltThreadDia, h=200);
		// Bolt head:
		tcy([0,0,mountArcRadius-1.405-boltHeadRecessDepth], d=boltHeadDia, h=100, $fn=6);

		// Trim bottom:
		tcu([-200, -200, -400], 400);
	}
}

module clip(d=0)
{
	tcu([-200, -400-d, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
