# Binary layout of the `tz_polygons` package payload (DESIGN.md §9.5, ADR-015).
# Source: timezone-boundary-builder (ODbL), simplified with Douglas-Peucker 0.001°.
# `country_polygons.v1.ksy` is the same layout with magic "CTPG" and ISO 3166-1 alpha-2 names.
# Layout details beyond §9.5 are recorded in DESIGN.md §15 D23.
meta:
  id: tz_polygons_v1
  title: Azen Fel Nas time-zone polygon index v1
  file-extension: bin
  endian: le
  encoding: UTF-8
doc: |
  Point-in-polygon index. A lookup takes the 1°×1° cell of the point, tests only the polygons listed
  for that cell, and returns the name of the first polygon that contains the point (holes excluded).
  Coordinates are integer micro-degrees (1e-6°), longitude first.
seq:
  - id: magic
    contents: "TZPG"
  - id: version
    type: u2
    valid: 1
  - id: count
    type: u4
    doc: Number of entries in the name table (zones).
  - id: names
    type: name
    repeat: expr
    repeat-expr: count
  - id: polygon_count
    type: u4
  - id: grid
    type: grid
  - id: polygons
    type: polygon
    repeat: expr
    repeat-expr: polygon_count
types:
  name:
    seq:
      - id: len
        type: u1
      - id: value
        type: str
        size: len
        doc: IANA zone id, e.g. "Africa/Cairo".
  grid:
    doc: |
      360 × 180 cells. Cell index = (floor(lat) + 90) * 360 + (floor(lon) + 180), with lat = 90 mapped
      to row 179 and lon = 180 mapped to column 359. Polygon ids of cell i are
      ids[offsets[i] .. offsets[i + 1]).
    seq:
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: 64801
      - id: ids
        type: u4
        repeat: expr
        repeat-expr: offsets[64800]
  polygon:
    seq:
      - id: name_index
        type: u4
        doc: Index into the name table.
      - id: min_lon
        type: s4
      - id: min_lat
        type: s4
      - id: max_lon
        type: s4
      - id: max_lat
        type: s4
      - id: ring_count
        type: u2
        doc: Ring 0 is the outer boundary; rings 1.. are holes.
      - id: rings
        type: ring
        repeat: expr
        repeat-expr: ring_count
  ring:
    doc: |
      Closed ring (the last point equals the first). Each point is a delta from the previous point;
      the first point is a delta from (0, 0), i.e. absolute.
    seq:
      - id: point_count
        type: u4
      - id: deltas
        type: delta
        repeat: expr
        repeat-expr: point_count
  delta:
    seq:
      - id: d_lon
        type: s4
      - id: d_lat
        type: s4
