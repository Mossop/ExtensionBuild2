CPP=cl.exe
MTL=midl.exe
RSC=rc.exe
BSC32=bscmake.exe
LINK32=link.exe
MT=mt.exe

!IF "$(CFG)" == ""
CFG=Release
!MESSAGE No configuration specified. Defaulting to Release.
!ENDIF 

!IF "$(CFG)" != "Release" && "$(CFG)" != "Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f <makefile> CFG="Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "Release"

OUTDIR=.\Release
CPP_PROJ=/nologo /MD /W3 /O1 /I "$(GECKO_SDK)\include" /FI"$(GECKO_SDK)\include\mozilla-config.h" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "XPCOM_GLUE" /D "MOZILLA_STRICT_API" /FR"$(INTDIR)\\" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c /Fp"$(INTDIR)\$(COMPONENT).pch"
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib nspr4.lib plds4.lib plc4.lib xpcomglue.lib shlwapi.lib /nologo /dll /incremental:no /machine:I386  /libpath:"$(GECKO_SDK)\lib"   
_VC_MANIFEST_INC=0
_VC_MANIFEST_BASENAME=__VC80

!ELSEIF  "$(CFG)" == "Debug"

OUTDIR=.\Debug
CPP_PROJ=/nologo /MDd /W3 /Gm /ZI /Od /I "$(GECKO_SDK)\include" /FI"$(GECKO_SDK)\include\mozilla-config.h" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "XPCOM_GLUE" /D "MOZILLA_STRICT_API" /FR"$(INTDIR)\\" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /RTC1 /c /Fp"$(INTDIR)\$(COMPONENT).pch"
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib nspr4.lib plds4.lib plc4.lib xpcomglue.lib shlwapi.lib /nologo /dll /incremental:yes /debug /machine:I386 /pdbtype:sept /libpath:"$(GECKO_SDK)\lib"
_VC_MANIFEST_INC=1
_VC_MANIFEST_BASENAME=__VC80.Debug

!ENDIF

INTDIR=$(OUTDIR)

!IF "$(_VC_MANIFEST_INC)" == "1"

_VC_MANIFEST_AUTO_RES=$(_VC_MANIFEST_BASENAME).auto.res
MT_SPECIAL_RETURN=1090650113
MT_SPECIAL_SWITCH=-notify_update
_VC_MANIFEST_EMBED_DLL= \
if exist $@.manifest $(MT) -manifest $@.manifest -out:$(_VC_MANIFEST_BASENAME).auto.manifest $(MT_SPECIAL_SWITCH) & \
if "%ERRORLEVEL%" == "$(MT_SPECIAL_RETURN)" \
rc /r $(_VC_MANIFEST_BASENAME).auto.rc & \
link $** /out:$@ $(LINK32_FLAGS)

_VC_MANIFEST_CLEAN=-del $(_VC_MANIFEST_BASENAME).auto.res \
    $(_VC_MANIFEST_BASENAME).auto.rc \
    $(_VC_MANIFEST_BASENAME).auto.manifest

!ELSE

_VC_MANIFEST_AUTO_RES=
_VC_MANIFEST_EMBED_DLL= \
if exist $@.manifest $(MT) -manifest $@.manifest -outputresource:$@;2
_VC_MANIFEST_CLEAN=

!ENDIF

ALL : "$(OUTDIR)" "$(INTDIR)" "$(OUTDIR)\$(COMPONENT).dll" "$(OUTDIR)\$(COMPONENT).bsc"

CLEAN :
	$(_VC_MANIFEST_CLEAN)
	-@erase "$(INTDIR)\$(COMPONENT).obj"
	-@erase "$(INTDIR)\$(COMPONENT).sbr"
	-@erase "$(INTDIR)\$(COMPONENT)Module.obj"
	-@erase "$(INTDIR)\$(COMPONENT)Module.sbr"
	-@erase "$(INTDIR)\vc80.idb"
	-@erase "$(OUTDIR)\$(COMPONENT).bsc"
	-@erase "$(OUTDIR)\$(COMPONENT).dll"
	-@erase "$(OUTDIR)\$(COMPONENT).dll.manifest"
	-@erase "$(OUTDIR)\$(COMPONENT).exp"
	-@erase "$(OUTDIR)\$(COMPONENT).lib"
!IF  "$(CFG)" == "Debug"
	-@erase "$(OUTDIR)\$(COMPONENT).pdb"
	-@erase "$(OUTDIR)\$(COMPONENT).ilk"
	-@erase "$(INTDIR)\vc80.pdb"
!ENDIF

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

!IF "$(OUTDIR)" != "$(INTDIR)"
"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"
!ENDIF

!include "rules.mak"

BSC32_FLAGS=/nologo
BSC32_SBRS= \
	"$(INTDIR)\$(COMPONENT).sbr" \
	"$(INTDIR)\$(COMPONENT)Module.sbr" 

"$(OUTDIR)\$(COMPONENT).bsc" : $(BSC32_SBRS)
	$(BSC32) /o$@ $(BSC32_FLAGS) $**

LINK32_OBJS= \
	"$(INTDIR)\$(COMPONENT).obj" \
	"$(INTDIR)\$(COMPONENT)Module.obj" 

"$(OUTDIR)\$(COMPONENT).dll" : $(LINK32_OBJS) $(_VC_MANIFEST_AUTO_RES)
	$(LINK32) $** $(LINK32_FLAGS) /pdb:"$(OUTDIR)\$(COMPONENT).pdb" /implib:"$(OUTDIR)\$(COMPONENT).lib" /out:$@
	$(_VC_MANIFEST_EMBED_DLL)

$(_VC_MANIFEST_BASENAME).auto.res : $(_VC_MANIFEST_BASENAME).auto.rc

$(_VC_MANIFEST_BASENAME).auto.rc : $(_VC_MANIFEST_BASENAME).auto.manifest
	type <<$@
#include <winuser.h>
2RT_MANIFEST"$(_VC_MANIFEST_BASENAME).auto.manifest"
<< KEEP

$(_VC_MANIFEST_BASENAME).auto.manifest :
	type <<$@
<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>
</assembly>
<< KEEP

SOURCE=.\$(COMPONENT).cpp

"$(INTDIR)\$(COMPONENT).obj"	"$(INTDIR)\$(COMPONENT).sbr" : $(SOURCE)
	$(CPP) $(CPP_PROJ) $**

SOURCE=.\$(COMPONENT)Module.cpp

"$(INTDIR)\$(COMPONENT)Module.obj"	"$(INTDIR)\$(COMPONENT)Module.sbr" : $(SOURCE)
