"""Build the files for the interactive 3D viewer and BOM page in ../viewer/.

- assembly.glb: the full assembly, one node per colour group (so the page
  can hide the cabinet, show the water path, etc.)
- part_<name>.glb: each printed insert and the CNC heater block, on its own
- bom.json: bom.csv plus category and link labels for the page

Needs openscad and python3 with trimesh. Run after exports/build.sh, since
the heater block STL comes from trim_heater_block.py.
Units: mm (the viewer scales to metres for three.js).
"""
import csv
import json
import re
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import numpy as np
import trimesh

SRC = Path(__file__).resolve().parent
PROJ = SRC.parent
OUT = PROJ / "viewer"
EXPORTS = PROJ / "exports"

# Colour (as OpenSCAD prints it) -> group label shown in the viewer.
GROUPS = {
    "[0.82, 0.68, 0.48]": "Cabinet",
    "[0.74, 0.6, 0.42]": "Cabinet",
    "[0.25, 0.25, 0.27]": "Printed inserts (PA12)",
    "[0.3, 0.55, 0.8]": "Electronics tray (PETG)",
    "[0.85, 0.3, 0.2]": "Trim heater block",
    "[0.95, 0.95, 0.9, 0.25]": "Heater insulation",
    "[0.35, 0.65, 0.95]": "Water path",
    "[0.75, 0.77, 0.8]": "Stainless and kettle",
    "[0.2, 0.2, 0.2]": "Stainless and kettle",
    "[0.9, 0.9, 0.95, 0.85]": "V60 and carafe",
    "[0.85, 0.92, 0.95, 0.6]": "V60 and carafe",
    "[0.7, 0.7, 0.72]": "Load cells",
    "[0.15, 0.15, 0.15]": "Pump and motors",
    "[0.1, 0.1, 0.1]": "Pump and motors",
    "[0.1, 0.5, 0.2]": "Electronics",
    "[0.8, 0.1, 0.1]": "Buttons and LED ring",
    "[0.86, 0.72, 0.52]": "Door and drawer fronts",
    "[0.78, 0.62, 0.28]": "Brass buttons",
    "[1, 0.86, 0.6]": "LED glow",
    "[0.82, 0.83, 0.85]": "Slides and LED channel",
    "[0.95, 0.55, 0.15]": "Sensors",
    "[0.12, 0.3, 0.6]": "Electronics",
    "[0.08, 0.08, 0.1]": "Electronics",
    "[0.6, 0.1, 0.5]": "Electronics",
    "[0.4, 0.4, 0.45]": "Power hardware (relay, fuse, DC jack)",
    "[0.18, 0.18, 0.2]": "Kettle relay outlet (mains, listed)",
    "[0.85, 0.2, 0.15]": "Wiring: 24 V and heater power",
    "[0.95, 0.8, 0.2]": "Wiring: sensors",
    "[0.5, 0.35, 0.7]": "Wiring: steppers",
    "[0.2, 0.75, 0.8]": "Wiring: switches, buttons, LEDs",
    "[0.92, 0.92, 0.92]": "Wiring: mains cords",
}

PARTS = {
    "drawer_tray": "Cone drawer tray",
    "nozzle_shroud": "Nozzle shroud",
    "drip_tray": "Drip tray",
    "drip_grate": "Drip grate",
    "carafe_platform": "Carafe scale platform",
    "kettle_platform": "Kettle scale platform",
    "lc_spacer": "Load-cell spacer",
    "electronics_tray": "Electronics tray",
    "pump_cradle": "Pump cradle",
}


def rgba(colour: str):
    v = [float(x) for x in colour.strip("[]").split(",")]
    if len(v) == 3:
        v.append(1.0)
    return [int(round(c * 255)) for c in v]


def openscad(args, out):
    subprocess.run(["openscad", "-q", *args, "-o", str(out)],
                   cwd=SRC, check=True, capture_output=True)


def load(path, colour):
    m = trimesh.load(path, force="mesh")
    m.visual = trimesh.visual.ColorVisuals(m, face_colors=np.tile(colour, (len(m.faces), 1)))
    return m


