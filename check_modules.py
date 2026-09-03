import marshal
import os

base = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\PYZ.pyz_extracted"
custom_modules = ["api", "application", "build_validation", "config", "core", "eng_to_ipa", "license", "managers", "models", "qml_app", "services", "update", "utils", "veoflow_res"]

for mod in custom_modules:
    mod_path = os.path.join(base, mod, "__init__.pyc")
    if not os.path.exists(mod_path):
        mod_path = os.path.join(base, mod + ".pyc")
    if not os.path.exists(mod_path):
        print(f"{mod}: NOT FOUND")
        continue
    
    with open(mod_path, "rb") as f:
        data = f.read()
    
    try:
        co = marshal.loads(data[16:])
        consts = co.co_consts
        has_pyarmor = False
        for c in consts:
            if isinstance(c, tuple) and len(c) == 1 and c[0] == "__pyarmor__":
                has_pyarmor = True
        if has_pyarmor:
            print(f"{mod}: PYARMOR PROTECTED")
        else:
            print(f"{mod}: UNPROTECTED - names={co.co_names[:10]}, consts_count={len(consts)}")
    except Exception as e:
        print(f"{mod}: ERROR {e}")