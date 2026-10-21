# geo_salah_core

Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState, provenance and PrayerProfile value types (DESIGN.md §6).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `calculation_trace.v1` wire model and shared wire codes since S02. Since S04 it also holds the astronomical core: `lib/src/astro/` (SPA from Reda & Andreas 2008, Espenak–Meeus ΔT, the §6.4 ¶2 interpolated day model) and `lib/src/solver/` (Brent, monotone-piece brackets, ADR-004 culmination segments). These are internal until S05 exposes `GeoSalahEngine`.