def build_assembly(tmp: Path, name="assembly", extra=()):
    listing = subprocess.run(
        ["openscad", "-D", 'pick="__list__"', "-D", "show_side=true", *extra,
         "-o", str(tmp / "list.csg"), "assembly.scad"],
        cwd=SRC, check=True, capture_output=True, text=True).stderr
    colours = sorted(set(re.findall(r'PAINT\|([^"]+)"', listing)))
    missing = [c for c in colours if c not in GROUPS]
    if missing:
        raise SystemExit(f"add these colours to GROUPS: {missing}")

    def one(i_c):
        i, c = i_c
        stl = tmp / f"{name}_c{i}.stl"
        openscad(["-D", f'pick="{c}"', "-D", "show_side=true", *extra, "assembly.scad"], stl)
        return c, stl

    with ThreadPoolExecutor(8) as ex:
        done = list(ex.map(one, enumerate(colours)))

    # glTF exporters sanitise names, so nodes get plain ids and the labels and
    # colours go in a sidecar JSON the viewer reads.
    scene = trimesh.Scene()
    meta = {}
    for i, (c, stl) in enumerate(done):
        node = f"g{i}"
        scene.add_geometry(load(stl, rgba(c)), node_name=node, geom_name=node)
        meta[node] = {"label": GROUPS[c], "rgba": [x / 255 for x in rgba(c)]}
    scene.export(OUT / f"{name}.glb")
    json.dump(meta, open(OUT / f"{name}_groups.json", "w"), indent=1)


def build_parts():
    pa12 = rgba("[0.32, 0.32, 0.35]")
    for name in PARTS:
        m = load(EXPORTS / f"{name}.stl", pa12 if name != "electronics_tray" else rgba("[0.3, 0.55, 0.8]"))
        trimesh.Scene(m).export(OUT / f"part_{name}.glb")
    m = load(EXPORTS / "trim_heater_block_preview.stl", rgba("[0.78, 0.80, 0.83]"))
    trimesh.Scene(m).export(OUT / "part_trim_heater_block.glb")


CATEGORIES = [
    ("Water and heat", ["kettle", "outlet", "pump", "flow meter", "tube", "tubing", "tee",
                        "heater", "cutout", "heater block", "insulation", "v60"]),
    ("Sensing", ["pt1000", "max31865", "ntc", "load cell", "hx711", "tof", "reed"]),
    ("Control and motion", ["esp32", "stepper", "tmc2209", "mosfet", "nozzle mechanism",
                            "power supply", "buck", "dc jack", "button", "relay", "level shifter", "wire", "cable", "grommet", "sleeving"]),
    ("Body, doors and lighting", ["plywood", "oil", "printed", "fasteners", "hinge", "forstner", "latch", "slides", "led strip", "led channel"]),
]


def category(item: str) -> str:
    low = item.lower()
    for cat, keys in CATEGORIES:
        if any(k in low for k in keys):
            return cat
    return "Other"


def build_bom():
    rows = list(csv.DictReader(open(PROJ / "bom.csv", newline="")))
    for r in rows:
        r["category"] = category(r["item"])
        r["link_kind"] = r.get("link_type") or "Product"
    json.dump(rows, open(OUT / "bom.json", "w"), indent=1)


def main():
    OUT.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory() as t:
        build_assembly(Path(t))
        build_assembly(Path(t), "assembly_open", ("-D", "drawer_open=160", "-D", "door_angle=105"))
    build_parts()
    build_bom()
    # Artifact pages don't serve .glb, so ship each model as base64 text too.
    import base64
    for glb in OUT.glob("*.glb"):
        (OUT / (glb.name + ".b64.txt")).write_text(base64.b64encode(glb.read_bytes()).decode())
    for p in sorted(OUT.glob("*")):
        print(f"{p.stat().st_size/1e6:7.2f} MB  {p.name}")


if __name__ == "__main__":
    main()
