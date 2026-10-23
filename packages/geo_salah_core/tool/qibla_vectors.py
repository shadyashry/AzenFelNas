"""Writes test/qibla/qibla_vectors.json: Qibla golden vectors (REQ-DOM-030).

Reference: GeographicLib 2.0 (Python, MIT), Geodesic.WGS84.Inverse, the
reference implementation of Karney (2013). Run from the package root:

    uv run --no-project --with geographiclib==2.0 python tool/qibla_vectors.py
"""

import glob
import json
import random

from geographiclib.geodesic import Geodesic

KAABA = (21.422487, 39.826206)


def vector(name, lat, lon):
    g = Geodesic.WGS84.Inverse(lat, lon, KAABA[0], KAABA[1])
    azi = g["azi1"] % 360.0 if g["s12"] != 0 else 0.0
    return {"name": name, "lat": lat, "lon": lon, "bearingDeg": azi, "distanceM": g["s12"]}


def main():
    out = []
    seen = set()
    for path in sorted(glob.glob("test/golden/*/*/*.json")):
        city = path.split("/")[2]
        if city in seen:
            continue
        seen.add(city)
        obs = json.load(open(path))["observer"]
        out.append(vector(city, obs["latitudeDeg"], obs["longitudeDeg"]))
    anti = (-KAABA[0], KAABA[1] - 180.0)
    edges = [
        ("kaaba", KAABA[0], KAABA[1]),
        ("kaaba_100m_north", KAABA[0] + 0.0009, KAABA[1]),
        ("north_pole", 90.0, 0.0),
        ("south_pole", -90.0, 0.0),
        ("equator_date_line", 0.0, 180.0),
        ("same_meridian_south", -30.0, KAABA[1]),
        ("papeete", -17.5516, -149.5585),
        ("near_antipode_1", anti[0] + 0.5, anti[1] + 0.5),
        ("near_antipode_2", anti[0] - 0.3, anti[1] - 1.2),
        ("near_antipode_3", anti[0] + 0.01, anti[1]),
        ("near_antipode_4", anti[0] - 2.0, anti[1] + 3.0),
    ]
    out += [vector(*e) for e in edges]
    rng = random.Random(20261023)
    for i in range(200):
        lat = round(rng.uniform(-89.9, 89.9), 6)
        lon = round(rng.uniform(-180.0, 180.0), 6)
        out.append(vector(f"random_{i:03d}", lat, lon))
    with open("test/qibla/qibla_vectors.json", "w") as f:
        json.dump({"reference": "GeographicLib 2.0 Geodesic.WGS84.Inverse",
                   "kaaba": {"lat": KAABA[0], "lon": KAABA[1], "refVersion": "2026.1"},
                   "vectors": out}, f, indent=1)
        f.write("\n")
    print(len(out))


main()
