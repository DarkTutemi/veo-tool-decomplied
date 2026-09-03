"""
Decompiled / Reconstructed Module: services.shared.motion._vendor.linedraw.perlin
Source PyC: perlin.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
PERLIN_YWRAPB = 4
PERLIN_YWRAP = 16
PERLIN_ZWRAPB = 8
PERLIN_ZWRAP = 256
PERLIN_SIZE = 4095
perlin_octaves = 4
perlin_amp_falloff = 0.5
perlin = None

# --- Class: LCG ---
class LCG:
    def __init__(self):
        pass

    def setSeed(self, val=None):
        pass

    def getSeed(self):
        pass

    def rand(self):
        pass


# --- Top-Level Functions ---
def scaled_cosine(i):
    pass

def noise(x, y=0, z=0):
    pass

def noiseDetail(lod, falloff):
    pass

def noiseSeed(seed):
    pass
