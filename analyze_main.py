import marshal
import dis

target = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\main.pyc"

with open(target, "rb") as f:
    data = f.read()

co = marshal.loads(data[16:])

# Dump the bytecode
print("=" * 60)
print("MAIN MODULE - disassembly")
print("=" * 60)
dis.dis(co)

print("\n" + "=" * 60)
print("CONSTANTS")
print("=" * 60)
for i, c in enumerate(co.co_consts):
    if isinstance(c, bytes):
        print(f"  [{i}] bytes (len={len(c)}): {c[:50]}...")
    elif hasattr(c, 'co_code'):
        print(f"  [{i}] code object: {c.co_name}")
        print(f"      varnames: {c.co_varnames}")
        print(f"      names: {c.co_names}")
        print(f"      nlocals: {c.co_nlocals}")
        if c.co_consts:
            print(f"      consts: {[repr(x)[:60] for x in c.co_consts[:10]]}")
    else:
        print(f"  [{i}] {repr(c)[:100]}")