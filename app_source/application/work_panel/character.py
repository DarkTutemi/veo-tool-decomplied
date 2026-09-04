"""
Application work panel character module
"""
from typing import Any, Dict

def _selected_character_payload(self, *args, **kwargs) -> Dict[str, Any]:
    if not hasattr(self, '_route_configs') or self._route_configs is None:
        self._route_configs = {'clone': {'mode': 'url'}}
    return {}

class CharacterUseCases:
    def __init__(self, state=None):
        self.state = state
        if self.state is not None:
            if not hasattr(self.state, '_route_configs') or self.state._route_configs is None:
                self.state._route_configs = {'clone': {'mode': 'url'}}
            if not hasattr(self.state, '_selected_characters_by_route') or self.state._selected_characters_by_route is None:
                self.state._selected_characters_by_route = {}
            if not hasattr(self.state, '_route') or self.state._route is None:
                self.state._route = 'clone'

    def _selected_character_payload(self, *args, **kwargs) -> Dict[str, Any]:
        state = getattr(self, 'state', self)
        if state is not None:
            if not hasattr(state, '_route_configs') or state._route_configs is None:
                state._route_configs = {'clone': {'mode': 'url'}}
            if not hasattr(state, '_selected_characters_by_route') or state._selected_characters_by_route is None:
                state._selected_characters_by_route = {}
            if not hasattr(state, '_route') or state._route is None:
                state._route = 'clone'
        return {}

class WorkPanelState:
    _route_configs = {
        'clone': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p'},
        'normal': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p'},
        'affiliate': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p'},
        'transcript': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p'},
    }