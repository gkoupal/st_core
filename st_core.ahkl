GetSTCoreVersion() {
	return 1.02
}

GetProjectFileLocation() {
	return "c:\CurrentProjectNumber.txt"
}

GetProject() {
	Global
	If UseProjectNumberFromClipboard = 1 
	{
		project_number := GetProjectFromClipboard()
		If project_number <> 0 
		{
			return %project_number%
		}
	}
	Else
	{
		loc := GetProjectFileLocation()
		FileReadLine, fOut, %loc%, 1
		project_number := fOut
		return fOut
	}
	return 0
}

SetProject(project_number) {
	loc := GetProjectFileLocation()
	project_number := SanitizeProjectNumber(project_number)
	FileDelete, %loc%
	FileAppend, %project_number%, %loc%
}

SetProjectFromClipboard() {
	projectnumber := GetProjectFromClipboard()
	SetProject(projectnumber)
	return GetProject()
}

SanitizeProjectNumber(project_number) {
	project_number = %project_number%
	if project_number is digit
	{
		return %project_number%
	}
	if InStr(project_number, "JB-")
	{
		spos := InStr(project_number, "JB-") + 3
		project_number := SubStr(project_number,spos,InStr(project_number, "-", 0, spos) - spos)
		return SanitizeProjectNumber(project_number)
	}
	return 0
}

GetProjectFromClipboard() {
	project_number = %Clipboard%
	StringReplace,project_number,project_number,`n,,A
	StringReplace,project_number,project_number,`r,,A
	return SanitizeProjectNumber(project_number)
}

GetInstIDFromAPI(projectnumber) {
	apiurl := "http://10.100.1.148/designapi/api/customer/installation/"
	tmpfile = %A_ScriptDir%\instid.tmp
	UrlDownloadToFile, %apiurl%%projectnumber%, %tmpfile%
	FileReadLine, InstID, %tmpfile%, 1
	FileDelete, %tmpfile%
	return %InstID%
}

GetInstIDFromExcel(projectnumber) {
	return GetExcelJobListColumn(projectnumber,"InstID")
}

GetExcelJobListColumn(projectnumber, ColumnName) {
	retval := 0
	try
	{
		oExcel := ComObjActive("Excel.Application")
		JobList := oExcel.Workbooks("Job List.xlsm").Sheets("Job List")
		Projects := JobList.Range("JobsTable[Job Number]").Cells
		j := Projects.Rows.Count
		Loop
		{
			if j < 1
			{
				break
			}
			if (JobList.Range("JobsTable[Job Number]").Cells(j,1).Value = projectnumber)
			{
				retval := JobList.Range("JobsTable[" . ColumnName . "]").Cells(j,1).Value
				break
			}
			j--
		}
	}
	catch
	{
	}
	return retval
}

ProjectFolder(projectnumber) {
	if (AreWeRemote() = 1) {
		return LocalProjectFolder(projectnumber)
	} else {
		return ServerProjectFolder(projectnumber)
	}
}

AHJLink(projectnumber, instid = -1) {
	if(instid = -1) {
		instid := GetInstIDFromAPI(projectnumber)
	}
	if (InstID > 0) {
		return "http://ahj.solarcity.com/installations/" InstID
	}
	return ""
}

ServerProjectFolder(projectnumber) {
	return "\\triton\jobs\" ProjectSubFolder(projectnumber)
}

LocalProjectFolder(projectnumber) {
	return "c:\Local\jobs\" ProjectSubFolder(projectnumber)
}

StructuralFolder(projectnumber) {
	return ProjectFolder(projectnumber) "\Drawings\Structural"
}

NYOutgoingFolder(projectnumber) {
	Global
	JobListStatus := GetExcelJobListColumn(projectnumber, "Status")
	StringLower, JobListStatus, JobListStatus
	Suffix := ""
	If JobListStatus <> 0 
	{
		If InStr(JobListStatus, "pzse") 
		{
			Suffix := " - P"
		}
		If InStr(JobListStatus, "eclipse")
		{
			Suffix := " - E"
		}
	}
	return NYOutgoingFolder "\" projectnumber " - Stamped" Suffix
}

