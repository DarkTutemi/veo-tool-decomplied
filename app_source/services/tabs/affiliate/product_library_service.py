"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_library_service
Source PyC: product_library_service.pyc

Docstring:
Headless product library service for affiliate products.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
PRODUCT_CATEGORIES = [('cosmetics', 'Mỹ phẩm'), ('fashion', 'Thời trang'), ('electronics', 'Điện tử'), ('home', 'Gia dụng'), ('food', 'Thực phẩm'), ('sports', 'Thể thao'), ('beauty', 'Làm đẹp'), ('health', 'Sức khỏe'), ('... [truncated]
CSV_TEMPLATE_ROWS = [['name', 'category', 'price', 'description', 'image_path', 'key_features'], ['Nike Air Max 90', 'shoes', '120', 'Premium sport shoes', 'C:\\images\\nike.jpg', 'Air cushion;Lightweight;Durable'], ['Q1... [truncated]
_VALID_CATEGORIES = {'sports', 'beauty', 'food', 'health', 'home', 'fashion', 'baby', 'other', 'electronics', 'cosmetics'}
_MAX_PRODUCT_IMAGES = 10
_PRODUCT_FIELDS = {'discount', 'sell_angle', 'sold', 'pain_point', 'prep_status', 'rating', 'source_paths', 'name', 'uses', 'extra_image_ids', 'browser_account', 'brand', 'price', 'affiliate_link', 'shopee_item_id', 't... [truncated]

# --- Class: ProductLibraryService ---
class ProductLibraryService:
    """Facade for product library actions without UI or IPC dependencies."""
    def __init__(self) -> 'None':
        pass

    def list_products(self, category: 'str' = '', search: 'str' = '', product_ids: 'Optional[List[str]]' = None) -> 'Dict[str, Any]':
        pass

    def import_csv(self, path: 'str' = '', rows: 'Optional[List[Dict[str, Any]]]' = None, content: 'str' = '', import_images: 'bool' = True) -> 'Dict[str, Any]':
        pass

    def preview_csv(self, path: 'str' = '', content: 'str' = '') -> 'Dict[str, Any]':
        pass

    def download_template(self, save_path: 'str' = '') -> 'Dict[str, Any]':
        pass

    def manage(self, action: 'str', product: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _first(row: 'Dict[str, Any]', *keys: 'str') -> 'str':
    pass

def _features(value: 'Any') -> 'List[str]':
    pass

def _price(value: 'Any') -> 'str':
    pass

def _category(value: 'Any') -> 'str':
    pass

def _stage_image(image_path: 'str') -> 'List[str]':
    pass

def _normalize_product(row: 'Dict[str, Any]', import_images: 'bool' = True) -> 'Optional[Dict[str, Any]]':
    pass

def _csv_content(rows: 'Iterable[Iterable[Any]]') -> 'str':
    pass

def _read_csv(path: 'str') -> 'List[Dict[str, Any]]':
    pass

def get_product_library_service() -> 'ProductLibraryService':
    pass
