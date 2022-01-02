import os, tables, terminal, strformat, options

from strutils import split, delete, replace, startsWith

import common

proc restoreFile(filePath: string, kind: PathComponent) =
    let 
        chosenFileName = splitPath(filePath).tail
        infoFile = TRASH_INFO_PATH & chosenFileName & ".trashinfo"

    var
        originalPath: string
        f: File
        
    if open(f, infoFile): # check if file can be opened
        try:
            discard f.readLine() # first line is useless
            originalPath = f.readLine().split("=")[1] # read single line
            close(f)
        except EOFError, IndexDefect:
            close(f)
            showError("Some data may have been corrupted!")
    else:
        showError("File not (info) found.")
    
    try:
        # currently, if the file/folder original location doesn't exist (original folder it was in was deleted)
        # then the below will fail.
        if kind == pcDir:
            moveDir(TRASH_FILES_PATH & chosenFileName, originalPath)
            removeFile(infoFile)
        else:
            moveFile(TRASH_FILES_PATH & chosenFileName, originalPath)
            removeFile(infoFile)

        echo &"Restored {chosenFileName}!"
    except OSError: # if original file path does not exist
        let allPaths: seq[string] = originalPath.split("/")

        var 
            fullPath: string = ""
            dirMissing: bool = false

        for path in allPaths:
            if path != allPaths[len(allPaths) - 1]:
                fullPath &= path & "/"
                if not dirExists(fullPath):
                    dirMissing = true
                    try:
                        createDir(fullPath)
                    except OSError:
                        showError("Could not restore file/folder to original location. Error at '" & fullPath & "'.")
        
        if not dirMissing: # if a different error occured than the original location not existing, such as permission error
            showError("Could not restore file/folder to original location.")
        else: # try restoring it again
            restoreFile(filePath, kind)

proc main() =
    let 
        FLAGS: Table[string, tuple[selected: bool, desc: string]] = checkFlags({
            "--help": (false, "Display help"),
            "--no-color": (false, "Remove the colors"),
            "--cur": (false, "Files that were children of current directory")
        }.toTable())

        colored: bool = not FLAGS["--no-color"].selected

    var
        fileCount: int = 0
        viewableFiles: int = 0
        allFileDetails: seq[tuple[number: int, filePath: string, kind: PathComponent]]
        noFlags = false

    for kind, path in walkDir(TRASH_FILES_PATH):
        fileCount += 1

        if FLAGS["--help"].selected:
            displayHelp("nrash-list", "List items in trash", FLAGS)
            break
        elif FLAGS["--cur"].selected:
            let info: Option[tuple[originalPath: string, deleteDate: string]] = getTrashFileInfo((fileCount, path, kind), false)
            if isSome(info):
                if startsWith(get(info).originalPath, getCurrentDir()):
                    allFileDetails.add((fileCount, path, kind))
                    viewableFiles += 1
        else:
            allFileDetails.add((fileCount, path, kind))
            viewableFiles += 1

    if not FLAGS["--help"].selected:
        noFlags = true

    if noFlags:
        var fileNum: int = 1

        while fileNum < viewableFiles:
            var file = allFileDetails[fileNum]
            displayFiles(file.kind, file.filePath, fileNum, colored=(colored))
            fileNum += 1

            if ((fileNum mod 10 == 0)) or (fileNum == fileCount - 1):
                echo "Controls:\n\tn - next\t\tp - previous\n\tq - Quit\t\t1 - Restore first item" # \t\t1 - show details of first item
                let choice: string = getUserInput()

                let action = navigateList(fileNum, fileCount, choice, allFileDetails)
                fileNum = action.value

                if not action.navigate:
                    restoreFile(allFileDetails[fileNum].filePath, allFileDetails[fileNum].kind)
                    quit()

        # currently you can't view previous results if the last results are needed to be shown with below
        # optional, but maybe todo, allow users to go back (use "p")
        if not (viewableFiles mod 10 == 0):
            echo "Controls:\n\tq - Quit\t\t1 - Restore first item" # \t\t1 - show details of first item
            let choice: string = getUserInput()

            let action = navigateList(fileNum, fileCount, choice, allFileDetails)
            fileNum = action.value

            if not action.navigate:
                restoreFile(allFileDetails[fileNum].filePath, allFileDetails[fileNum].kind)

main()

stdout.resetAttributes() # reset terminal colors & stuff once program exists