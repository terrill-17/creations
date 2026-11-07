// Coffee machine: 3D-printed inserts
// Units: mm. Select a part with -D 'part="name"' (see exports/build.sh).
// Material: PA12 (MJF, JLC3DP) for anything near water, heat or steam;
// PETG is fine for the electronics tray.
// None of these parts touch brewing water or coffee: the V60 insert, the
// carafe and the stainless/silicone water path are bought, food-grade parts.

include <params.scad>

/* [Part] */
part = "all";  // [all, v60_holder, cone_lc_mount, drip_tray, drip_grate, carafe_platform, kettle_platform, lc_spacer, electronics_tray, pump_cradle]

/* [Heat-set inserts] */
insert_m3_d = 4.0;   // hole for M3 brass heat-set insert (check insert brand)
insert_m4_d = 5.6;
m3_clr = 3.4;
m4_clr = 4.5;

// ---------- helpers ----------
module rounded_box(size, r=4) {
    hull() for (x=[r, size[0]-r], y=[r, size[1]-r])
        translate([x, y, 0]) cylinder(r=r, h=size[2]);
}

// Two holes at one end of a bar load cell, centred on x=0, along +X.
module lc_end_holes(d=lc_hole_d, h=50) {
    for (i=[0,1]) translate([i*lc_hole_pitch, 0, -1]) cylinder(d=d, h=h);
}

// ---------- V60 holder ----------
// Ring that locates the V60 base plate, with a gap for the handle, on an arm
// that bolts to the free end of the cone load cell. Origin = cone centre.
holder_t     = 6;
holder_wall  = 6;
holder_arm_w = 24;
holder_arm_l = 95;   // cone centre to load-cell bolt pattern
module v60_holder() {
    seat_d = v60_plate_d + 2*clearance;
    od = seat_d + 2*holder_wall;
    difference() {
        union() {
            cylinder(d=od, h=holder_t + v60_plate_t);
            translate([-holder_arm_w/2, 0, 0])
                cube([holder_arm_w, holder_arm_l + lc_hole_pitch + 10, holder_t]);
        }
        // seat for the base plate
        translate([0, 0, holder_t]) cylinder(d=seat_d, h=50);
        // drip-through hole
        translate([0, 0, -1]) cylinder(d=v60_outlet_d + 4, h=50);
        // handle gap (handle faces the front, -Y, so the cone lifts out forward)
        translate([-(v60_handle_w + 4)/2, -od, holder_t])
            cube([v60_handle_w + 4, od/2, 50]);
        // load-cell bolts (M4 into heat-set inserts from below)
        translate([0, holder_arm_l, 0]) rotate([0, 0, 90])
            lc_end_holes(d=insert_m4_d, h=holder_t + 2);
    }
}

// ---------- cone load-cell wall mount ----------
// Block that screws to the rear divider and holds the fixed end of the beam.
module cone_lc_mount() {
    bw = 40; bh = 30; bd = lc_hole_pitch + 2*lc_hole_end + 6;
    difference() {
        cube([bw, bd, bh]);
        // beam fixed-end holes, vertical
        translate([bw/2, lc_hole_end + 3, bh - 12]) rotate([0, 0, 90])
            lc_end_holes(d=insert_m4_d, h=20);
        // two #8 wood screws into the divider, through the back face
        for (x=[8, bw-8]) translate([x, bd + 1, bh/2]) rotate([90, 0, 0]) {
            cylinder(d=4.5, h=bd + 2);
            cylinder(d=9, h=bd - 6);   // counterbore from the front
        }
    }
}

// ---------- drip tray and grate ----------
tray_w = brew_bay_w - 2*clearance - 4;
tray_d = 190;
module drip_tray() {
    difference() {
        rounded_box([tray_w, tray_d, tray_h - 4], r=6);
        translate([wall, wall, 2]) rounded_box([tray_w - 2*wall, tray_d - 2*wall, 50], r=4);
        // finger notch at the front
        translate([tray_w/2, -1, tray_h - 4]) rotate([-90, 0, 0]) cylinder(d=30, h=wall + 2);
    }
    // ledge the grate rests on
    difference() {
        translate([wall, wall, 0]) rounded_box([tray_w - 2*wall, tray_d - 2*wall, tray_h - 8], r=4);
        translate([wall + 3, wall + 3, -1]) rounded_box([tray_w - 2*wall - 6, tray_d - 2*wall - 6, 50], r=3);
    }
}
module drip_grate() {
    gw = tray_w - 2*wall - 2*clearance;
    gd = tray_d - 2*wall - 2*clearance;
    slot = 5; bar = 4;
    difference() {
        rounded_box([gw, gd, 4], r=4);
        for (y=[10 : slot + bar : gd - 10 - slot])
            translate([10, y, -1]) cube([gw - 20, slot, 6]);
    }
}

