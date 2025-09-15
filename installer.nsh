##NOT BEING USED

!macro customInstall
  CreateShortCut "$DESKTOP\VGSLite.lnk" "$INSTDIR\VGSLite.exe"
  CreateShortCut "$SMPROGRAMS\VGSLite\VGSLite.lnk" "$INSTDIR\VGSLite.exe"
!macroend

!macro customUnInstall
  Delete "$DESKTOP\VGSLite.lnk"
  Delete "$SMPROGRAMS\VGSLite\VGSLite.lnk"
!macroend