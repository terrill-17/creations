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
show_wiring   = true;
drawer_open   = 0;       // mm the cone drawer is pulled out (0 to ~170)
door_angle    = 0;       // kettle door swing in degrees (0 closed, ~105 fully open)

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
sensor = [0.95, 0.55, 0.15];   // probes, reed switches, ToF
pcb    = [0.1, 0.5, 0.2];
board2 = [0.12, 0.3, 0.6];     // breakout boards (blue)
pwrhw  = [0.4, 0.4, 0.45];     // relay, fuse, DC jack
mainsbox = [0.18, 0.18, 0.2];  // UL-listed kettle relay outlet
w_pwr  = [0.85, 0.2, 0.15];    // 24 V and heater power
w_sig  = [0.95, 0.8, 0.2];     // sensor signals
w_mot  = [0.5, 0.35, 0.7];     // stepper cables
w_ui   = [0.2, 0.75, 0.8];     // LED strip, buttons, door/drawer switches
w_ac   = [0.92, 0.92, 0.92];   // mains cords (bought, moulded)

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
        difference() {
            translate([ply, div_y, ply]) cube([W - 2*ply, ply_in, H - 2*ply]);
            // 20 mm cable grommet holes (see wiring())
            for (p=grommets) translate([p[0], div_y - 1, p[1]]) rotate([-90, 0, 0]) cylinder(d=20, h=ply_in + 2);
        }
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

// Tech strip coordinates: behind the rear divider.
ts_y0 = div_y + ply_in;            // front face of the tech strip
ts_y1 = D - ply;                   // inside of the back panel
tray_z = H - ply - 60;             // electronics tray surface
module board(at, size, c=pcb, hs=0) {   // PCB + parts envelope (+ heatsink)
    paint(c) translate(at) cube([size[0], size[1], 1.6]);
    paint([0.15, 0.15, 0.15]) translate(at + [3, 3, 1.6]) cube([size[0] - 6, size[1] - 6, size[2]]);
    if (hs > 0) paint(alu) translate(at + [size[0]/2 - 6, size[1]/2 - 6, 1.6 + size[2]]) cube([12, 12, hs]);
}
module electronics() {
    paint(petg) translate([ply + 20, ts_y0, tray_z]) electronics_tray();
    z = tray_z + 3 + 6;            // boards on 6 mm standoffs
    // row 1 (front of tray): ESP32-S3, 2x MAX31865, 2x HX711, level shifter
    board([45, ts_y0 + 8, z], [69, 26, 6], [0.08, 0.08, 0.1]);          // ESP32-S3-DevKitC
    board([120, ts_y0 + 8, z], [28, 25, 3], board2);                     // MAX31865 (kettle)
    board([152, ts_y0 + 8, z], [28, 25, 3], board2);                     // MAX31865 (pre-nozzle)
    board([186, ts_y0 + 8, z], [34, 21, 3], pcb);                        // HX711 (carafe)
    board([186, ts_y0 + 32, z], [34, 21, 3], pcb);                       // HX711 (kettle)
    board([226, ts_y0 + 8, z], [20, 18, 3], board2);                     // 74AHCT125 level shifter
    // row 2: 3x TMC2209, heater MOSFET, buck converter
    for (i=[0:2]) board([45 + i*24, ts_y0 + 45, z], [20, 15, 3], [0.6, 0.1, 0.5], 9);   // TMC2209
    board([120, ts_y0 + 45, z], [40, 25, 4], pcb, 18);                   // MOSFET + heatsink
    board([166, ts_y0 + 58, z], [43, 21, 8], board2);                    // buck 24->5 V
    // main 24 V relay and blade fuse on the back panel, DC jack below
    paint(pwrhw) translate([300, ts_y1 - 30, tray_z + 5]) cube([30, 30, 26]);       // relay
    paint(pwrhw) translate([340, ts_y1 - 16, tray_z + 10]) cube([36, 16, 14]);      // fuse holder
    paint(pwrhw) translate([400, D - ply - 12, 60]) rotate([-90, 0, 0]) cylinder(d=14, h=ply + 14); // DC jack
    // UL-listed kettle relay outlet (IoT Relay style) at the bottom of the tech strip
    paint(mainsbox) translate([40, ts_y0 + 8, floor_z]) cube([150, 85, 60]);
}

