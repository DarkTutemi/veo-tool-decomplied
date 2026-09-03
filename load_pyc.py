import struct
import marshal
import sys

target = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\main.pyc"

with open(target, "rb") as f:
    data = f.read()

print("Total size:", len(data))
print("Header (16):", data[:16].hex(" "))

# Python 3.13 header: magic(4) + flags(4) + hash(8)
# Code object follows at offset 16
code_start = 16
print("Code object signature at 16:", hex(data[16]))

# Try loading the code object with marshal
try:
    co = marshal.loads(data[code_start:])
    print("Code object loaded successfully!")
    print("Type:", type(co))
    print("co_filename:", getattr(co, "co_filename", None))
    print("co_name:", getattr(co, "co_name", None))
    print("co_firstlineno:", getattr(co, "co_firstlineno", None))
    print("Number of constants:", len(co.co_consts))
    for i, c in enumerate(co.co_consts[:10]):
        if isinstance(c, type(co)):
            print(f"  const[{i}] code object: {c.co_name}")
        else:
            print(f"  const[{i}]: {repr(c)[:80]}")
except Exception as e:
    print(f"marshal load failed: {type(e).__name__}: {e}")
