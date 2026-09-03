"""
Decompiled / Reconstructed Module: services.shared.routing.genre_packs
Source PyC: genre_packs.pyc

Docstring:
Genre packs — per-vertical prompt overrides for the Master Prompt architect.

A genre pack is a curated prompt bundle for ONE fixed content vertical
(short drama, Buddhist dharma, agriculture, cinematic film...). The user picks
it explicitly in the Master "Dòng nội dung" dropdown (persisted as the legacy
``template_name`` config key — the old dead "storytelling" slot, now revived).

Contract with the script architect:
- ONLY the creative guidance changes: the "YOU ARE" persona line, plus one
  inserted "# GENRE PACK" block (story formula + per-scene craft + must/never).
- The machine-facing output contract (RESOURCE_PLAN_JSON shape, <SCRIPT> scene
  fields, entity_library, narrator, voice lock, library control, publish kit)
  stays byte-identical to the Auto path. Unknown/legacy ids ("storytelling",
  "" ...) resolve to NO pack → the prompt is exactly what it was before.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
GENRE_PACKS = {'short_drama': GenrePack(id='short_drama', label='Short Drama (phim ngắn kịch tính)', persona='A veteran vertical-drama showrunner who writes binge-worthy short episodes: every scene is a beat that r... [truncated]
LEGACY_TEMPLATE_IDS = frozenset({'storytelling'})

# --- Class: GenrePack ---
class GenrePack:
    """GenrePack(id: 'str', label: 'str', persona: 'str', formula: 'str', craft_rules: 'List[str]' = <factory>, must_include: 'List[str]' = <factory>, never: 'List[str]' = <factory>, tone: 'str' = '', content_domain: 'str' = '', suggested_content_type: 'str' = 'narrative')"""
    tone = ''
    content_domain = ''
    suggested_content_type = 'narrative'

    def __init__(self, id: 'str', label: 'str', persona: 'str', formula: 'str', craft_rules: 'List[str]' = <factory>, must_include: 'List[str]' = <factory>, never: 'List[str]' = <factory>, tone: 'str' = '', content_domain: 'str' = '', suggested_content_type: 'str' = 'narrative') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def resolve_genre_pack(genre_id: 'Any') -> 'Optional[GenrePack]':
    pass

def genre_pack_options() -> 'List[Dict[str, str]]':
    pass

def format_genre_pack_block(pack: 'GenrePack') -> 'str':
    """Prompt block inserted into the architect prompt for the selected pack."""
    pass

def apply_genre_to_domain_profile(profile: 'Dict[str, Any]', pack: 'GenrePack') -> 'Dict[str, Any]':
    pass
