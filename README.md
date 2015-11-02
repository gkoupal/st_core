This is the core AHK library that I use as a ST member.

## What's it do?
This library provides functions you can bind to a single hot key to do the following things (just some examples):

1. Open the SolarWorks page for a project (`OpenSolarWorks()`)
2. Open the project folder on Triton (`OpenProjectFolder()`)
3. Open the photos, drawings, or PDF folder on Triton (`OpenPhotosFolder()` etc)
4. Open the most recent 01 PDF set (`OpenPDF()`)
5. Open the latest calculations PDF package (`OpenLatestReviewPackage()`)
6. Open the latest ENP Excel file (`OpenLatestENP()`)

It can work in two different ways:

1. **Clipboard Mode**: The above functions/hotkeys will attempt to find a project number in your clipboard and work from that
2. **Active Project Mode**: "Set it and forget it", press a hotkey to read the project number from your clipboard and set it as your active project, the hotkeys above work no matter what is in your clipboard.

## Installation / Quick Start

First, make sure you have AutoHotkey v1.1 or newer installed.

1. Download [update_st_core.ahk][updater_url] (<- right click, save as) from this repository and save it where you want the st_core library to live on your computer.
2. Double-click **`update_st_core.ahk`**. The latest version of `st_core.ahk` and `update_st_core.ahk` will be downloaded to the folder you're in, as well as `st_default_keys.ahk`.
3. **Quick-Start**: If you are a new AHK user, you can just double click `st_default_keys.ahk` and you'll be configured to use the keys as outlined [here][example_url]!

[updater_url]: https://raw.githubusercontent.com/ngordon-scty/st_core/master/update_st_core.ahk
[example_url]: https://github.com/ngordon-scty/st_core/blob/master/examples/README.md

## Usage
Once the library is downloaded, (to `C:\st_core` in this example), your main `AutoHotkey.ahk` file (*can be found by right clicking AHK in your system tray and pressing "edit this script"*) needs to have the following lines added at the very beginning of the file:
```
#Include c:\st_core\st_core.ahkl         ;this is the path to the library
UseProjectNumberFromClipboard = 1        ;1 for "Clipboard Mode", 0 for "Active Project Mode"
```
Then you can bind hotkeys to these functions in your AHK configuration just as you usually would. For example, I use **Windows Key + F12** to open the SolarWorks page for a project:
```
#F12:: OpenSolarWorks()
```
Copy a project number into your clipboard, and press **Windows + F12** and watch as SolarWorks magically opens.

#### Using 'Active Project Mode'
To use active project mode, you you must have `UseProjectNumberFromClipboard = 0` in your main AHK file and you need to have a hotkey bound to `SetProjectFromClipboard()`. I use **Ctrl + Win + V**:
```
UseProjectNumberFromClipboard = 0
#^v:: SetProjectFromClipboard()
```
... but any hotkey will work. For me, selecting a project number, pressing **Ctrl + C** and then **Ctrl + Win + V** is easy and intuitive to make it my active project.

## Documentation
A list of all the functions can be found by browsing the file, detailed documentation will be coming soon, I promise! Here is a list of the useful ones, hopefully with enough explanation:
##### Most useful:
These functions take action based on the active project or project number in your clipboard (depending on your configuration)
* `OpenProjectFolder()` - Opens the project folder
* `OpenPDFFolder()` - Opens the PDF folder
* `OpenPhotosFolder()` - Opens the audit photos folder
* `OpenStructuralFolder()` - Opens the structural folder
* `OpenPDF()` - Opens the most recent 01 set of drawings found in the PDF folder
* `OpenPDFOrPDFFolder()` - Tries to open the PDF, but opens the PDF folder if it can't be found
* `OpenStampedFolder()` - Opens the "Drawings\PDF\Stamped" (or 'Stamped (WET)') if it exists 
* `OpenLatestPhoto()` - Opens the latest photo in the audit photos folder
* `OpenLatestENP()` - Opens the latest ENP Excel workbook in the structural folder
* `OpenLatestReviewPackage()` - Opens the latest PDF review package found in the structural folder
* `OpenSolarWorks()` - Opens the SolarWorks page for the project
* `OpenAHJPage()` - Opens the AHJ page for the project
* `OpenPlansToStamp()` - Opens the most recent plan set in the "Drawings\PDF\Stamped" folder ready for stamping if it exists
* `OpenCalcsToStamp()` - Opens the most recent calculations package in the "Drawings\PDF\Stamped" folder ready for stamping if it exists


##### Still pretty useful:
* `ProjectFolder(projectnumber)` - returns the path to the project folder for `projectnumber`
* `StructuralFolder(projectnumber)` - returns the path to the structural folder for `projectnumber`
* `PDFFolder(projectnumber)` - returns the path to the PDF folder for `projectnumber`
* `PhotosFolder(projectnumber)` - returns the path to the Audit Photos folder for `projectnumber`
* `Find01PDF(projectnumber)` - returns the path to the latest 01 PDF for `projectnumber`, blank if not found
* `FindLatestPhoto(projectnumber)` - returns the path to the latest photo in the audit photos folder for `projectnumber`, blank if not found
* `FindLatestReviewPackage(projectnumber)` - returns the path to the latest review package PDF for `projectnumber`, blank if not found
* `FindLatestENP(projectnumber)` - returns the path to the latest ENP workbook for `projectnumber`, blank if not found

##### Useful but advanced:
* `GetProject()` - returns the current project number from clipboard or active
* `SetProject(project_number)` - sets the current active project to `project_number`
* `SetProjectFromClipboard()` - sets the current active project from whatever is in the clipboard, returns the project number if valid, 0 if not
* `GetProjectFromClipboard()` - gets a project number from the clipboard, returns the number if valid, 0 if not