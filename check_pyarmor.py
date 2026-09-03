import marshal

# Load the pyarmor_runtime __init__.pyc
target = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\PYZ.pyz_extracted\pyarmor_runtime_015154\__init__.pyc"

with open(target, "rb") as f:
    data = f.read()

print("File size:", len(data))
print("Header:", data[:16].hex(" "))

co = marshal.loads(data[16:])
print("\nco_name:", co.co_name)
print("co_filename:", co.co_filename)
print("co_names:", co.co_names)
print("co_varnames:", co.co_varnames)
print("co_consts count:", len(co.co_consts))
for i, c in enumerate(co.co_consts):
    if isinstance(c, type(co)):
        print(f"  [{i}] code: {c.co_name}, names: {c.co_names[:15]}")
    elif isinstance(c, bytes):
        print(f"  [{i}] bytes len={len(c)}")
    else:
        print(f"  [{i}] {repr(c)[:100]}")