PDFFolder(projectnumber) {
	return ProjectFolder(projectnumber) "\Drawings\PDF"
}

PhotosFolder(projectnumber) {
	return ProjectFolder(projectnumber) "\Photos\Audit Photos"
}

ProjectSubFolder(projectnumber) {
	return SubStr(projectnumber, 1,3) "\" projectnumber
}

OpenProjectFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := ProjectFolder(projectnumber)
		Run %Location%
	}
}

OpenPDFFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := PDFFolder(projectnumber)
		Run %Location%
	}
}

OpenPhotosFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := PhotosFolder(projectnumber)
		Run %Location%
	}
}

OpenStructuralFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := StructuralFolder(projectnumber)
		Run %Location%
	}
}

OpenNYOutgoingFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := NYOutgoingFolder(projectnumber)
		Run %Location%
	}
}

OpenPDFOrPDFFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		If OpenPDF() = ""
		{
			OpenPDFFolder()
		}	
	
	}
}

OpenPDF() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		PDF := Find01PDF(projectnumber)
		If PDF <> ""
		{
			Run %PDF%
			return %PDF%
		}
	}
	return ""
}

OpenLatestPhoto() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Photo := FindLatestPhoto(projectnumber)
		if Photo <> ""
		{
			Run %Photo%
			return %Photo%
		}
	}
	return ""
}

OpenLatestENP() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		enp := FindLatestENP(projectnumber)
		if enp <> ""
		{
			Run %enp%
			return %enp%
		}
	}
	return ""
}

OpenLatestReviewPackage() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		rp := FindLatestReviewPackage(projectnumber)
		if rp <> ""
		{
			Run %rp%
			return %rp%
		}
	}
	return ""
}

OpenSolarWorks() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := "https://soleo.solarcity.com/Results.aspx?BillingType=Undefined&JobNumber=-" . projectnumber . "-"
		Run %location%
	}
}

OpenAHJPage() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := AHJLink(projectnumber)
		if Location <> ""
		{
			Run %Location%
		}
	}
}

Find01PDF(projectnumber) {
	file := FindLatestFile(PDFFolder(projectnumber), "*_01.pdf", 0)
	return file
}

FindLatestPhoto(projectnumber) {
	file := FindLatestFile(PhotosFolder(projectnumber), "*.jpg", 1)
	return file
}

FindLatestReviewPackage(projectnumber) {
	file := FindLatestFile(StructuralFolder(projectnumber), "*JB-" . projectnumber . "*.pdf", 1)
	return file
}

FindLatestENP(projectnumber) {
	file := FindLatestFile(StructuralFolder(projectnumber), "*-00*.xlsm", 1)
	return file
}

FindLatestFile(path, pattern, recurse) {
	match := path . "\" . pattern
	latestfile = ""
	FileList =
	Loop, %match%, 0,%recurse%
		FileList = %FileList%%A_LoopFileTimeModified%`t%A_LoopFileFullPath%`n
	Sort, FileList  ; Sort by date.
	Loop, parse, FileList, `n
	{
		if A_LoopField =  ; Omit the last linefeed (blank item) at the end of the list.
			continue
		StringSplit, FileItem, A_LoopField, %A_Tab%  ; Split into two parts at the tab char.
		latestfile = %FileItem2%
	}
	if latestfile <> ""
	{
		return latestfile
	}
	return ""
}

AreWeRemote() {
	IfExist, C:\remote
		return 1
	return 0
}

ToggleRemote() {
	If AreWeRemote()
		NotRemote()
	Else
		GoRemote()
}

GoRemote() {
	FileAppend, "", c:\remote
}

NotRemote() {
	FileDelete, c:\remote
}