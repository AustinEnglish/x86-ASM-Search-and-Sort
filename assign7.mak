ALL: assign7.EXE

CLEAN:
 -@erase assign7.EXE
 -@erase assign7.ILK
 -@erase assign7.PDB
 -@erase assign7.OBJ
 -@erase assign7.LST

assign7.ASM:

assign7.OBJ: assign7.ASM
 ml /c /coff /Zi assign7.ASM

assign7.EXE: assign7.OBJ
 link /debug /subsystem:console /out:assign7.EXE /entry:start assign7.OBJ KERNEL32.LIB IO.OBJ
