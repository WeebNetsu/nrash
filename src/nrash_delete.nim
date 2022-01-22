import os, tables, terminal, strutils

import common

proc main() =
    let 
        FLAGS: Table[string, tuple[selected: bool, desc: string]] = checkFlags({
            "--empty": (false, "Empty your entire trash bin"), 
            "--help": (false, "Display help"),
            "--no-color": (false, "Remove the colors")
        }.toTable())
        colored: bool = not FLAGS["--no-color"].selected

    var
        fileCount: int = 0
        allFileDetails: seq[tuple[number: int, filePath: string, kind: PathComponent]]
        noFlags = false

    for kind, path in walkDir(TRASH_FILES_PATH):
        fileCount += 1

        if FLAGS["--help"].selected:
            displayHelp("nrash-delete", "Delete items in trash", FLAGS)
            break
        else:
            allFileDetails.add((fileCount, path, kind))
            noFlags = true

    if FLAGS["--empty"].selected:
        noFlags = false

        var deletedFileCount: int = 0

        echo "Are you sure you want to delete ", fileCount, " items from your trash? [y/n]"
        let choice: string = getUserInput()
        if choice == "y":
            # delete all files/folders
            for kind, path in walkDir(TRASH_FILES_PATH):
                try:
                    if kind == pcDir:
                        removeDir(path)
                    else:
                        removeFile(path)
                    
                    removeFile(TRASH_INFO_PATH & splitPath(path).tail & ".trashinfo")

                    deletedFileCount += 1
                    let perc: int = int((deletedFileCount / fileCount) * 100)
                    stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat(perc), fgGreen, "\t", $perc , "%")
                    cursorUp 1
                    eraseLine()
                except OSError:
                    if kind == pcDir:
                        echo "Error deleting folder: ", splitPath(path).tail
                    else:
                        echo "Error deleting file: ", splitPath(path).tail
                finally:
                    stdout.resetAttributes()
        else:
            echo "Trash not emptied."

    # TODO below just displays files, allow to delete
    if noFlags:
        var fileNum: int = 1

        while fileNum <= fileCount:
            var file = allFileDetails[fileNum]
            displayFiles(file.kind, file.filePath, fileNum, colored=(colored))
            fileNum += 1

            if ((fileNum mod 10 == 0)) or (fileNum == fileCount - 1):
                echo "Controls:\n\tn - next\t\tp - previous\n\tq - Quit\t\t1 - Show first item" # \t\t1 - show details of first item
                let choice: string = getUserInput()

                let action = navigateList(fileNum, fileCount, choice, allFileDetails)
                fileNum = action.value

                if not action.navigate:
                    discard getTrashFileInfo(allFileDetails[fileNum], true)
                    quit()

main()

stdout.resetAttributes() # reset terminal colors & stuff once program exists