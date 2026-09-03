import marshal, os, dis, sys

base = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\PYZ.pyz_extracted"
out = r"H:\veo-tool\decompiled\sources"

def fully_decompile(co, out_file, indent=0):
    """Write a human-readable representation of a code object"""
    prefix = "    " * indent
    out_file.write(f"{prefix}# === {co.co_name} (file: {co.co_filename}) ===\n")
    out_file.write(f"{prefix}def {co.co_name}({', '.join(co.co_varnames[:co.co_nlocals])}):\n")
    
    # Try to disassemble
    try:
        # Write bytecode instructions
        import dis
        # Capture dis output
        from io import StringIO
        sio = StringIO()
        dis.dis(co, file=sio)
        lines = sio.getvalue().split('\n')
        for line in lines:
            if line.strip():
                out_file.write(f"{prefix}    # {line.strip()}\n")
    except Exception as e:
        out_file.write(f"{prefix}    # [disassembly error: {e}]\n")
    
    out_file.write(f"{prefix}    # locals: {co.co_varnames}\n")
    out_file.write(f"{prefix}    # names: {co.co_names}\n")
    out_file.write(f"{prefix}    # consts count: {len(co.co_consts)}\n")
    
    # Recurse into nested code objects
    for i, c in enumerate(co.co_consts):
        if isinstance(c, type(co)):
            out_file.write("\n")
            fully_decompile(c, out_file, indent + 1)
    
    out_file.write("\n")

# 1. Decompile build_validation.pyc
src = os.path.join(base, "build_validation.pyc")
with open(src, "rb") as f:
    data = f.read()
co = marshal.loads(data[16:])

with open(os.path.join(out, "build_validation.py"), "w", encoding="utf-8") as f:
    fully_decompile(co, f)
print(f"Done: build_validation.py ({len(co.co_consts)} consts, {len(co.co_names)} names)")

# 2. Check eng_to_ipa
eng_dir = os.path.join(base, "eng_to_ipa")
if os.path.isdir(eng_dir):
    print(f"\neng_to_ipa directory found:")
    for root, dirs, files in os.walk(eng_dir):
        for f in files:
            if f.endswith('.pyc'):
                p = os.path.join(root, f)
                rel = os.path.relpath(p, eng_dir)
                with open(p, 'rb') as fp:
                    d = fp.read()
                try:
                    co2 = marshal.loads(d[16:])
                    has_pyarmor = False
                    for c2 in co2.co_consts:
                        if isinstance(c2, tuple) and len(c2) == 1 and c2[0] == '__pyarmor__':
                            has_pyarmor = True
                    tag = "PYARMOR" if has_pyarmor else "OK"
                    print(f"  [{tag}] {rel}: {co2.co_name}, names={len(co2.co_names)}, consts={len(co2.co_consts)}")
                except Exception as e:
                    print(f"  [ERR] {rel}: {e}")
else:
    # Check if it's a single .pyc
    eng_pyc = os.path.join(base, "eng_to_ipa.pyc")
    if os.path.exists(eng_pyc):
        print("eng_to_ipa is a single .pyc file")
        with open(eng_pyc, 'rb') as fp:
            d = fp.read()
        co2 = marshal.loads(d[16:])
        print(f"  co_name: {co2.co_name}")
        print(f"  co_names: {co2.co_names[:20]}")
        print(f"  consts: {len(co2.co_consts)}")
    else:
        # Check top-level and real directory
        real_eng = r"H:\veo-tool\eng_to_ipa"
        if os.path.isdir(real_eng):
            print(f"\neng_to_ipa at top-level:")
            for root, dirs, files in os.walk(real_eng):
                for f in files:
                    if f.endswith('.py'):
                        rel = os.path.relpath(os.path.join(root, f), real_eng)
                        print(f"  {rel}")