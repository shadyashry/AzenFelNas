"""Reads the pinned cities15000 records into `gazetteer_package.v1` places (§9.5, §15 D72).

The source keeps GeoNames' `alternatenames` without language tags, so names are chosen by script:

* `ar`: names written only with Arabic letters (U+0621-U+064A, U+0671), harakat, spaces and
  hyphens. Persian, Urdu and Kurdish spellings that need other letters are left out; the ones that
  do not (e.g. «قاهره») stay and are found through the same normalised search key.
* `en`: Latin-script names (Basic Latin, Latin-1 and Latin Extended-A letters, space, `'`, `-`,
  `.`) with at least one capital letter, leaving out codes of four or fewer capitals (IATA codes)
  and GeoNames' lower-case machine transliterations.

`asciiName` is the name with its diacritics removed (NFKD, combining marks dropped, a few letters
spelled out); GeoNames' own `asciiname` column is not in the source.
"""

import json
import re
import unicodedata
import zipfile
from collections.abc import Iterable, Mapping
from pathlib import Path

from dm_pipelines.gazetteer.config import GazetteerSource
from dm_pipelines.hashing import sha256_file
from dm_pipelines.schema.gazetteer_package_v1 import AltNames, ArItem, EnItem, Place
from dm_pipelines.tzdata.source import SourceMismatchError

_ARABIC = re.compile(r"^[\u0621-\u063A\u0641-\u064A\u064B-\u0652\u0670\u0671 \-]+$")
_ARABIC_LETTER = re.compile(r"[\u0621-\u063A\u0641-\u064A\u0671]")
_LATIN = re.compile(r"^[A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u017F '\-.]+$")
_CAPITAL = re.compile(r"[A-Z\u00C0-\u00D6\u00D8-\u00DE]")
_CODE_MAX_LENGTH = 4
_SPELLED_OUT = str.maketrans(
    {
        "ß": "ss",
        "Æ": "AE",
        "æ": "ae",
        "Ø": "O",
        "ø": "o",
        "Œ": "OE",
        "œ": "oe",
        "Đ": "D",
        "đ": "d",
        "Ð": "D",
        "ð": "d",
        "Ł": "L",
        "ł": "l",
        "\u0131": "i",
        "Þ": "Th",
        "þ": "th",
        "\u02bb": "'",
        "\u02bc": "'",
        "\u2019": "'",
    }
)


def read_places(path: Path, source: GazetteerSource) -> list[Place]:
    """Verify `path` against `source` and return its places sorted by GeoNames id."""
    if (actual := sha256_file(path)) != source.sha256:
        message = f"{path.name}: sha256 {actual}, pinned {source.sha256}"
        raise SourceMismatchError(message)
    with zipfile.ZipFile(path) as archive:
        document: Mapping[str, Mapping[str, object]] = json.loads(archive.read(source.zip_member))
    places = [place_of(record) for record in document.values()]
    places.sort(key=lambda place: place.id)
    return places


def place_of(record: Mapping[str, object]) -> Place:
    """Return the place of one geonamescache record; raise `ValueError` when it is malformed."""
    name = str(record["name"]).strip()
    alternates = record["alternatenames"]
    if not isinstance(alternates, list):
        message = f"geonameid {record['geonameid']}: alternatenames is not a list"
        raise TypeError(message)
    names = [str(item).strip() for item in alternates]
    return Place.model_validate(
        {
            "id": record["geonameid"],
            "name": name,
            "asciiName": ascii_name(name),
            "altNames": AltNames(
                ar=[ArItem(item) for item in arabic_names(names)],
                en=[EnItem(item) for item in latin_names(names, exclude=name)],
            ),
            "country": record["countrycode"],
            "admin1": record["admin1code"],
            "lat": record["latitude"],
            "lon": record["longitude"],
            "population": record["population"],
            "zoneId": record["timezone"],
        }
    )


def arabic_names(names: Iterable[str]) -> list[str]:
    """Return the distinct Arabic-letter names in code point order."""
    return sorted(
        {n for n in names if _ARABIC.fullmatch(n) and _ARABIC_LETTER.search(n) is not None}
    )


def latin_names(names: Iterable[str], *, exclude: str) -> list[str]:
    """Return the distinct Latin-script names other than `exclude` in code point order."""
    return sorted(
        {
            n
            for n in names
            if n != exclude
            and _LATIN.fullmatch(n)
            and _CAPITAL.search(n) is not None
            and not (n.isupper() and len(n) <= _CODE_MAX_LENGTH)
        }
    )


def ascii_name(name: str) -> str:
    """Return `name` without diacritics; `name` itself when nothing ASCII is left."""
    decomposed = unicodedata.normalize("NFKD", name.translate(_SPELLED_OUT))
    folded = "".join(c for c in decomposed if c.isascii() and not unicodedata.combining(c))
    folded = " ".join(folded.split())
    return folded or name
