#Include %A_ScriptDir%
#Include *i ./st_core.ahkl
#NoEnv 
#NoTrayIcon
#SingleInstance off

ghurl := "https://raw.githubusercontent.com/ngordon-scty/st_core/master/"
st_core_version := 0
st_core_version_func := "GetSTCoreVersion"
If IsFunc(st_core_version_func)
	st_core_version := %st_core_version_func%()
;[todo] check local version with remote version tags on github, probably using their api, only download if required
;for now, lets just always assume master is the best release
UrlDownloadToFile, %ghurl%update_st_core.ahk, %A_ScriptDir%\update_st_core.ahk
UrlDownloadToFile, %ghurl%st_core.ahkl, %A_ScriptDir%\st_core.ahkl
IfNotExist, %A_ScriptDir%\st_default_keys.ahk
	UrlDownloadToFile, %ghurl%examples/st_default_keys.ahk, %A_ScriptDir%\st_default_keys.ahk