// ------------------------------------------------------------- sensors ---
module sensors() {
    // PT1000 on the kettle dip wand (probe down into the kettle beside the pickup)
    k = [kettle_x0 + kettle_bay_w/2 + 12, bay_d/2 - 30];
    paint(sensor) translate([k[0], k[1], floor_z + 50]) cylinder(d=6, h=shelf_k_z - floor_z - 50);
    // PT1000 in the 316 tee before the nozzle
    paint(steel) translate([brew_cx - 15, brew_cy - 8, shelf_b_z + ply_in + 2]) cube([30, 16, 16]);  // tee
    paint(sensor) translate([brew_cx, brew_cy, shelf_b_z + ply_in + 18]) cylinder(d=6, h=40);
    // heater block: NTC and two 120 C cutouts on the top face
    hb = [brew_x0 + 30, 150, shelf_b_z + ply_in + 15 + 20];
    paint(sensor) translate([hb[0] + 91, hb[1] - 2, hb[2]]) cylinder(d=4, h=8);
    for (dx=[40, 64]) paint(sensor) translate([hb[0] + dx, hb[1], hb[2]]) cylinder(d=14, h=10);
    // ToF in the nozzle shroud, looking down
    paint(sensor) rotate_about([brew_cx, brew_cy, 0], 135)
        translate([brew_cx + (v60_rim_d + 12)/2 - 3 - 11, brew_cy - 6.5, shelf_b_z - 12]) cube([9, 13, 3]);
    // reed switches: kettle door (front edge of the bay divider), drawer (rear)
    paint(sensor) translate([split_x - 23, 0, 244]) cube([6, 4, 14]);
    paint(sensor) translate([brew_x0 + brew_bay_w - 25, div_y - 4, holder_z + 12]) cube([12, 4, 6]);
}
module rotate_about(p, a) translate(p) rotate([0, 0, a]) translate(-p) children();

// -------------------------------------------------------------- wiring ---
// [x, z] of the grommet holes in the rear divider, matching the runs below.
grommets = [[57, shelf_k_z + 60], [90, shelf_k_z + 45], [134, shelf_k_z + 40],
            [400, shelf_b_z - 15], [345, shelf_b_z - 8], [300, shelf_b_z + ply_in + 45],
            [320, shelf_b_z + ply_in + 60], [330, shelf_b_z + ply_in + 70],
            [split_x, 260], [440, holder_z + 15],
            [205, floor_z + 20], [310, floor_z + 20], [k_x(), floor_z + 30]];
