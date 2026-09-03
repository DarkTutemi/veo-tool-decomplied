import marshal
import sys

def dump_code(co, indent=0, max_depth=3):
    prefix = "  " * indent
    if indent > max_depth:
        return
    try:
        print(f"{prefix}code: {getattr(co, 'co_name', '?')}")
        print(f"{prefix}  filename: {getattr(co, 'co_filename', '?')}")
        print(f"{prefix}  varnames: {getattr(co, 'co_varnames', ())}")
        print(f"{prefix}  names: {getattr(co, 'co_names', ())}")
        print(f"{prefix}  nlocals: {getattr(co, 'co_nlocals', 0)}")
        consts = getattr(co, 'co_consts', ())
        print(f"{prefix}  consts ({len(consts)}):")
        for i, c in enumerate(consts[:20]):
            if isinstance(c, type(co)):
                print(f"{prefix}    [{i}]")
                dump_code(c, indent + 2, max_depth)
            elif isinstance(c, bytes):
                print(f"{prefix}    [{i}] bytes (len={len(c)})")
            elif isinstance(c, tuple):
                items = [repr(x)[:40] for x in c[:5]]
                print(f"{prefix}    [{i}] tuple({len(c)}): {items}")
            else:
                print(f"{prefix}    [{i}] {repr(c)[:80]}")
    except Exception as e:
        print(f"{prefix}  ERROR: {e}")

# Load main.pyc
target = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\main.pyc"
with open(target, "rb") as f:
    data = f.read()

co = marshal.loads(data[16:])
print("=" * 60)
print("STRUCTURE OF main.pyc")
print("=" * 60)
dump_code(co, max_depth=5)