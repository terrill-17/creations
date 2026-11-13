#!/usr/bin/env bash
# Regenerate every export and render from src/. Run from anywhere.
# Needs: openscad (2021+), python3 with cadquery, xvfb-run for headless renders.
set -euo pipefail
cd "$(dirname "$0")/../src"

# CNC: trim heater block (STEP), plus a preview STL used by assembly.scad
python3 trim_heater_block.py

# 3D-printed inserts (STL)
for p in drawer_tray nozzle_shroud drip_tray drip_grate carafe_platform \
         kettle_platform lc_spacer electronics_tray pump_cradle; do
  openscad -q -D "part=\"$p\"" -o "../exports/$p.stl" printed_inserts.scad
  echo "wrote $p.stl"
done

# Renders
run() { if [ -z "${DISPLAY:-}" ]; then xvfb-run -a openscad "$@"; else openscad "$@"; fi; }
run -q -D show_side=true -o ../images/assembly_front.png --imgsize=1400,1100 --viewall --autocenter \
    --camera=0,0,0,62,0,28,0 --colorscheme=Tomorrow assembly.scad
run -q -D show_side=true -D drawer_open=160 -D door_angle=105 -o ../images/assembly_open.png \
    --imgsize=1400,1100 --viewall --autocenter --camera=0,0,0,62,0,28,0 --colorscheme=Tomorrow assembly.scad
run -q -D show_side=true -o ../images/assembly_back.png --imgsize=1400,1100 --viewall --autocenter \
    --camera=0,0,0,70,0,200,0 --colorscheme=Tomorrow assembly.scad
run -q -D show_panels=false -D show_fronts=false -D show_printed=false -D show_water=false \
    -o ../images/assembly_wiring.png --imgsize=1400,1100 --viewall --autocenter \
    --camera=0,0,0,60,0,215,0 --colorscheme=Tomorrow assembly.scad
run -q -D show_panels=false -D show_fronts=false -D show_wiring=false -o ../images/assembly_internals.png --imgsize=1400,1100 \
    --viewall --autocenter --camera=0,0,0,65,0,330,0 --colorscheme=Tomorrow assembly.scad
echo "renders written to images/"

# Interactive viewer page data (assembly + part models, BOM json) in ../viewer/
python3 export_viewer.py
