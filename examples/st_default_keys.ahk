#Include %A_ScriptDir%
#Include st_core.ahkl
UseProjectNumberFromClipboard = 1

;/* SOLARWORKS PAGE */
#F12:: OpenSolarWorks()			;Win + F12 opens SolarWorks
#F10:: OpenAHJPage()			;Win + F10 opens the AHJ page

;/* PHOTOS */
#9:: OpenPhotosFolder()			;Win + 9 opens photos folder
#^9:: OpenLatestPhoto()			;Ctrl + Win + 9 opens most recent photo

;/* MAIN PROJECT FOLDER */
#7:: OpenProjectFolder()		;Win + 7 opens project folder

;/* STRUCTURAL FOLDER */
#8:: OpenStructuralFolder()		;Win + 8 opens structural folder
#!8:: OpenLatestReviewPackage()	;Win + Alt + 8 opens latest review package PDF
#^8:: OpenLatestENP()			;Win + Ctrl + 8 opens latest ENP excel workbook

;/* PDF FOLDER */
#4:: OpenPDFFolder()			;Win + 4 opens PDF drawings folder
#^4:: OpenPDFOrPDFFolder()		;Win + Ctrl + 4 opens latest 01 set or PDF drawings folder

;/* STAMPING FILES */
#^6:: OpenPlansToStamp()		;Win + Ctrl + 6 opens the latest plan set ready for stamping
#!6:: OpenCalcsToStamp()		;Win + Alt + 6 opens the latest calculations package ready for stamping


;/* BECOME A PROJECT FOR ACTIVE MODE */
#^v:: SetProjectFromClipboard()	;Win + Ctrl + v changes the active project to the number in the clipboard