# creations

Physical design repo. One folder per project, copied from `_template/`.

- Units are mm. Give imperial in notes when it helps with lumber or tape measures.
- Default CAD is OpenSCAD in `src/`; use CadQuery when STEP is needed for CNC. Exports go in `exports/` and must be reproducible from `src/`.
- No 3D printer or CNC in-house; design for outsourced services (JLC3DP, Craftcloud, Xometry, SendCutSend, PCBWay) and their tolerances. In-house: circular saw, radial arm saw, table saw, drills, impact drivers.
- Each project delivers: parametric source, exports, `bom.csv` with sources and costs, and build notes in its README.
- STL/STEP/3MF are tracked with Git LFS (`.gitattributes`).
