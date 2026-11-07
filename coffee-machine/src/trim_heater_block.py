"""Trim heater block: 6061 aluminium, CNC (Xometry / SendCutSend / PCBWay).

A split block that clamps a bent 1/4" 316 stainless tube (two straight passes
joined by one U-bend outside the block) around a 24 V cartridge heater.
Water only ever touches the stainless tube; the aluminium stays dry.

Units: mm.  Run:  python3 trim_heater_block.py   (writes ../exports/)
"""
from pathlib import Path

import cadquery as cq

# --- parameters --------------------------------------------------------------
L = 130.0            # block length (along the tube passes)
W = 64.0             # block width
T_HALF = 10.0        # thickness of each half; total 20
TUBE_OD = 6.35       # 1/4" 316 SS tube
TUBE_CLR = 0.15      # groove radius = OD/2 + clearance; fill with thermal paste
PASS_PITCH = 32.0    # centre-to-centre of the two passes (U-bend R16 = 2.5 x OD)
HEATER_D = 10.0      # VERIFY: 24 V ~150 W cartridge heater, 10 mm x 100 mm
HEATER_FIT = 0.1     # slip fit; heater bore is split on the joint line
HEATER_DEPTH = 105.0 # blind bore from the inlet/outlet end
NTC_D = 3.2          # glass-bead NTC in thermal epoxy, top half only
NTC_DEPTH = 8.0
CUTOUT_PITCH = 24.0  # VERIFY: KSD301-style 120 C cutout, 2x M4 tapped
CLAMP_X = 27.0       # clamp screw rows, outside the tube grooves
CLAMP_Y = (15.0, 48.3, 81.7, 115.0)
M4_TAP = 3.3         # tap drill for M4
M4_CLR = 4.5

OUT = Path(__file__).resolve().parent.parent / "exports"


def half(top: bool) -> cq.Workplane:
    """One half of the block. Joint face at z=0; top half extends +z."""
    blk = cq.Workplane("XY").box(W, L, T_HALF, centered=(True, False, False))
    if not top:
        blk = blk.translate((0, 0, -T_HALF))

    # Tube grooves: half-round, full length, on the joint face.
    r = TUBE_OD / 2 + TUBE_CLR
    for x in (-PASS_PITCH / 2, PASS_PITCH / 2):
        groove = (cq.Workplane("XZ").center(x, 0).circle(r)
                  .extrude(-L))  # XZ normal is -Y, so -L extrudes toward +Y
        blk = blk.cut(groove)

    # Cartridge heater: blind half-bore from the y=0 end, centred on x=0.
    hb = (cq.Workplane("XZ").circle(HEATER_D / 2 + HEATER_FIT)
          .extrude(-HEATER_DEPTH))
    blk = blk.cut(hb)

    # Clamp screws: clearance in the top half, tapped in the bottom half.
    d = M4_CLR if top else M4_TAP
    for x in (-CLAMP_X, CLAMP_X):
        for y in CLAMP_Y:
            z0 = 0 if top else -T_HALF
            hole = (cq.Workplane("XY").workplane(offset=z0)
                    .center(x, y).circle(d / 2).extrude(T_HALF))
            blk = blk.cut(hole)

    if top:
        # NTC pocket and thermal cutout mount on the top face, over the heater.
        ntc = (cq.Workplane("XY").workplane(offset=T_HALF - NTC_DEPTH)
               .center(0, L * 0.7).circle(NTC_D / 2).extrude(NTC_DEPTH))
        blk = blk.cut(ntc)
        for dy in (-CUTOUT_PITCH / 2, CUTOUT_PITCH / 2):
            tap = (cq.Workplane("XY").workplane(offset=T_HALF - 7)
                   .center(0, L * 0.4 + dy).circle(M4_TAP / 2).extrude(7))
            blk = blk.cut(tap)
    return blk


def main() -> None:
    OUT.mkdir(exist_ok=True)
    top, bottom = half(True), half(False)
    cq.exporters.export(top, str(OUT / "trim_heater_block_top.step"))
    cq.exporters.export(bottom, str(OUT / "trim_heater_block_bottom.step"))
    # STL of the assembled block, for the OpenSCAD assembly view only.
    cq.exporters.export(top.union(bottom), str(OUT / "trim_heater_block_preview.stl"))
    print("wrote", *sorted(p.name for p in OUT.glob("trim_heater_block*")))


if __name__ == "__main__":
    main()
