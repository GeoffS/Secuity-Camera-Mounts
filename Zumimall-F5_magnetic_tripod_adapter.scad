// Copyright 2025 - Geoff SObering - All Rights Reserved
// Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3

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
ballheadThreadHoleDia = 6.5;
ballheadThreadStopDia = 8.6;
ballheadNutThickness = 4.7;
ballheadNutRecessDia = 13;

boltHeadDia = 22.5; // Hex
boltThreadDia = 12.65;
boltHeadRecessDepth = 1.405 + (7.5 + 2.5);
boltThreadLength = 19; // 3/4"

boltRecessOffsetZ = mountArcRadius-boltHeadRecessDepth;
boltThreadsOffsetZ = -boltThreadLength+boltRecessOffsetZ;
echo(str("boltThreadsOffsetZ = ", boltThreadsOffsetZ));

extensionZ = -boltThreadsOffsetZ + ballheadNutThickness + 2;
echo(str("extensionZ = ", extensionZ));

antiRotationSupportDia = 15;

ringOutsideDiameter = 33;
ringCircleDiameter = 6;
ringTorusOffsetZ = 7.5 + ringCircleDiameter/2;

ballheadMountOffsetX = 30;
ballheadMountOffsetZ = -extensionZ + 12;

ballheadMountDia = ballheadNutRecessDia + 6;
ballheadMountZ = 10;

// $fn=360;

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

			// Ball-head mount:
			difference()
			{
				hull()
				{

					translate([-ballheadMountOffsetX, 0, ballheadMountOffsetZ]) simpleChamferedCylinderDoubleEnded(d=ballheadMountDia, h=-ballheadMountOffsetZ, cz=2);
					centerOffsetZ = -extensionZ-0.53; // 0.5 smallest w/o overhangs
					translate([0, 0, centerOffsetZ]) simpleChamferedCylinderDoubleEnded(d=ballheadMountDia+8.9, h=-centerOffsetZ, cz=2);
				}
				// Trim so the final piece doesn't extend below the extension:
				tcu([-200, -200, -extensionZ-400], 400);
			}

			// Bottom support:
			difference()
			{
				hull()
				{
					h1 = 38;
					h2 = 20;
					cz = 1;
					translate([0,0,h2-h1]) simpleChamferedCylinder(d=antiRotationSupportDia, h=h1, cz=cz, flip=true);
					translate([23,0,0]) simpleChamferedCylinder(d=antiRotationSupportDia, h=h2, cz=cz, flip=true);
				}
				// Trim so the final piece doesn't extend below the extension:
				tcu([-200, -200, -400-extensionZ], 400);
			}
			
			// Side support:
			difference()
			{
				sideOffsetY = 26.5;
				d = 20;
				cz = 2;
				h1 = 62;
				h2 = 42;

				doubleY() hull()
				{
					translate([0,0,h2-h1]) simpleChamferedCylinderDoubleEnded(d=d, h=h1, cz=cz);
					translate([0,sideOffsetY+1,0]) simpleChamferedCylinderDoubleEnded(d=d, h=h2, cz=cz);
				}

				// Trim to the side:
				chamferDia = 10;
				z1 = 7.5;
				z2 = 40;
				yo2 = sideOffsetY + 0.3;
				hull()
				{
					doubleY() sideSupportCylinder(d=chamferDia, x=d/2, y=sideOffsetY, z=z1);
					doubleY() sideSupportCylinder(d=chamferDia, x=d/2, y=yo2, z=z2);
				}
				doubleX() hull()
				{
					doubleY() sideSupportCylinderChamfer(d=chamferDia, x=d/2, y=sideOffsetY, z=z1, cz=cz);
					doubleY() sideSupportCylinderChamfer(d=chamferDia, x=d/2, y=yo2, z=z2, cz=cz);
				}
				// Chamfers at the front parts of the side-support:
				doubleY() translate([0,sideOffsetY-3, h2+5]) rotate([0,90,0]) tcy([0,0,-50], d=20, h=100, $fn=4);

				// Trim so the final piece doesn't extend below the extension:
				tcu([-200, -200, -400-extensionZ], 400);
			}
		}

		cameraLowerBodyDia = 55;
		translate([boltHeadDia/2, 0, cameraLowerBodyDia/2+9.4]) 
		{
			rotate([-90,0,0]) difference()
			{
				tcy([0,0,-50], d=cameraLowerBodyDia, h=100);
				tcu([-400,-200,-200], 400);
			}
		}
		tcy([0,0,12], d=mountArcRadius*2, h=100);

		// Recess for the rubber bit:
		difference()
		{
			union()
			{
				translate([0,0,ringTorusOffsetZ]) hull() torus3a(outsideDiameter=ringOutsideDiameter, circleDiameter=ringCircleDiameter);
				tcy([0,0,ringTorusOffsetZ], d=ringOutsideDiameter, h=100);
			}
			
			doubleY() tcu([-200, antiRotationSupportDia/2+0.02, -200], 400);
			tcu([-400, -200, -200], 400);
		}

		// Bolt threaded part:
		tcy([0,0,boltThreadsOffsetZ], d=boltThreadDia, h=200);
		// Bolt head:
		rotate([0,0,30]) tcy([0,0,boltRecessOffsetZ], d=boltHeadDia, h=100, $fn=6);

		// Bolt removal nut hole:
		tcy([0,0,-100], d=ballheadThreadHoleDia, h=100);
		// Bolt removal nut recess:
		tcy([0,0,boltThreadsOffsetZ-ballheadNutThickness], d=ballheadNutRecessDia, h=100, $fn=6);
		
		// Ball-head mount:
		translate([-ballheadMountOffsetX, 0, 0])
		{
			// Hole for the threads:
			tcy([0, 0, -50], d=ballheadThreadHoleDia, h=100);
			// Recess for the stop on the ball-head threaded section:
			tcy([0,0,-10+ballheadMountOffsetZ], d=ballheadThreadStopDia, h=10);
			// Nut:
			tcy([0,0,ballheadMountOffsetZ+3.7], d=ballheadNutRecessDia, h=10, $fn=6);
		}
	}

	// Sacrificial layer in ball-head mount:
	layerThickness = 0.2;
	tcy([-ballheadMountOffsetX,0,-0+ballheadMountOffsetZ], d=ballheadThreadStopDia, h=layerThickness);
}

module sideSupportCylinder(d, x, y, z)
{
	translate([0, y-d/2, z+d/2]) rotate([0,90,0]) 
	{
		tcy([0,0,-100], d=d, h=200, $fn=4);
	}
}

module sideSupportCylinderChamfer(d, x, y, z, cz)
{
	echo(str("sideSupportCylinderChamfer(): d, x, y, z, cz = ", d, ", ", x, ", ", y, ", ", z, ", ", cz));
	translate([0, y-d/2, z+d/2]) rotate([0,90,0]) 
	{
		translate([0,0,x-d/2-cz]) cylinder(d2=16, d1=0, h=8, $fn=4);
	}
}

module testPrint()
{
	difference()
	{
		itemModule();
		tcu([-200, -200, -400], 400);
	}
}

module clip(d=0)
{
	// tcu([-200, -400-d, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
	// displayGhost() translate([0,0,ringTorusOffsetZ]) torus3a(outsideDiameter=ringOutsideDiameter, circleDiameter=ringCircleDiameter);

	// display() testPrint();
}
else
{
	itemModule();
	// testPrint();
}
