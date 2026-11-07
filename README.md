# creations

Designs, prototypes and builds for physical projects: parametric CAD, fabrication exports, bills of materials and build notes.

## Layout

```
creations/
├── _template/          # copy this to start a new project
│   ├── README.md       # build notes: goal, dimensions, decisions, steps
│   ├── bom.csv         # bill of materials with sources and costs
│   ├── src/            # parametric source (.scad or CadQuery .py)
│   ├── exports/        # STL / STEP / DXF / 3MF sent to fab services
│   └── images/         # photos, renders, sketches
└── <project-name>/     # one folder per project, kebab-case
```

Start a project with `cp -r _template my-project`.

## Conventions

- **Units:** millimetres. Add imperial in notes where it helps with tape measures or lumber stock.
- **CAD:** OpenSCAD by default. CadQuery when STEP output is needed for machining. Blender only for organic or visual work.
- **Exports:** STL/3MF for printing, STEP for CNC, DXF for laser and sheet cutting. Exports are regenerated from `src/`, so the source file is the truth.
- **Fabrication:** outsourced (JLC3DP, Craftcloud, Xometry, SendCutSend, PCBWay). Note each service's tolerances and minimum feature sizes in the project README.
- **In-house tools:** circular saw, radial arm saw, table saw, drills, impact drivers. Mark which parts can be made at home.

## Large files

STL, STEP, 3MF and similar binaries are stored with [Git LFS](https://git-lfs.com) (see `.gitattributes`). Run `git lfs install` once per machine before cloning.
