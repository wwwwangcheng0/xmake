; this is a NSI spec file,
; it is autogenerated by the xmake build system.
; do not edit by hand.

; includes
!include "MUI2.nsh"
!include "WordFunc.nsh"
!include "WinMessages.nsh"
!include "FileFunc.nsh"
!include "UAC.nsh"

; the version information
!define VERSION      "${PACKAGE_VERSION}"
!if "${PACKAGE_VERSION_BUILD}" != ""
!define VERSION_FULL "${PACKAGE_VERSION}+${PACKAGE_VERSION_BUILD}"
!else
!define VERSION_FULL "${PACKAGE_VERSION}"
!endif

; set the package name
Name "${PACKAGE_NAME} - v${VERSION}"

; set the output file path
OutFile "${PACKAGE_OUTPUTFILE}"

; set the working directory
!cd "${PACKAGE_WORKDIR}"

; use unicode
Unicode true

; use best compressor
SetCompressor /FINAL /SOLID lzma
SetCompressorDictSize 64
SetDatablockOptimize ON

; set the default installation directory
!if "${PACKAGE_ARCH}" == "x64"
  !define PROGRAMFILES $PROGRAMFILES64
  !define HKLM HKLM64
  !define HKCU HKCU64
!else
  !define PROGRAMFILES $PROGRAMFILES
  !define HKLM HKLM
  !define HKCU HKCU
!endif

; request application privileges for Windows Vista
RequestExecutionLevel user

; set DPI aware
ManifestDPIAware true

; set icon
!if "${PACKAGE_ICONFILE}" != ""
  !define MUI_ICON "${PACKAGE_ICONFILE}"
!endif

