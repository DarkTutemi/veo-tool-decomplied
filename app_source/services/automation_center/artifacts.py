"""
Decompiled / Reconstructed Module: services.automation_center.artifacts
Source PyC: artifacts.pyc

Docstring:
Local artifact verification for Automation Center runs.

Hashing is intentionally synchronous.  Callers must invoke it from the single
Automation Center worker lane rather than from the Qt GUI thread.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['revalidate_frozen_publish_artifacts', 'verify_required_artifacts']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Sequence = typing.Sequence
_HASH_CHUNK_BYTES = 1048576
_SHA256_RE = re.compile('^[0-9a-f]{64}$')
_PUBLISH_REQUIRED_KINDS = frozenset({'publish_metadata', 'video'})
_PUBLISH_COVER_KINDS = frozenset({'thumbnail', 'cover'})
__all__ = ['revalidate_frozen_publish_artifacts', 'verify_required_artifacts']

# --- Top-Level Functions ---
def verify_required_artifacts(artifacts: 'Sequence[ArtifactCandidate]') -> 'tuple[dict[str, Any], ...]':
    """Validate and SHA-256 hash every required local artifact.

    The returned manifest is local evidence, not a remote-upload receipt.  A
    file must remain the same size and modification time throughout hashing;
    otherwise the run is left for reconciliation instead of being marked
    complete against a moving output."""
    pass

def _verify_artifact(candidate: 'ArtifactCandidate') -> 'dict[str, Any]':
    pass

def revalidate_frozen_publish_artifacts(artifacts: 'Sequence[Mapping[str, Any]]') -> 'dict[str, dict[str, Any]]':
    pass

def _revalidate_frozen_artifact(artifact: 'Mapping[str, Any]', *, expected_kind: 'str') -> 'dict[str, Any]':
    pass

def _publish_manifest_error(message: 'str', **details: 'Any') -> 'WorkerControlError':
    pass

def _publish_artifact_changed(kind: 'str', path: 'Path', **details: 'Any') -> 'WorkerControlError':
    pass