// ---------- scale platforms ----------
// Platform bolts to the free end of a bar load cell; ribs keep it stiff.
module lc_platform(size, rib_h=8) {
    difference() {
        union() {
            translate([-size[0]/2, -size[1]/2, 0]) rounded_box([size[0], size[1], 4], r=6);
            // boss over the load-cell end
            translate([-12, -lc_w, -rib_h]) cube([24, lc_hole_pitch + 2*lc_hole_end + 2, rib_h]);
            // ribs
            for (a=[0, 90]) rotate([0, 0, a])
                translate([-min(size[0], size[1])/2 + 6, -1.5, -rib_h + 2])
                    cube([min(size[0], size[1]) - 12, 3, rib_h - 2]);
        }
        translate([0, -lc_w + lc_hole_end + 1, -rib_h - 1]) rotate([0, 0, 90])
            lc_end_holes(d=insert_m4_d, h=rib_h + 2);
    }
}
module carafe_platform() lc_platform([tray_w - 10, 150]);
module kettle_platform() lc_platform([kettle_base_d + 30, kettle_base_d + 30], rib_h=10);

// Spacer under the fixed end of a beam so the free end can flex.
module lc_spacer() {
    difference() {
        translate([-10, -lc_w/2 - 4, 0]) cube([lc_hole_pitch + 20, lc_w + 8, 6]);
        lc_end_holes(d=m4_clr, h=10);
    }
}

// ---------- electronics tray ----------
// Slides into dados in the tech-strip side walls. Pegboard of M3 insert
// holes on a 10 mm grid so boards can move while the layout is unsettled.
etray_w = 220;
etray_d = tech_d - 2*clearance;
module electronics_tray() {
    difference() {
        union() {
            cube([etray_w, etray_d, 3]);
            // lip at the rear for cable ties
            translate([0, etray_d - 3, 0]) cube([etray_w, 3, 12]);
        }
        for (x=[15 : 10 : etray_w - 15], y=[10 : 10 : etray_d - 15])
            translate([x, y, -1]) cylinder(d=insert_m3_d, h=5, $fn=20);
        for (x=[20 : 30 : etray_w - 20])
            translate([x, etray_d - 4, 7]) cube([5, 5, 3], center=true);   // tie slots
    }
}

// ---------- pump cradle ----------
// U-cradle with strap slots; pump body size is a VERIFY until the pump is chosen.
pump_body = [70, 95, 62];   // VERIFY: w, l, h of the peristaltic pump body
module pump_cradle() {
    w = pump_body[0] + 2*clearance; l = pump_body[1] * 0.6; h = pump_body[2] * 0.5;
    difference() {
        translate([-wall, 0, -wall]) cube([w + 2*wall, l, h + wall]);
        translate([0, -1, 0]) cube([w, l + 2, h + 1]);
        for (y=[l*0.25, l*0.75]) translate([-wall - 1, y - 6, -wall + 1]) cube([w + 2*wall + 2, 12, 2.5]);
        // base screws
        for (x=[w*0.25, w*0.75]) translate([x, l/2, -wall - 1]) cylinder(d=m4_clr, h=wall + 2);
    }
}

// ---------- layout ----------
if (part == "v60_holder")       v60_holder();
if (part == "cone_lc_mount")    cone_lc_mount();
if (part == "drip_tray")        drip_tray();
if (part == "drip_grate")       drip_grate();
if (part == "carafe_platform")  rotate([180, 0, 0]) carafe_platform();
if (part == "kettle_platform")  rotate([180, 0, 0]) kettle_platform();
if (part == "lc_spacer")        lc_spacer();
if (part == "electronics_tray") electronics_tray();
if (part == "pump_cradle")      pump_cradle();
if (part == "all") {
    v60_holder();
    translate([90, 0, 0])   cone_lc_mount();
    translate([150, -60, 0]) drip_tray();
    translate([150 + tray_w + 10, -60, 0]) drip_grate();
    translate([-150, -140, 10]) carafe_platform();
    translate([-150, 140, 10]) kettle_platform();
    translate([90, 60, 0])  lc_spacer();
    translate([-110, 260, 0]) electronics_tray();
    translate([150, 160, 3]) pump_cradle();
}