; UAC
!macro Init thing
  uac_tryagain:
  !insertmacro UAC_RunElevated
  ${Switch} $0
  ${Case} 0
    ${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
    ${IfThen} $3 <> 0 ${|} ${Break} ${|} ;we are admin, let the show go on
    ${If} $1 = 3 ;RunAs completed successfully, but with a non-admin user
      MessageBox mb_YesNo|mb_IconExclamation|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
    ${EndIf}
    ;fall-through and die
  ${Case} 1223
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, aborting!"
    Quit
  ${Case} 1062
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Logon service not running, aborting!"
    Quit
  ${Default}
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Unable to elevate, error $0"
    Quit
  ${EndSwitch}

  ; The UAC plugin changes the error level even in the inner process, reset it.
  ; note fix install exit code 1223 to 0 with slient /S
  SetErrorLevel 0
  SetShellVarContext all
!macroend

; add the install Pages
!insertmacro MUI_PAGE_WELCOME
!if "${PACKAGE_LICENSEFILE}" != ""
  !insertmacro MUI_PAGE_LICENSE "${PACKAGE_LICENSEFILE}"
!endif
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; add uninstall Pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; add languages
!insertmacro MUI_LANGUAGE "English"

; set registry paths
!define RegUninstall "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}"

; set product information
VIProductVersion                         "${VERSION}.0"
VIFileVersion                            "${VERSION}.0"
VIAddVersionKey /LANG=0 ProductName      "${PACKAGE_NAME}"
VIAddVersionKey /LANG=0 Comments         "${PACKAGE_DESCRIPTION}"
VIAddVersionKey /LANG=0 CompanyName      "${PACKAGE_COMPANY}"
VIAddVersionKey /LANG=0 LegalCopyright   "${PACKAGE_COPYRIGHT}"
VIAddVersionKey /LANG=0 FileDescription  "${PACKAGE_NAME} Installer - v${VERSION}"
VIAddVersionKey /LANG=0 OriginalFilename "${PACKAGE_FILENAME}"
VIAddVersionKey /LANG=0 FileVersion      "${VERSION_FULL}"
VIAddVersionKey /LANG=0 ProductVersion   "${VERSION_FULL}"

; helper functions
Function TrimQuote
  Exch $R1 ; Original string
  Push $R2

Loop:
  StrCpy $R2 "$R1" 1
  StrCmp "$R2" "'"   TrimLeft
  StrCmp "$R2" "$\"" TrimLeft
  StrCmp "$R2" "$\r" TrimLeft
  StrCmp "$R2" "$\n" TrimLeft
  StrCmp "$R2" "$\t" TrimLeft
  StrCmp "$R2" " "   TrimLeft
  GoTo Loop2
TrimLeft:
  StrCpy $R1 "$R1" "" 1
  Goto Loop

Loop2:
  StrCpy $R2 "$R1" 1 -1
  StrCmp "$R2" "'"   TrimRight
  StrCmp "$R2" "$\"" TrimRight
  StrCmp "$R2" "$\r" TrimRight
  StrCmp "$R2" "$\n" TrimRight
  StrCmp "$R2" "$\t" TrimRight
  StrCmp "$R2" " "   TrimRight
  GoTo Done
TrimRight:
  StrCpy $R1 "$R1" -1
  Goto Loop2

Done:
  Pop $R2
  Exch $R1
FunctionEnd

; remove directory if it exists
Function RMDirIfExists
!define RMDirIfExists '!insertmacro RMDirIfExistsCall'
!macro RMDirIfExistsCall _PATH
  push '${_PATH}'
 Call RMDirIfExists
!macroend
  Exch $0
  IfFileExists "$0" 0 fileDoesNotExist
  RMDir /r "$0"
  fileDoesNotExist:
FunctionEnd

Function un.RMDirIfExists
!define unRMDirIfExists '!insertmacro unRMDirIfExistsCall'
!macro unRMDirIfExistsCall _PATH
  push '${_PATH}'
  Call un.RMDirIfExists
!macroend
  Exch $0
  IfFileExists "$0" 0 fileDoesNotExist
  RMDir /r "$0"
  fileDoesNotExist:
FunctionEnd

; remove file if it exists
Function RMFileIfExists
!define RMFileIfExists '!insertmacro RMFileIfExistsCall'
!macro RMFileIfExistsCall _PATH
  push '${_PATH}'
  Call RMFileIfExists
!macroend
  Exch $0
  IfFileExists "$0" 0 fileDoesNotExist
  Delete "$0"
  fileDoesNotExist:
FunctionEnd

Function un.RMFileIfExists
!define unRMFileIfExists '!insertmacro unRMFileIfExistsCall'
!macro unRMFileIfExistsCall _PATH
  push '${_PATH}'
  Call un.RMFileIfExists
!macroend
  Exch $0
  IfFileExists "$0" 0 fileDoesNotExist
  Delete "$0"
  fileDoesNotExist:
FunctionEnd

; remove it's parent directories if they are empty
Function RMEmptyParentDirs
!define RMEmptyParentDirs '!insertmacro RMEmptyParentDirsCall'
!macro RMEmptyParentDirsCall _PATH
  push '${_PATH}'
  Call RMEmptyParentDirs
!macroend
  ClearErrors

  Exch $0
  RMDir "$0\.."

  IfErrors Skip
  ${RMEmptyParentDirs} "$0\.."
  Skip:

  Pop $0
FunctionEnd

Function un.RMEmptyParentDirs
!define unRMEmptyParentDirs '!insertmacro unRMEmptyParentDirsCall'
!macro unRMEmptyParentDirsCall _PATH
  push '${_PATH}'
  Call un.RMEmptyParentDirs
!macroend
  ClearErrors

  Exch $0
  RMDir "$0\.."

  IfErrors Skip
  ${unRMEmptyParentDirs} "$0\.."
  Skip:

  Pop $0
FunctionEnd


; setup installer
Var NoAdmin
Function .onInit
  ${GetOptions} $CMDLINE "/NOADMIN" $NoAdmin
  ${If} ${Errors}
    !insertmacro Init "installer"
    StrCpy $NoAdmin "false"
  ${Else}
    StrCpy $NoAdmin "true"
  ${EndIf}

  ; get installation root directory
  ${If} $InstDir == ""
    ${If} $NoAdmin == "false"
      ReadRegStr $R0 ${HKLM} ${RegUninstall} "InstallLocation"
    ${Else}
      ReadRegStr $R0 ${HKCU} ${RegUninstall} "InstallLocation"
    ${EndIf}
    ${If} $R0 != ""
      Push $R0
      Call TrimQuote
      Pop  $R0
      StrCpy $InstDir $R0
    ${EndIf}
  ${EndIf}
  ${If} $InstDir == ""
    StrCpy $InstDir "${PROGRAMFILES}\${PACKAGE_NAME}"
  ${EndIf}
FunctionEnd

Section "${PACKAGE_NAME} (required)" InstallExeutable

  SectionIn RO

  ; set output path to the installation directory.
  SetOutPath $InstDir

  ; add install commands
  ${PACKAGE_INSTALLCMDS}

  ; add uninstaller
  WriteUninstaller "uninstall.exe"
  ; Write the uninstall keys for Windows
  !macro AddReg RootKey
    WriteRegStr   ${RootKey} ${RegUninstall} "NoAdmin"               "$NoAdmin"
    WriteRegStr   ${RootKey} ${RegUninstall} "DisplayName"           "${PACKAGE_NSIS_DISPLAY_NAME}"
    !if "${PACKAGE_NSIS_DISPLAY_ICON}" != ""
    WriteRegStr   ${RootKey} ${RegUninstall} "DisplayIcon"           '"${PACKAGE_NSIS_DISPLAY_ICON}"'
    !endif
    WriteRegStr   ${RootKey} ${RegUninstall} "Comments"              "${PACKAGE_DESCRIPTION}"
    WriteRegStr   ${RootKey} ${RegUninstall} "Publisher"             "${PACKAGE_COPYRIGHT}"
    WriteRegStr   ${RootKey} ${RegUninstall} "UninstallString"       '"$InstDir\uninstall.exe"'
    WriteRegStr   ${RootKey} ${RegUninstall} "QuiteUninstallString"  '"$InstDir\uninstall.exe" /S'
    WriteRegStr   ${RootKey} ${RegUninstall} "InstallLocation"       $InstDir
    WriteRegStr   ${RootKey} ${RegUninstall} "HelpLink"              "${PACKAGE_HOMEPAGE}"
    WriteRegStr   ${RootKey} ${RegUninstall} "URLInfoAbout"          "${PACKAGE_HOMEPAGE}"
    WriteRegStr   ${RootKey} ${RegUninstall} "URLUpdateInfo"         "${PACKAGE_HOMEPAGE}"
    WriteRegDWORD ${RootKey} ${RegUninstall} "VersionMajor"          ${PACKAGE_VERSION_MAJOR}
    WriteRegDWORD ${RootKey} ${RegUninstall} "VersionMinor"          ${PACKAGE_VERSION_MINOR}
    WriteRegStr   ${RootKey} ${RegUninstall} "DisplayVersion"        ${VERSION_FULL}
    WriteRegDWORD ${RootKey} ${RegUninstall} "NoModify"              1
    WriteRegDWORD ${RootKey} ${RegUninstall} "NoRepair"              1

    ; write size to reg
    ${GetSize} "$InstDir" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD ${RootKey} ${RegUninstall} "EstimatedSize" "$0"
  !macroend

  ${If} $NoAdmin == "false"
    !insertmacro AddReg ${HKLM}
  ${Else}
    !insertmacro AddReg ${HKCU}
  ${EndIf}
SectionEnd

; add the binary directory to %PATH%
Section "Add to PATH" InstallPath
  ${If} $NoAdmin == "false"
    ReadRegStr $R0 ${HKLM} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
    ${WordReplace} $R0 ";${PACKAGE_BINDIR}" "" "+" $R1
    WriteRegExpandStr ${HKLM} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" "$R1;${PACKAGE_BINDIR}"
  ${Else}
    ReadRegStr $R0 ${HKCU} "Environment" "Path"
    ${WordReplace} $R0 ";${PACKAGE_BINDIR}" "" "+" $R1
    WriteRegExpandStr ${HKCU} "Environment" "Path" "$R1;${PACKAGE_BINDIR}"
  ${EndIf}
   SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

${PACKAGE_NSIS_INSTALL_SECTIONS}

; define language strings
LangString DESC_InstallExeutable ${LANG_ENGLISH} "${PACKAGE_DESCRIPTION}"
LangString DESC_InstallPath ${LANG_ENGLISH} "Add ${PACKAGE_NAME} to PATH"
${PACKAGE_NSIS_INSTALL_DESCS}

; assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${InstallExeutable} $(DESC_InstallExeutable)
!insertmacro MUI_DESCRIPTION_TEXT ${InstallPath} $(DESC_InstallPath)
${PACKAGE_NSIS_INSTALL_DESCRIPTION_TEXTS}
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; setup uninstaller
Function un.onInit
  ; check if we need uac
  ReadRegStr $NoAdmin ${HKLM} ${RegUninstall} "NoAdmin"
  IfErrors 0 +2
  ReadRegStr $NoAdmin ${HKCU} ${RegUninstall} "NoAdmin"

  ${IfNot} $NoAdmin == "true"
    !insertmacro Init "uninstaller"
  ${EndIf}
FunctionEnd

Section "Uninstall"

  ; add uninstall commands
  ${PACKAGE_UNINSTALLCMDS}

  ; remove the binary directory from %Path%
  ${If} $NoAdmin == "false"
    DeleteRegKey ${HKLM} ${RegUninstall}
    ReadRegStr $R0 ${HKLM} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
    ${WordReplace} $R0 ";${PACKAGE_BINDIR}" "" "+" $R1
    WriteRegExpandStr ${HKLM} "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" "$R1"
  ${Else}
    DeleteRegKey ${HKCU} ${RegUninstall}
    ReadRegStr $R0 ${HKCU} "Environment" "Path"
    ${WordReplace} $R0 ";${PACKAGE_BINDIR}" "" "+" $R1
    WriteRegExpandStr ${HKCU} "Environment" "Path" "$R1"
  ${EndIf}

  ; remove uninstall.exe
  ${unRMFileIfExists} "$InstDir\uninstall.exe"
  ${unRMEmptyParentDirs} "$InstDir\uninstall.exe"

SectionEnd

