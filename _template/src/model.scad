// Project name — parametric model
// Units: mm

/* [Dimensions] */
width     = 50;
depth     = 30;
height    = 10;
wall      = 2.4;   // >= 1.2 for most print services

/* [Fit] */
clearance = 0.2;   // hole/slot clearance for printed parts

/* [Quality] */
$fn = 64;

module part() {
    difference() {
        cube([width, depth, height]);
        translate([wall, wall, wall])
            cube([width - 2*wall, depth - 2*wall, height]);
    }
}

part();

// Export: openscad -o ../exports/part.stl model.scad
