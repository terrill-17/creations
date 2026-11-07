// Coffee machine: overall layout and assembly view (draft 1)
// Units: mm. Panels are cut in-house; bought parts are coloured placeholders.
// Render: see exports/build.sh. Set show_* to hide groups.

include <params.scad>
use <printed_inserts.scad>

/* [View] */
show_panels   = true;
show_side     = false;   // right side panel hides the brew bay; off by default
show_bought   = true;
show_printed  = true;
show_water    = true;

/* [Export by colour, used by export_viewer.py] */
pick = "";   // "" = everything; "__list__" = echo colours only; else one colour

module paint(c) {
    if (pick == "__list__") echo(str("PAINT|", c));
    else if (pick == "" || pick == str(c)) color(c) children();
}

wood   = [0.82, 0.68, 0.48];
inner  = [0.74, 0.60, 0.42];
steel  = [0.75, 0.77, 0.80];
pa12   = [0.25, 0.25, 0.27];
petg   = [0.30, 0.55, 0.80];
hot    = [0.85, 0.30, 0.20];
water  = [0.35, 0.65, 0.95];

// ------------------------------------------------------------ panels ----
shelf_k_z = floor_z + kettle_bay_h;          // shelf over the kettle bay
shelf_b_z = floor_z + brew_bay_h;            // shelf over the brew bay
div_y     = bay_d;                           // front face of the rear divider

module panels() {
    paint(wood) {
        cube([W, D, ply]);                                   // base
        translate([0, 0, H - ply]) cube([W, D, ply]);        // top
        translate([0, 0, ply]) cube([ply, D, H - 2*ply]);    // left side
        if (show_side)
            translate([W - ply, 0, ply]) cube([ply, D, H - 2*ply]);  // right side
        translate([ply, D - ply, ply]) cube([W - 2*ply, ply, H - 2*ply]);  // back (service panel)
    }
    paint(inner) {
        // divider between kettle bay and brew bay, full height, stops at rear divider
        translate([ply + kettle_bay_w, 0, ply]) cube([ply_in, div_y, H - 2*ply]);
        // rear divider: bays in front, tech strip behind
        translate([ply, div_y, ply]) cube([W - 2*ply, ply_in, H - 2*ply]);
        // shelf over kettle bay
        translate([ply, 0, shelf_k_z]) cube([kettle_bay_w, div_y, ply_in]);
        // shelf over brew bay (underside carries the nozzle mechanism)
        translate([brew_x0, 0, shelf_b_z]) cube([brew_bay_w, div_y, ply_in]);
        // front fascia over the brew bay: buttons + LED ring
        translate([brew_x0, 0, shelf_b_z + ply_in]) cube([brew_bay_w, ply_in, upper_h]);
        // front fascia over the kettle bay
        translate([ply, 0, shelf_k_z + ply_in]) cube([kettle_bay_w, ply_in, H - ply - shelf_k_z - ply_in]);
    }
}

// --------------------------------------------------------- bought parts --
module kettle() {
    cx = kettle_x0 + kettle_bay_w/2; cy = bay_d/2;
    zp = floor_z + 16;   // sits on the kettle scale platform
    paint([0.2, 0.2, 0.2]) translate([cx, cy, zp]) cylinder(d=kettle_base_d, h=kettle_base_h);
    paint(steel) translate([cx, cy, zp + kettle_base_h]) cylinder(d=kettle_body_d, h=kettle_h - kettle_base_h);
    paint([0.2, 0.2, 0.2]) translate([cx - 12, cy + kettle_body_d/2 - 5, zp + 70])
        cube([24, kettle_handle, kettle_h - 110]);
}

module v60() {
    paint([0.9, 0.9, 0.95, 0.85]) translate([brew_cx, brew_cy, holder_z]) {
        cylinder(d=v60_plate_d, h=v60_plate_t);
        translate([0, 0, v60_plate_t]) cylinder(d1=v60_outlet_d + 10, d2=v60_rim_d, h=v60_h);
    }
}

module carafe() {
    paint([0.85, 0.92, 0.95, 0.6])
        translate([brew_cx, brew_cy, floor_z + scale_h + tray_h]) cylinder(d=carafe_d, h=carafe_h);
}

module load_cell(at, rot=0) {
    paint([0.7, 0.7, 0.72]) translate(at) rotate([0, 0, rot])
        translate([0, -lc_w/2, 0]) cube([lc_l, lc_w, lc_h]);
}

module pump() {   // peristaltic, above the kettle bay
    paint([0.15, 0.15, 0.15]) translate([kettle_x0 + 30, 60, shelf_k_z + ply_in])
        cube([pump_body[0], pump_body[1], pump_body[2]]);
}

module flowmeter() {   // Digmesa Nano Inox, after the pump, before the heater
    paint(steel) translate([kettle_x0 + 150, 90, shelf_k_z + ply_in + 20])
        rotate([0, 90, 0]) cylinder(d=24, h=40);
}

