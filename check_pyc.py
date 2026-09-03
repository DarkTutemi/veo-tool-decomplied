import py_compile, tempfile, os

tmp = tempfile.mkdtemp()
src = os.path.join(tmp, "test.py")
with open(src, "w") as f:
    f.write('print("hello")\n')
pyc_file = py_compile.compile(src, cfile=os.path.join(tmp, "test.pyc"))
print("pyc file:", pyc_file)
with open(pyc_file, "rb") as f:
    data = f.read()
print("Test pyc size:", len(data))
print("Header 16 bytes:", data[:16].hex(" "))
print("Byte 16 (code obj start):", hex(data[16]))

print()
target = r"H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\main.pyc"
with open(target, "rb") as f:
    tdata = f.read(64)
print("Target 16 bytes:", tdata[:16].hex(" "))
print("Target byte 16:", hex(tdata[16]))