function k_x() = kettle_x0 + kettle_bay_w/2;
// Each run starts at the controller tray and goes back-to-front through
// grommet holes in the rear divider. Polylines are drawn as 5 mm cables.
module cable(pts, c, d=5) {
    paint(c) for (i=[0:len(pts) - 2]) hull() {
        translate(pts[i]) sphere(d=d, $fn=8);
        translate(pts[i + 1]) sphere(d=d, $fn=8);
    }
}
tz = tray_z + 12;   // cable height leaving the boards
ty = ts_y0 + 30;
dv = div_y + ply_in/2;   // passing through the rear divider
module wiring() {
    k = [kettle_x0 + kettle_bay_w/2, bay_d/2];
    // --- motors (stepper cables) ---
    cable([[57, ty, tz], [57, dv, shelf_k_z + 60], [kettle_x0 + 60, 150, shelf_k_z + ply_in + 30]], w_mot);  // pump
    cable([[81, ty, tz], [81, ts_y0 + 70, tz], [400, ts_y0 + 70, tz], [400, dv, shelf_b_z - 12],
           [brew_cx + 60, brew_cy + 60, shelf_b_z - 12]], w_mot);                                          // nozzle rotate
    cable([[105, ty, tz], [105, ts_y0 + 75, tz], [410, ts_y0 + 75, tz], [410, dv, shelf_b_z - 18],
           [brew_cx + 20, brew_cy, shelf_b_z - 36]], w_mot);                                               // nozzle radial
    // --- 24 V power: DC jack -> fuse -> relay -> tray; MOSFET -> heater ---
    cable([[400, D - ply - 6, 60], [400, ts_y1 - 10, 60], [400, ts_y1 - 10, tray_z + 17], [376, ts_y1 - 8, tray_z + 17]], w_pwr, 6);
    cable([[340, ts_y1 - 8, tray_z + 17], [330, ts_y1 - 15, tray_z + 17]], w_pwr, 6);
    cable([[300, ts_y1 - 15, tray_z + 17], [210, ts_y0 + 70, tz]], w_pwr, 6);
    cable([[140, ts_y0 + 58, tz], [140, ts_y0 + 85, tz], [300, ts_y0 + 85, tz], [300, dv, shelf_b_z + ply_in + 45],
           [brew_x0 + 30, 140, shelf_b_z + ply_in + 45]], w_pwr, 6);                                     // heater cartridge
    // --- sensor signals ---
    cable([[134, ty, tz], [134, dv, shelf_k_z + 40], [k[0] + 12, k[1] - 30, shelf_k_z + 40], [k[0] + 12, k[1] - 30, shelf_k_z]], w_sig);  // kettle PT1000
    cable([[166, ty, tz], [166, ts_y0 + 20, tz + 6], [330, ts_y0 + 20, tz + 6], [330, dv, shelf_b_z + ply_in + 70],
           [brew_cx, brew_cy, shelf_b_z + ply_in + 70], [brew_cx, brew_cy, shelf_b_z + ply_in + 58]], w_sig);       // pre-nozzle PT1000
    cable([[60, ts_y0 + 20, tz], [60, ts_y0 + 12, tz + 8], [320, ts_y0 + 12, tz + 8], [320, dv, shelf_b_z + ply_in + 60],
           [brew_x0 + 121, 148, shelf_b_z + ply_in + 60]], w_sig);                                         // NTC
    cable([[90, ts_y0 + 20, tz], [90, dv - 0, shelf_k_z + 45], [kettle_x0 + 170, 90, shelf_k_z + ply_in + 35]], w_sig);  // flow meter
    cable([[203, ty, tz], [203, ts_y1 - 20, tz], [203, ts_y1 - 20, floor_z + 25], [205, dv, floor_z + 20],
           [k[0] + 6, k[1] + 30, floor_z + 8]], w_sig);                                                    // kettle load cell
    cable([[215, ty + 22, tz], [230, ts_y1 - 25, tz], [230, ts_y1 - 25, floor_z + 25], [310, dv, floor_z + 20],
           [brew_cx + 6, brew_cy + 70, floor_z + 12]], w_sig);                                             // carafe load cell
    cable([[100, ts_y0 + 18, tz], [100, ts_y0 + 25, tz + 10], [345, ts_y0 + 25, tz + 10], [345, dv, shelf_b_z - 8],
           [brew_cx - 30, brew_cy + 35, shelf_b_z - 8]], w_sig);                                           // ToF (I2C)
    // --- UI: door/drawer reeds, buttons, LED strip, kettle relay control ---
    cable([[70, ts_y0 + 15, tz], [70, ts_y0 + 15, 300], [split_x, dv, 260], [split_x, 4, 251]], w_ui);    // door reed
    cable([[110, ts_y0 + 15, tz], [110, ts_y0 + 15, 280], [440, ts_y0 + 15, 280], [440, dv, holder_z + 15],
           [brew_x0 + brew_bay_w - 19, div_y - 6, holder_z + 15]], w_ui);                                  // drawer reed
    cable([[236, ty, tz], [300, ts_y1 - 40, tz + 15], [W - ply - 40, ts_y1 - 10, H - 60], [W - ply - 74, ts_y1 - 10, H - 60]], w_ui); // buttons
    cable([[240, ts_y0 + 10, tz], [450, ts_y1 - 30, tz], [450, ts_y1 - 30, floor_z], [450, ts_y1 - 30, -2],
           [W - led_inset, ts_y1 - 30, -4]], w_ui);                                                        // LED strip
    cable([[50, ts_y0 + 40, tz], [30, ts_y1 - 10, tz], [30, ts_y1 - 10, floor_z + 70], [60, ts_y0 + 50, floor_z + 60]], w_ui);  // kettle relay control
    // --- mains (moulded cords from bought, listed parts) ---
    cable([[k[0], k[1] + 60, floor_z + 30], [k[0], dv, floor_z + 30], [150, ts_y0 + 40, floor_z + 30]], w_ac, 7);   // kettle base -> relay outlet
    cable([[60, ts_y0 + 70, floor_z + 30], [60, D + 30, floor_z + 30]], w_ac, 8);                         // relay outlet -> wall
    cable([[400, D + 2, 60], [400, D + 40, 40]], w_pwr, 6);                                               // 24 V brick lead in
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
module kettle_door(angle=0) {
    // Door leaf swings about a vertical axis at its outer-left front corner,
    // which is close to where a full-overlay cup hinge pivots.
    translate([reveal, -front_t, 0]) rotate([0, 0, -angle]) translate([-reveal, front_t, 0]) {
        paint(front) translate([reveal, -front_t, reveal])
            cube([split_x - reveal*1.5, front_t, H - 2*reveal]);
        // hinge cups bored in the door back, door-switch magnet near the latch edge
        for (z=[80, H - 80])
            paint(steel) translate([24, 0.5, z]) rotate([90, 0, 0]) cylinder(d=hinge_cup, h=12);
        paint(sensor) translate([split_x - 20, 0.5, 250]) rotate([90, 0, 0]) cylinder(d=10, h=3);
    }
    // hinge arms and mounting plates on the left side panel (fixed)
    for (z=[80, H - 80]) {
        paint(steel) translate([ply + 2, 0, z - 25]) cube([12, 40, 50]);
        paint(steel) translate([ply + 2 - angle/12, -6, z - 8]) cube([12 + angle/12, 8, 16]);
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
    if (show_fronts) { kettle_door(door_angle); drawer_front(drawer_open); }
    if (show_bought) {
        kettle(); v60_at(drawer_open); carafe(); pump(); flowmeter(); heater_block();
        nozzle_mech(); electronics(); rear_buttons(); sensors();
        load_cell([brew_cx, brew_cy + 75 - lc_l, floor_z + 6], 90);
        load_cell([kettle_x0 + kettle_bay_w/2, bay_d/2 - lc_l/2, floor_z], 90);
    }
    if (show_printed) { printed(); drawer(drawer_open); }
    if (show_water) water_path();
    if (show_wiring) wiring();
}