module heater_block() {   // trim heater, in the overhang, insulated
    paint(hot) translate([brew_x0 + 30, 150, shelf_b_z + ply_in + 15])
        rotate([0, 0, -90]) translate([0, 0, 10])
        import("../exports/trim_heater_block_preview.stl");
    // insulation jacket envelope
    paint([0.95, 0.95, 0.9, 0.25]) translate([brew_x0 + 20, 8 + ply_in, shelf_b_z + ply_in + 5])
        cube([150, 84, 40]);
}

module nozzle_mech() {   // polar: rotating hub + radial carriage, concept only
    z = shelf_b_z;
    paint(pa12) translate([brew_cx, brew_cy, z - 30]) cylinder(d=hub_d, h=30);
    paint(pa12) translate([brew_cx - spiral_r_max - 10, brew_cy - 8, z - 42]) cube([2*spiral_r_max + 20, 16, 12]);
    paint(steel) translate([brew_cx + 20, brew_cy, nozzle_z]) cylinder(d=6.35, h=z - 42 - nozzle_z);
    // motors
    paint([0.1, 0.1, 0.1]) translate([brew_cx + 40, brew_cy + 40, z - 25]) cube([42, 42, 25]);
}

module electronics() {
    paint(petg) translate([ply + 20, div_y + ply_in, H - ply - 60]) electronics_tray();
    paint([0.1, 0.5, 0.2]) translate([ply + 40, div_y + ply_in + 10, H - ply - 57]) cube([150, 70, 15]);
}

module controls() {   // Off (hardware stop) and Brew buttons + LED ring on fascia
    z = shelf_b_z + ply_in + upper_h/2;
    paint([0.8, 0.1, 0.1]) translate([brew_cx - 45, -4, z]) rotate([-90, 0, 0]) cylinder(d=22, h=6);
    paint(steel) translate([brew_cx + 45, -4, z]) rotate([-90, 0, 0]) cylinder(d=22, h=6);
    paint([0.9, 0.9, 1.0]) translate([brew_cx, -2, z]) rotate([-90, 0, 0])
        difference() { cylinder(d=66, h=3); translate([0, 0, -1]) cylinder(d=52, h=5); }
}

// -------------------------------------------------------- water path ----
module water_path() {
    // kettle dip wand -> pump -> flow meter -> trim heater -> PT1000 tee -> nozzle
    k = [kettle_x0 + kettle_bay_w/2, bay_d/2 - 30];
    pts = [
        [k[0], k[1], floor_z + 40],                         // pickup near kettle floor
        [k[0], k[1], shelf_k_z + ply_in + 30],              // up through kettle shelf
        [kettle_x0 + 60, 100, shelf_k_z + ply_in + 30],     // pump inlet
        [kettle_x0 + 150, 100, shelf_k_z + ply_in + 20],    // flow meter
        [brew_x0 + 40, 140, shelf_b_z + ply_in + 25],       // heater in
        [brew_x0 + 40, 30, shelf_b_z + ply_in + 25],        // heater out
        [brew_cx, brew_cy, shelf_b_z + ply_in + 10],        // PT1000 tee, down to hub
        [brew_cx, brew_cy, shelf_b_z - 40],
    ];
    paint(water) for (i=[0:len(pts) - 2]) hull() {
        translate(pts[i]) sphere(d=9.5, $fn=16);
        translate(pts[i + 1]) sphere(d=9.5, $fn=16);
    }
}

// ------------------------------------------------------------- printed ---
pump_body = [70, 95, 62];   // keep in step with printed_inserts.scad
module printed() {
    // carafe scale: spacer + beam + platform, drip tray on top
    paint(pa12) translate([brew_cx, brew_cy + 75 - lc_l, floor_z + 6 + lc_h + 10]) rotate([0, 0, 90]) carafe_platform();
    paint(pa12) translate([brew_cx - (brew_bay_w - 4)/2 + 0.3, brew_cy - 95, floor_z + scale_h])
        { drip_tray(); translate([3.3, 3.3, tray_h - 8]) drip_grate(); }
    // V60 holder cantilevered from the rear divider on the cone load cell
    paint(pa12) translate([brew_cx, brew_cy, holder_z - 6]) v60_holder();
    // kettle scale platform
    paint(pa12) translate([kettle_x0 + kettle_bay_w/2, bay_d/2, floor_z + 16]) kettle_platform();
}

// ------------------------------------------------------------- build -----
if (show_panels) panels();
if (show_bought) {
    kettle(); v60(); carafe(); pump(); flowmeter(); heater_block();
    nozzle_mech(); electronics(); controls();
    load_cell([brew_cx, brew_cy + 75 - lc_l, floor_z + 6], 90);
    load_cell([brew_cx - lc_w/2 + 6, div_y - lc_l + 2, holder_z - 6 - lc_h], 90);
    load_cell([kettle_x0 + kettle_bay_w/2, bay_d/2 - lc_l/2, floor_z], 90);
}
if (show_printed) printed();
if (show_water) water_path();
