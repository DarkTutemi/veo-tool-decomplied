#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script: compile_and_replace.py
Description:
    1. Compiles patched .py files from decompiled/app_source/license/ to .pyc (Python 3.12 bytecode).
    2. Backs up original .pyc files in PYZ.pyz_extracted/license/.
    3. Overwrites PYZ.pyz_extracted/license/ with the newly compiled .pyc files.
    4. Tests importing and executing the license check in the unpacked environment.
"""

import os
import sys
import shutil
import py_compile
from pathlib import Path

# Force UTF-8 on Windows console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent
SRC_LICENSE_DIR = BASE_DIR / "decompiled" / "app_source" / "license"
DEST_LICENSE_DIR = BASE_DIR / "unpack-veotool" / "VEOFLOWPROMAX.exe_extracted" / "PYZ.pyz_extracted" / "license"
BACKUP_DIR = BASE_DIR / "unpack-veotool" / "VEOFLOWPROMAX.exe_extracted" / "PYZ.pyz_extracted" / "license_backup"

print("=" * 65)
print("🔨 RECOMPILING PATCHED LICENSE MODULES & REPLACING .PYC")
print("=" * 65)

# Step 1: Backup original .pyc files if not already backed up
if not BACKUP_DIR.exists():
    print(f"\n📦 [1/4] Creating backup of original .pyc files at: {BACKUP_DIR.name}")
    shutil.copytree(DEST_LICENSE_DIR, BACKUP_DIR)
    print("  ✅ Backup completed.")
else:
    print(f"\n📦 [1/4] Backup already exists at: {BACKUP_DIR.name}")

# Step 2: Compile patched .py files to .pyc directly into destination
print(f"\n⚙️  [2/4] Compiling .py files to Python 3.12 .pyc...")
modules = [
    "__init__",
    "license_manager",
    "main_license_client",
    "unified_license_client",
    "hardware_key_derivation",
    "secure_memory",
    "main_api_client"
]

compiled_count = 0
for mod in modules:
    src_py = SRC_LICENSE_DIR / f"{mod}.py"
    dest_pyc = DEST_LICENSE_DIR / f"{mod}.pyc"

    if not src_py.exists():
        print(f"  ⚠️ Warning: {src_py.name} does not exist, skipping.")
        continue

    # Compile with Python 3.12 py_compile
    try:
        py_compile.compile(str(src_py), cfile=str(dest_pyc), doraise=True)
        size_kb = dest_pyc.stat().st_size / 1024
        print(f"  ✅ Compiled {src_py.name} -> {dest_pyc.name} ({size_kb:.1f} KB)")
        compiled_count += 1
    except Exception as e:
        print(f"  ❌ Error compiling {src_py.name}: {e}")
        sys.exit(1)

# Also copy the .py files alongside .pyc for full source transparency
print(f"\n📋 [3/4] Copying patched .py source files to destination...")
for mod in modules:
    src_py = SRC_LICENSE_DIR / f"{mod}.py"
    dest_py = DEST_LICENSE_DIR / f"{mod}.py"
    if src_py.exists():
        shutil.copy2(src_py, dest_py)
print(f"  ✅ Copied {compiled_count} source files to {DEST_LICENSE_DIR.name}")

# Step 4: Verification test inside unpacked environment
print(f"\n🧪 [4/4] Testing license check in unpacked runtime environment...")

# Add DLL directory and paths matching the application environment
extracted_dir = BASE_DIR / "unpack-veotool" / "VEOFLOWPROMAX.exe_extracted"
pyz_dir = extracted_dir / "PYZ.pyz_extracted"

os.add_dll_directory(str(BASE_DIR))
if (pyz_dir / "numpy.libs").exists():
    os.add_dll_directory(str(pyz_dir / "numpy.libs"))

sys.path.insert(0, str(extracted_dir))
sys.path.insert(0, str(pyz_dir))

# Mock missing tab services for headless execution if needed
from reconstruct_key_modules import FlexibleModule, missing_tab_services
for m in missing_tab_services:
    if m not in sys.modules:
        sys.modules[m] = FlexibleModule(m)

# Import from the replaced license package
import license
import license.license_manager as lm_mod

lm = lm_mod.get_license_manager()
lm.configure(license_key="TEST-LIFETIME-KEY", device_id="TEST-MACHINE-ID")
success, info = lm.verify_license()

print("=" * 65)
print("📊 RUNTIME VERIFICATION RESULTS:")
print(f"  • verify_license() success : {success}")
print(f"  • License Tier             : {info.get('tier')}")
print(f"  • License Type             : {info.get('license_type')}")
print(f"  • Status                   : {info.get('status')}")
print(f"  • Features                 : {info.get('features')}")
print(f"  • Expiration Date          : {info.get('expires_at')}")
print(f"  • Remaining Quota          : {info.get('remaining_count')}")
print(f"  • FeatureGate('render_4k') : {lm.feature_gate.has('render_4k')}")
print(f"  • FeatureGate('master_ai') : {lm.feature_gate.has('master_ai')}")
print("=" * 65)

assert success is True, "verify_license() must return True"
assert info.get("tier") == "PREMIUM", "Tier must be PREMIUM"
assert lm.feature_gate.has("render_4k") is True, "FeatureGate must permit render_4k"

print("🎉 ALL RECOMPILED .PYC FILES WORK 100% PERFECTLY IN UNPACKED RUNTIME!")
print("=" * 65)
