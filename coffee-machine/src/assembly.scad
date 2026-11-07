// Coffee machine: overall layout and assembly view (draft 2)
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
show_fronts   = true;
drawer_open   = 0;       // mm the cone drawer is pulled out (0 to ~170)
door_open     = false;   // hide the kettle door to see into the bay

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
front  = [0.86, 0.72, 0.52];   // door and drawer front, same panel as the grain match
brass  = [0.78, 0.62, 0.28];
alu    = [0.82, 0.83, 0.85];
glow   = [1.0, 0.86, 0.6];

// ------------------------------------------------------------ panels ----
shelf_k_z = floor_z + kettle_bay_h;          // shelf over the kettle bay
shelf_b_z = floor_z + brew_bay_h;            // shelf over the brew bay
div_y     = bay_d;                           // front face of the rear divider

module panels() {
    paint(wood) {
        difference() {                                       // base
            cube([W, D, ply]);
            // kettle bay air intake: slots in the overhang strip, outside the plinth
            for (x=[kettle_x0 + 30 : 16 : kettle_x0 + kettle_bay_w - 40])
                translate([x, 6, -1]) cube([8, plinth_inset - 12, ply + 2]);
        }
        translate([0, 0, H - ply]) cube([W, D, ply]);        // top
        difference() {                                       // left side
            translate([0, 0, ply]) cube([ply, D, H - 2*ply]);
            // kettle bay exhaust: slots just under the kettle shelf
            for (y=[30 : 16 : bay_d - 40])
                translate([-1, y, shelf_k_z - 40]) cube([ply + 2, 8, 30]);
        }
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
        // fascia over the brew bay, behind the drawer front (closes the overhang)
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

module v60_at(open=0) {
    paint([0.9, 0.9, 0.95, 0.85]) translate([brew_cx, brew_cy - open, holder_z]) {
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

module rear_buttons() {   // 19 mm brass: Power (latching) and Brew (momentary)
    for (i=[0, 1]) translate([W - ply - 40 - i*34, D, H - 60]) rotate([-90, 0, 0]) {
        paint(brass) cylinder(d=24, h=3);
        paint(brass) cylinder(d=19, h=6);
        paint(glow) translate([0, 0, 6]) difference() { cylinder(d=15, h=0.6); translate([0, 0, -1]) cylinder(d=12, h=3); }
    }
}

// ---------------------------------------------------------- plinth + LED --
module plinth() {
    pw = W - 2*plinth_inset; pd = D - 2*plinth_inset; t = ply;
    paint(inner) translate([plinth_inset, plinth_inset, -plinth_h]) difference() {
        cube([pw, pd, plinth_h]);
        translate([t, t, -1]) cube([pw - 2*t, pd - 2*t, plinth_h + 2]);
    }
}
module led_strip() {   // channel + opal diffuser on the base underside, shining down
    w = led_ch[0]; h = led_ch[1]; o = led_inset - w/2;
    paint(alu) translate([0, 0, -h]) difference() {
        translate([o, o, 0]) cube([W - 2*o, D - 2*o, h]);
        translate([o + w, o + w, -1]) cube([W - 2*o - 2*w, D - 2*o - 2*w, h + 2]);
    }
    paint(glow) translate([0, 0, -h - 0.5]) difference() {
        translate([o + 1, o + 1, 0]) cube([W - 2*o - 2, D - 2*o - 2, 0.6]);
        translate([o + w - 1, o + w - 1, -1]) cube([W - 2*o - 2*w + 2, D - 2*o - 2*w + 2, 3]);
    }
}

// ---------------------------------------------------------------- fronts --
split_x = ply + kettle_bay_w + ply_in/2;   // fronts meet over the bay divider
module kettle_door() {
    paint(front) translate([reveal, -front_t, reveal - plinth_h * 0])
        cube([split_x - reveal*1.5, front_t, H - 2*reveal]);
    // concealed cup hinges on the left side panel, push latch on the divider
    for (z=[80, H - 80]) {
        paint(steel) translate([ply + 2, 0, z - 25]) cube([12, 40, 50]);
        paint(steel) translate([24, -4, z]) rotate([90, 0, 0]) cylinder(d=hinge_cup, h=12);
    }
    paint(steel) translate([split_x - ply_in/2 - 16, 0, H/2]) cube([14, 30, 12]);   // push latch
}
module drawer_front(open=0) {
    paint(front) translate([split_x + reveal/2, -front_t - open, drawer_front_z0])
        cube([W - split_x - reveal*1.5, front_t, H - reveal - drawer_front_z0]);
}
module drawer(open=0) {
    paint(pa12) translate([brew_x0 + slide_t + 0.5, -open, holder_z - drawer_floor]) drawer_tray();
    // slides on the bay walls
    for (x=[brew_x0, brew_x0 + brew_bay_w - slide_t])
        paint(alu) translate([x, 0, holder_z - drawer_floor + 2]) cube([slide_t, slide_l, 35]);
    // push latch + reed switch at the back of the drawer
    paint(steel) translate([brew_x0 + brew_bay_w - 40, div_y - 16, holder_z + 10]) cube([14, 16, 12]);
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
    // nozzle shroud under the brew shelf
    paint(pa12) translate([brew_cx, brew_cy, shelf_b_z]) nozzle_shroud();
    // kettle scale platform
    paint(pa12) translate([kettle_x0 + kettle_bay_w/2, bay_d/2, floor_z + 16]) kettle_platform();
}

// ------------------------------------------------------------- build -----
// Cabinet sits on the plinth; z = 0 is the counter.
translate([0, 0, plinth_h]) {
    if (show_panels) { panels(); plinth(); led_strip(); }
    if (show_fronts) { if (!door_open) kettle_door(); drawer_front(drawer_open); }
    if (show_bought) {
        kettle(); v60_at(drawer_open); carafe(); pump(); flowmeter(); heater_block();
        nozzle_mech(); electronics(); rear_buttons();
        load_cell([brew_cx, brew_cy + 75 - lc_l, floor_z + 6], 90);
        load_cell([kettle_x0 + kettle_bay_w/2, bay_d/2 - lc_l/2, floor_z], 90);
    }
    if (show_printed) { printed(); drawer(drawer_open); }
    if (show_water) water_path();
}
