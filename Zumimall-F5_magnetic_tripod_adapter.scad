include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>
include <../OpenSCAD_Lib/torus.scad>

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

ballheadThreadHoleLength = 11.5;
ballheadThreadHoleDia = 6.4;
ballheadThreadStopDia = 8.5;
balheadNutThickness = 4.7;

boltHeadDia = 21.8; // Hex
boltThreadDia = max(12.65, 12.6); // 1/2" threads vs. 1/4" nut
boltHeadRecessDepth = 1.405 + (7.5 + 2.5);
boltThreadLength = 19; // 3/4"

boltRecessOffsetZ = mountArcRadius-boltHeadRecessDepth;
boltThreadsOffsetZ = -boltThreadLength+boltRecessOffsetZ;
echo(str("boltThreadsOffsetZ = ", boltThreadsOffsetZ));

extensionZ = -boltThreadsOffsetZ + ballheadThreadHoleLength;
echo(str("extensionZ = ", extensionZ));

antiRotationSupportDia = 15;

$fn=360;

module itemModule()
{
	difference()
	{
		union()
		{
			// Ball:
			tsp([0,0,0], d=mountArcRadius*2);
			// Extension:
			translate([0,0,-extensionZ]) simpleChamferedCylinder(d=mountArcRadius*2, h=extensionZ, cz=2, flip=true);
			// Sliping-down support:
			difference()
			{
				hull()
				{
					
					h1 = 42;
					h2 = 20;
					cz = 1;
					translate([0,0,h2-h1]) simpleChamferedCylinder(d=antiRotationSupportDia, h=h1, cz=cz, flip=true);
					translate([23,0,0]) simpleChamferedCylinder(d=antiRotationSupportDia, h=h2, cz=cz, flip=true);
				}
				// Trim so the final piece doesn't extend below the extension:
				tcu([-200, -200, -400-extensionZ], 400);
			}
		}

		
		bodyDia = 44;
		translate([+boltHeadDia/2, 0, bodyDia/2+10]) rotate([-90,0,0]) tcy([0,0,-50], d=bodyDia, h=100);

		// Recess for the rubber bit:
		difference()
		{
			translate([0,0,10+0.5]) hull() torus3a(outsideDiameter=26.6, circleDiameter=3.5);
			doubleY() tcu([-200, antiRotationSupportDia/2+1.94, -200], 400);
			tcu([-400, -200, -200], 400);
		}

		// Bolt threaded part:
		tcy([0,0,boltThreadsOffsetZ], d=boltThreadDia, h=200);
		// Bolt head:
		tcy([0,0,boltRecessOffsetZ], d=boltHeadDia, h=100, $fn=6);

		// Bolt to nut transition:
		hull()
		{
			tcy([0,0,boltThreadsOffsetZ], d=boltThreadDia, h=0.1);
			tcy([0,0,-extensionZ+3.7+balheadNutThickness-nothing], d=12.6, h=0.1, $fn=6);
		}

		// Ball-head threads:
		tcy([0,0,-100], d=ballheadThreadHoleDia, h=100);
		// Ball-head nut recess:
		tcy([0,0,-extensionZ+3.7], d=12.6, h=balheadNutThickness, $fn=6);
	}
}

module clip(d=0)
{
	// tcu([-200, -400-d, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
