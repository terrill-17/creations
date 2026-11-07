// Coffee machine (automatic pour-over brewer): shared parameters
// Units: mm. Axes: X = width (left to right), Y = depth (front 0 to back),
// Z = up from the underside of the base panel.
// Included by assembly.scad and printed_inserts.scad.
// Every "VERIFY" value is a placeholder until the real part is measured.

/* [Sheet stock: birch ply, cut in-house on the table saw] */
ply      = 18;     // outer panels, 18 mm (3/4" nominal)
ply_in   = 12;     // interior dividers and shelves, 12 mm (1/2" nominal)
dado_d   = 6;      // dado depth for shelves and insert slots

/* [Bays (inside dimensions)] */
kettle_bay_w = 240;   // kettle side bay, opens to the front
kettle_bay_h = 280;
brew_bay_w   = 200;   // carafe bay, the cut-out bottom-front quadrant
brew_bay_h   = 340;
bay_d        = 230;   // depth of both bays, front to rear divider
tech_d       = 100;   // rear strip behind the divider: electronics, wiring
upper_h      = 120;   // overhang above the brew bay (nozzle + trim heater)

/* [Derived overall size] */
W = ply + kettle_bay_w + ply_in + brew_bay_w + ply;   // ~478
D = bay_d + ply_in + tech_d + ply;                     // ~360
H = ply + brew_bay_h + ply_in + upper_h + ply;         // ~508
kettle_x0 = ply;                                       // bay inner left
brew_x0   = ply + kettle_bay_w + ply_in;               // bay inner left
floor_z   = ply;                                       // top of base panel

/* [Kettle: plain compact 1.0 L boil-only, VERIFY against the chosen model] */
kettle_body_d = 165;
kettle_h      = 215;   // power base + kettle to top of lid
kettle_base_d = 175;
kettle_base_h = 25;
kettle_handle = 55;    // handle sticks out this far from the body

/* [Hario V60-02 plastic (VD-02T): Hario lists 138 W x 115 D x 82 H] */
v60_rim_d    = 115;
v60_h        = 82;
v60_plate_d  = 100;    // VERIFY: diameter of the flat base plate
v60_plate_t  = 4;      // VERIFY
v60_outlet_d = 45;     // VERIFY: clear hole under the cone
v60_handle_w = 30;     // VERIFY: width of the handle where it meets the cone

/* [Carafe: Hario V60 Range Server 600 class, VERIFY] */
carafe_d = 105;
carafe_h = 115;

/* [Bar load cells, VERIFY against purchased cells] */
lc_l          = 80;
lc_w          = 12.7;
lc_h          = 12.7;
lc_hole_d     = 4.5;   // M4 clearance
lc_hole_pitch = 15;
lc_hole_end   = 5;

/* [Brew bay stack, bottom to top] */
scale_h      = 32;     // carafe scale: spacer + beam + platform
tray_h       = 18;     // drip tray with grate
cone_gap     = 8;      // carafe top to V60 plate
holder_z     = floor_z + scale_h + tray_h + carafe_h + cone_gap; // V60 seat
nozzle_gap   = 25;     // nozzle tip above the V60 rim
nozzle_z     = holder_z + v60_plate_t + v60_h + nozzle_gap;
brew_cx      = brew_x0 + brew_bay_w/2;   // centre line of cone and carafe
brew_cy      = 105;

/* [Nozzle: polar mechanism, concept level in this draft] */
spiral_r_max = 45;     // radial travel needed to reach the V60-02 bed edge
hub_d        = 60;

/* [Print fit] */
clearance = 0.3;   // MJF/SLS PA12; use 0.2 for FDM PETG
wall      = 3;

$fn = 72;
