GetSTCoreVersion() {
	return 1.0601
}

;===Default Options===
SearchForLegacyReviewPackages = 1	;Should FindLatestReviewPackage search for review packages matching the old file naming scheme?
Ignore00Set = 1						;Should FindLatestReviewPackage ignore the *-00.pdf review package? Only matters if looking for legacy review packages

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

NYOutgoingFolder(projectnumber,consultant="") {
	Global
	if consultant = ""
		consultant = DefaultNYConsultant
	return DropboxFolder "\" consultant "\Incoming\" projectnumber " - Stamped"
}

PDFFolder(projectnumber) {
	return ProjectFolder(projectnumber) "\Drawings\PDF"
}

AutoCADFolder(projectnumber) {
	return ProjectFolder(projectnumber) "\Drawings\AutoCAD"
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

OpenStampedFolder() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := FindStampedFolder(projectnumber)
		If Location <> ""
		{
			Run %Location%
		}
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

OpenNYOutgoingFolder(consultant="") {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		Location := NYOutgoingFolder(projectnumber,consultant)
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

OpenDWG() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		dwg := FindDWG(projectnumber)
		If dwg <> ""
		{
			Run %dwg%
			return %dwg%
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

OpenPlansToStamp() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		rp := FindPlansToStamp(projectnumber)
		if rp <> ""
		{
			Run %rp%
			return %rp%
		}
	}
	return ""
}

OpenCalcsToStamp() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		rp := FindCalcsToStamp(projectnumber)
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

FindDWG(projectnumber) {
	file := FindLatestFile(AutoCADFolder(projectnumber), "*_01.dwg", 0)
	return file
}

FindLatestPhoto(projectnumber) {
	file := FindLatestFile(PhotosFolder(projectnumber), "*.jpg", 1)
	return file
}

FindStampedFolder(projectnumber) {
	return FindLatestFolder(PDFFolder(projectnumber),"Stamped*",0)
}

FindPlansToStamp(projectnumber) { 
	StampedFolder := FindStampedFolder(projectnumber)
	If StampedFolder <> ""
	{
		return FindLatestFile(StampedFolder, "*_01*.pdf", 0)
	}
}

FindCalcsToStamp(projectnumber) { 
	StampedFolder := FindStampedFolder(projectnumber)
	If StampedFolder <> ""
	{
		return FindLatestFile(StampedFolder, "*JB-" . projectnumber . "*.pdf", 0)
	}
}

FindLatestReviewPackage(projectnumber) {
	Global SearchForLegacyReviewPackages
	file := FindLatestFile(StructuralFolder(projectnumber), "*JB-" . projectnumber . "-00*_Calcs_ENP*_ALL.pdf", 1)
	If file =  
	{
		If SearchForLegacyReviewPackages
		{
			Global Ignore00Set
			ignore := ""
			If Ignore00Set
				ignore := "*" . projectnumber . "-00.pdf"
			file := FindLatestFile(StructuralFolder(projectnumber), "*JB-" . projectnumber . "*.pdf", 1, ignore)
		}
	}
	return file
}

FindLatestENP(projectnumber) {
	file := FindLatestFile(StructuralFolder(projectnumber), "*-00*.xlsm", 1)
	return file
}

FindLatestFolder(path, pattern, recurse, ignore="") {
	return FindLatestFile(path, pattern, recurse, ignore, 2)
}

FindLatestFile(path, pattern, recurse, ignore="", foldermode=0) {
	match := path . "\" . pattern
	ignorematch := path . "\" . ignore
	latestfile = ""
	FileList =
	IgnoreList =
	If StrLen(ignore) > 0
	{
		Loop, %ignorematch%, %foldermode%, %recurse%
			IgnoreList = %IgnoreList%%A_LoopFileFullPath%`n
	}
	Loop, %match%, %foldermode%,%recurse%
		FileList = %FileList%%A_LoopFileTimeModified%`t%A_LoopFileFullPath%`n
	Sort, FileList  ; Sort by date.
	Loop, parse, FileList, `n
	{
		if A_LoopField =  ; Omit the last linefeed (blank item) at the end of the list.
			continue
		StringSplit, FileItem, A_LoopField, %A_Tab%  ; Split into two parts at the tab char.
		if InStr(IgnoreList, FileItem2)
			continue
		latestfile = %FileItem2%
	}
	if latestfile <> ""
	{
		return latestfile
	}
	return ""
}

GetCurrentState() {
	projectnumber := GetProject()
	If projectnumber <> 0
	{
		return GetStateFromProjectNumber(projectnumber)
	}	
	return ""
}

GetStateFromProjectNumber(projectnumber) {
	StateByZipThree0 := {002: "NH",004: "NY",005: "NY",010: "MA",011: "MA",012: "MA",013: "MA",014: "MA",015: "MA",016: "MA",017: "MA",018: "MA",019: "MA",020: "MA",021: "MA",022: "MA",023: "MA",024: "MA",025: "MA",026: "MA",027: "MA",028: "RI",029: "RI",030: "NH",031: "NH",032: "NH",033: "NH",034: "NH",035: "NH",036: "NH",037: "NH",038: "NH",039: "ME",040: "ME",041: "ME",042: "ME",043: "ME",044: "ME",045: "ME",046: "ME",047: "ME",048: "ME",049: "ME",050: "VT",051: "VT",052: "VT",053: "VT",054: "VT",055: "MA",056: "VT",057: "VT",058: "VT",059: "VT",060: "CT",061: "CT",062: "CT",063: "CT",064: "CT",065: "CT",066: "CT",067: "CT",068: "CT",069: "CT",070: "NJ",071: "NJ",072: "NJ",073: "NJ",074: "NJ",075: "NJ",076: "NJ",077: "NJ",078: "NJ",079: "NJ",080: "NJ",081: "NJ",082: "NJ",083: "NJ",084: "NJ",085: "NJ",086: "NJ",087: "NJ",088: "NJ",089: "NJ"}
	StateByZipThree1 := {100: "NY",101: "NY",102: "NY",103: "NY",104: "NY",105: "NY",106: "NY",107: "NY",108: "NY",109: "NY",110: "NY",111: "NY",112: "NY",113: "NY",114: "NY",115: "NY",116: "NY",117: "NY",118: "NY",119: "NY",120: "NY",121: "NY",122: "NY",123: "NY",124: "NY",125: "NY",126: "NY",127: "NY",128: "NY",129: "NY",130: "NY",131: "NY",132: "NY",133: "NY",134: "NY",135: "NY",136: "NY",137: "NY",138: "NY",139: "NY",140: "NY",141: "NY",142: "NY",143: "NY",144: "NY",145: "NY",146: "NY",147: "NY",148: "NY",149: "NY",150: "PA",151: "PA",152: "PA",153: "PA",154: "PA",155: "PA",156: "PA",157: "PA",158: "PA",159: "PA",160: "PA",161: "PA",162: "PA",163: "PA",164: "PA",165: "PA",166: "PA",167: "PA",168: "PA",169: "PA",170: "PA",171: "PA",172: "PA",173: "PA",174: "PA",175: "PA",176: "PA",177: "PA",178: "PA",179: "PA",180: "PA",181: "PA",182: "PA",183: "PA",184: "PA",185: "PA",186: "PA",187: "PA",188: "PA",189: "PA",190: "PA",191: "PA",192: "PA",193: "PA",194: "PA",195: "PA",196: "PA",197: "DE",198: "DE",199: "DE"}
	StateByZipThree2 := {200: "DC",201: "VA",202: "DC",203: "DC",204: "DC",205: "DC",206: "MD",207: "MD",208: "MD",209: "MD",210: "MD",211: "MD",212: "MD",214: "MD",215: "MD",216: "MD",217: "MD",218: "MD",219: "MD",220: "VA",221: "VA",222: "VA",223: "VA",224: "VA",225: "VA",226: "VA",227: "VA",228: "VA",229: "VA",230: "VA",231: "VA",232: "VA",233: "VA",234: "VA",235: "VA",236: "VA",237: "VA",238: "VA",239: "VA",240: "VA",241: "VA",242: "VA",243: "VA",244: "VA",245: "VA",246: "VA",247: "WV",248: "WV",249: "WV",250: "WV",251: "WV",252: "WV",253: "WV",254: "WV",255: "WV",256: "WV",257: "WV",258: "WV",259: "WV",260: "WV",261: "WV",262: "WV",263: "WV",264: "WV",265: "WV",266: "WV",267: "WV",268: "WV",270: "NC",271: "NC",272: "NC",273: "NC",274: "NC",275: "NC",276: "NC",277: "NC",278: "NC",279: "NC",280: "NC",281: "NC",282: "NC",283: "NC",284: "NC",285: "NC",286: "NC",287: "NC",288: "NC",289: "NC",290: "SC",291: "SC",292: "SC",293: "SC",294: "SC",295: "SC",296: "SC",297: "SC",298: "SC",299: "SC"}
	StateByZipThree3 := {300: "GA",301: "GA",302: "GA",303: "GA",304: "GA",305: "GA",306: "GA",307: "GA",308: "GA",309: "GA",310: "GA",311: "GA",312: "GA",313: "GA",314: "GA",315: "GA",316: "GA",317: "GA",318: "GA",319: "GA",320: "FL",321: "FL",322: "FL",323: "FL",324: "FL",325: "FL",326: "FL",327: "FL",328: "FL",329: "FL",330: "FL",331: "FL",332: "FL",333: "FL",334: "FL",335: "FL",336: "FL",337: "FL",338: "FL",339: "FL",340: "AA",341: "FL",342: "FL",344: "FL",346: "FL",347: "FL",349: "FL",350: "AL",351: "AL",352: "AL",354: "AL",355: "AL",356: "AL",357: "AL",358: "AL",359: "AL",360: "AL",361: "AL",362: "AL",363: "AL",364: "AL",365: "AL",366: "AL",367: "AL",368: "AL",369: "AL",370: "TN",371: "TN",372: "TN",373: "TN",374: "TN",375: "TN",376: "TN",377: "TN",378: "TN",379: "TN",380: "TN",381: "TN",382: "TN",383: "TN",384: "TN",385: "TN",386: "MS",387: "MS",388: "MS",389: "MS",390: "MS",391: "MS",392: "MS",393: "MS",394: "MS",395: "MS",396: "MS",397: "MS",398: "GA",399: "GA"}
	StateByZipThree4 := {400: "KY",401: "KY",402: "KY",403: "KY",404: "KY",405: "KY",406: "KY",407: "KY",408: "KY",409: "KY",410: "KY",411: "KY",412: "KY",413: "KY",414: "KY",415: "KY",416: "KY",417: "KY",418: "KY",419: "KY",420: "KY",421: "KY",422: "KY",423: "KY",424: "KY",425: "KY",426: "KY",427: "KY",430: "OH",431: "OH",432: "OH",433: "OH",434: "OH",435: "OH",436: "OH",437: "OH",438: "OH",439: "OH",440: "OH",441: "OH",442: "OH",443: "OH",444: "OH",445: "OH",446: "OH",447: "OH",448: "OH",449: "OH",450: "OH",451: "OH",452: "OH",453: "OH",454: "OH",455: "OH",456: "OH",457: "OH",458: "OH",459: "OH",460: "IN",461: "IN",462: "IN",463: "IN",464: "IN",465: "IN",466: "IN",467: "IN",468: "IN",469: "IN",470: "IN",471: "IN",472: "IN",473: "IN",474: "IN",475: "IN",476: "IN",477: "IN",478: "IN",479: "IN",480: "MI",481: "MI",482: "MI",483: "MI",484: "MI",485: "MI",486: "MI",487: "MI",488: "MI",489: "MI",490: "MI",491: "MI",492: "MI",493: "MI",494: "MI",495: "MI",496: "MI",497: "MI",498: "MI",499: "MI"}
	StateByZipThree5 := {500: "IA",501: "IA",502: "IA",503: "IA",504: "IA",505: "IA",506: "IA",507: "IA",508: "IA",509: "IA",510: "IA",511: "IA",512: "IA",513: "IA",514: "IA",515: "IA",516: "IA",520: "IA",521: "IA",522: "IA",523: "IA",524: "IA",525: "IA",526: "IA",527: "IA",528: "IA",530: "WI",531: "WI",532: "WI",534: "WI",535: "WI",537: "WI",538: "WI",539: "WI",540: "WI",541: "WI",542: "WI",543: "WI",544: "WI",545: "WI",546: "WI",547: "WI",548: "WI",549: "WI",550: "MN",551: "MN",553: "MN",554: "MN",555: "MN",556: "MN",557: "MN",558: "MN",559: "MN",560: "MN",561: "MN",562: "MN",563: "MN",564: "MN",565: "MN",566: "MN",567: "MN",569: "DC",570: "SD",571: "SD",572: "SD",573: "SD",574: "SD",575: "SD",576: "SD",577: "SD",580: "ND",581: "ND",582: "ND",583: "ND",584: "ND",585: "ND",586: "ND",587: "ND",588: "ND",590: "MT",591: "MT",592: "MT",593: "MT",594: "MT",595: "MT",596: "MT",597: "MT",598: "MT",599: "MT"}
	StateByZipThree6 := {600: "IL",601: "IL",602: "IL",603: "IL",604: "IL",605: "IL",606: "IL",607: "IL",608: "IL",609: "IL",610: "IL",611: "IL",612: "IL",613: "IL",614: "IL",615: "IL",616: "IL",617: "IL",618: "IL",619: "IL",620: "IL",622: "IL",623: "IL",624: "IL",625: "IL",626: "IL",627: "IL",628: "IL",629: "IL",630: "MO",631: "MO",633: "MO",634: "MO",635: "MO",636: "MO",637: "MO",638: "MO",639: "MO",640: "MO",641: "MO",644: "MO",645: "MO",646: "MO",647: "MO",648: "MO",649: "MO",650: "MO",651: "MO",652: "MO",653: "MO",654: "MO",655: "MO",656: "MO",657: "MO",658: "MO",660: "KS",661: "KS",662: "KS",664: "KS",665: "KS",666: "KS",667: "KS",668: "KS",669: "KS",670: "KS",671: "KS",672: "KS",673: "KS",674: "KS",675: "KS",676: "KS",677: "KS",678: "KS",679: "KS",680: "NE",681: "NE",683: "NE",684: "NE",685: "NE",686: "NE",687: "NE",688: "NE",689: "NE",690: "NE",691: "NE",692: "NE",693: "NE"}
	StateByZipThree7 := {700: "LA",701: "LA",703: "LA",704: "LA",705: "LA",706: "LA",707: "LA",708: "LA",710: "LA",711: "LA",712: "LA",713: "LA",714: "LA",716: "AR",717: "AR",718: "AR",719: "AR",720: "AR",721: "AR",722: "AR",723: "AR",724: "AR",725: "AR",726: "AR",727: "AR",728: "AR",729: "AR",730: "OK",731: "OK",733: "TX",734: "OK",735: "OK",736: "OK",737: "OK",738: "OK",739: "OK",740: "OK",741: "OK",743: "OK",744: "OK",745: "OK",746: "OK",747: "OK",748: "OK",749: "OK",750: "TX",751: "TX",752: "TX",753: "TX",754: "TX",755: "TX",756: "TX",757: "TX",758: "TX",759: "TX",760: "TX",761: "TX",762: "TX",763: "TX",764: "TX",765: "TX",766: "TX",767: "TX",768: "TX",769: "TX",770: "TX",772: "TX",773: "TX",774: "TX",775: "TX",776: "TX",777: "TX",778: "TX",779: "TX",780: "TX",781: "TX",782: "TX",783: "TX",784: "TX",785: "TX",786: "TX",787: "TX",788: "TX",789: "TX",790: "TX",791: "TX",792: "TX",793: "TX",794: "TX",795: "TX",796: "TX",797: "TX",798: "TX",799: "TX"}
	StateByZipThree8 := {800: "CO",801: "CO",802: "CO",803: "CO",804: "CO",805: "CO",806: "CO",807: "CO",808: "CO",809: "CO",810: "CO",811: "CO",812: "CO",813: "CO",814: "CO",815: "CO",816: "CO",820: "WY",821: "WY",822: "WY",823: "WY",824: "WY",825: "WY",826: "WY",827: "WY",828: "WY",829: "WY",830: "WY",831: "WY",832: "ID",833: "ID",834: "ID",834: "WY",835: "ID",836: "ID",837: "ID",838: "ID",840: "UT",841: "UT",842: "UT",843: "UT",844: "UT",845: "UT",846: "UT",847: "UT",850: "AZ",851: "AZ",852: "AZ",853: "AZ",855: "AZ",856: "AZ",857: "AZ",859: "AZ",860: "AZ",863: "AZ",864: "AZ",865: "AZ",870: "NM",871: "NM",872: "NM",873: "NM",874: "NM",875: "NM",877: "NM",878: "NM",879: "NM",880: "NM",881: "NM",882: "NM",883: "NM",884: "NM",885: "TX",889: "NV",890: "NV",891: "NV",893: "NV",894: "NV",895: "NV",897: "NV",898: "NV"}
	StateByZipThree9 := {900: "CA",901: "CA",902: "CA",903: "CA",904: "CA",905: "CA",906: "CA",907: "CA",908: "CA",910: "CA",911: "CA",912: "CA",913: "CA",914: "CA",915: "CA",916: "CA",917: "CA",918: "CA",919: "CA",920: "CA",921: "CA",922: "CA",923: "CA",924: "CA",925: "CA",926: "CA",927: "CA",928: "CA",930: "CA",931: "CA",932: "CA",933: "CA",934: "CA",935: "CA",936: "CA",937: "CA",938: "CA",939: "CA",940: "CA",941: "CA",942: "CA",943: "CA",944: "CA",945: "CA",946: "CA",947: "CA",948: "CA",949: "CA",950: "CA",951: "CA",952: "CA",953: "CA",954: "CA",955: "CA",956: "CA",957: "CA",958: "CA",959: "CA",960: "CA",961: "CA",962: "AP",963: "AP",965: "AP",966: "AP",967: "HI",968: "HI",969: "GU",969: "PW ",969: "FM",969: "MP ",969: "MH ",970: "OR",971: "OR",972: "OR",973: "OR",974: "OR",975: "OR",976: "OR",977: "OR",978: "OR",979: "OR",980: "WA",981: "WA",982: "WA",983: "WA",984: "WA",985: "WA",986: "WA",988: "WA",989: "WA",990: "WA",991: "WA",992: "WA",993: "WA",994: "WA",995: "AK",996: "AK",997: "AK",998: "AK",999: "AK"}
	Index := SubStr(projectnumber,1,1)
	List := StateByZipThree%Index%
	Return List[substr(projectnumber,1,3)]
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